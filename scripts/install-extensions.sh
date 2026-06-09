#!/usr/bin/env bash
set -euo pipefail

EXTENSIONS_JSON="/opt/kasm/extensions.json"
CONFIGS_DIR="/opt/kasm/extension-configs"
POLICY_DIR="/etc/chromium/policies/managed"
POLICY_FILE="${POLICY_DIR}/extensions.json"

mkdir -p "${POLICY_DIR}"

# Build ExtensionInstallForcelist array: ["id;update_url", ...]
FORCELIST=$(jq '[.extensions[] | "\(.id);\(.update_url)"]' "${EXTENSIONS_JSON}")

# Build ExtensionSettings object from per-extension config files
EXTENSION_SETTINGS="{}"
while IFS= read -r id; do
  config_file="${CONFIGS_DIR}/${id}.json"
  if [[ -f "${config_file}" ]]; then
    policy=$(cat "${config_file}")
    EXTENSION_SETTINGS=$(echo "${EXTENSION_SETTINGS}" | jq --arg id "${id}" --argjson policy "${policy}" \
      '. + {($id): {installation_mode: "force_installed", "runtime_allowed_hosts": [], "policy": $policy}}')
  fi
done < <(jq -r '.extensions[].id' "${EXTENSIONS_JSON}")

# Write final Chrome managed policy file
jq -n \
  --argjson forcelist "${FORCELIST}" \
  --argjson settings "${EXTENSION_SETTINGS}" \
  '{
    ExtensionInstallForcelist: $forcelist,
    ExtensionSettings: $settings
  }' > "${POLICY_FILE}"

echo "Chrome extension policy written to ${POLICY_FILE}"
cat "${POLICY_FILE}"
