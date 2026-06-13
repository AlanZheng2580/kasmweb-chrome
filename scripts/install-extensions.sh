#!/usr/bin/env bash
set -euo pipefail

EXTENSIONS_JSON="/opt/kasm/extensions.json"
# kasmweb/chrome ships Google Chrome, which reads from /etc/opt/chrome/policies/managed/
POLICY_DIR="/etc/opt/chrome/policies/managed"
POLICY_FILE="${POLICY_DIR}/extensions.json"

mkdir -p "${POLICY_DIR}"

FORCELIST=$(jq '[.extensions[] | "\(.id);\(.update_url)"]' "${EXTENSIONS_JSON}")

EXTENSION_SETTINGS="{}"
while IFS= read -r ext; do
  id=$(echo "${ext}" | jq -r '.id')
  update_url=$(echo "${ext}" | jq -r '.update_url')
  entry=$(jq -n --arg mode "force_installed" --arg url "${update_url}" \
    '{installation_mode: $mode, update_url: $url, toolbar_pin: "force_pinned"}')
  EXTENSION_SETTINGS=$(echo "${EXTENSION_SETTINGS}" | jq --arg id "${id}" --argjson entry "${entry}" \
    '. + {($id): $entry}')
done < <(jq -c '.extensions[]' "${EXTENSIONS_JSON}")

jq -n \
  --argjson forcelist "${FORCELIST}" \
  --argjson settings "${EXTENSION_SETTINGS}" \
  '{
    ExtensionInstallForcelist: $forcelist,
    ExtensionSettings: $settings
  }' > "${POLICY_FILE}"

echo "Extension install policy written to ${POLICY_FILE}"
cat "${POLICY_FILE}"
