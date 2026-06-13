#!/usr/bin/env bash
set -euo pipefail

EXTENSIONS_JSON="/opt/kasm/extensions.json"
BLACKLIST_JSON="/opt/kasm/blacklist.json"
CONFIGS_DIR="/opt/kasm/extension-configs"
POLICY_DIR="/etc/opt/chrome/policies/managed"
POLICY_FILE="${POLICY_DIR}/policy.json"

mkdir -p "${POLICY_DIR}"

FORCELIST=$(jq '[.extensions[] | "\(.id);\(.update_url)"]' "${EXTENSIONS_JSON}")
URL_BLOCKLIST=$(jq '[.domains[]]' "${BLACKLIST_JSON}")

EXTENSION_SETTINGS="{}"
while IFS= read -r ext; do
  id=$(echo "${ext}" | jq -r '.id')
  update_url=$(echo "${ext}" | jq -r '.update_url')
  entry=$(jq -n --arg url "${update_url}" \
    '{installation_mode: "force_installed", update_url: $url, toolbar_pin: "force_pinned"}')
  config_file="${CONFIGS_DIR}/${id}.json"
  if [[ -f "${config_file}" ]]; then
    managed_policy=$(cat "${config_file}")
    entry=$(echo "${entry}" | jq --argjson p "${managed_policy}" '. + {managed_policy: $p}')
  fi
  EXTENSION_SETTINGS=$(echo "${EXTENSION_SETTINGS}" | jq --arg id "${id}" --argjson e "${entry}" \
    '. + {($id): $e}')
done < <(jq -c '.extensions[]' "${EXTENSIONS_JSON}")

jq -n \
  --argjson forcelist "${FORCELIST}" \
  --argjson settings "${EXTENSION_SETTINGS}" \
  --argjson blocklist "${URL_BLOCKLIST}" \
  '{
    ExtensionInstallForcelist: $forcelist,
    ExtensionSettings: $settings,
    URLBlocklist: $blocklist
  }' > "${POLICY_FILE}"

echo "Policy written to ${POLICY_FILE}"
cat "${POLICY_FILE}"
