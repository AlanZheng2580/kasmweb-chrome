#!/usr/bin/env bash
set -euo pipefail

EXTENSIONS_JSON="/opt/kasm/extensions.json"
BLACKLIST_JSON="/opt/kasm/blacklist.json"
CONFIGS_DIR="/opt/kasm/extension-configs"
# kasmweb/chrome ships Google Chrome, which reads from /etc/opt/chrome/policies/managed/
POLICY_DIR="/etc/opt/chrome/policies/managed"
POLICY_FILE="${POLICY_DIR}/extensions.json"

mkdir -p "${POLICY_DIR}"

# Build ExtensionInstallForcelist array: ["id;update_url", ...]
FORCELIST=$(jq '[.extensions[] | "\(.id);\(.update_url)"]' "${EXTENSIONS_JSON}")

# Build ExtensionSettings object: force_installed with update_url required
EXTENSION_SETTINGS="{}"
while IFS= read -r ext; do
  id=$(echo "${ext}" | jq -r '.id')
  update_url=$(echo "${ext}" | jq -r '.update_url')
  entry=$(jq -n --arg mode "force_installed" --arg url "${update_url}" \
    '{installation_mode: $mode, update_url: $url, toolbar_pin: "force_pinned"}')

  config_file="${CONFIGS_DIR}/${id}.json"
  if [[ -f "${config_file}" ]]; then
    managed_policy=$(cat "${config_file}")
    entry=$(echo "${entry}" | jq --argjson p "${managed_policy}" '. + {managed_policy: $p}')
  fi

  EXTENSION_SETTINGS=$(echo "${EXTENSION_SETTINGS}" | jq --arg id "${id}" --argjson entry "${entry}" \
    '. + {($id): $entry}')
done < <(jq -c '.extensions[]' "${EXTENSIONS_JSON}")

# Build URLBlocklist array from blacklist.json
URL_BLOCKLIST=$(jq '[.domains[]]' "${BLACKLIST_JSON}")

# Write final Chrome managed policy file
jq -n \
  --argjson forcelist "${FORCELIST}" \
  --argjson settings "${EXTENSION_SETTINGS}" \
  --argjson blocklist "${URL_BLOCKLIST}" \
  '{
    ExtensionInstallForcelist: $forcelist,
    ExtensionSettings: $settings,
    URLBlocklist: $blocklist
  }' > "${POLICY_FILE}"

echo "Chrome extension policy written to ${POLICY_FILE}"
cat "${POLICY_FILE}"
