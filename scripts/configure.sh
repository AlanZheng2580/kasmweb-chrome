#!/usr/bin/env bash
set -euo pipefail

EXTENSIONS_JSON="/opt/kasm/extensions.json"
BLACKLIST_JSON="/opt/kasm/blacklist.json"
CONFIGS_DIR="/opt/kasm/extension-configs"
OFFLINE_EXTENSIONS_DIR="/opt/kasm/offline-extensions"
OFFLINE_UPDATES_DIR="${OFFLINE_EXTENSIONS_DIR}/updates"
POLICY_DIR="/etc/opt/chrome/policies/managed"
POLICY_FILE="${POLICY_DIR}/policy.json"

mkdir -p "${POLICY_DIR}"
mkdir -p "${OFFLINE_UPDATES_DIR}"

URL_BLOCKLIST=$(jq '[.domains[]]' "${BLACKLIST_JSON}")

EXTENSION_SETTINGS="{}"
PROXY_SETTINGS="null"

while IFS= read -r ext; do
  id=$(echo "${ext}" | jq -r '.id')
  update_url=$(echo "${ext}" | jq -r '.update_url')
  crx_path=$(echo "${ext}" | jq -r '.crx_path // empty')
  version=$(echo "${ext}" | jq -r '.version // empty')

  if [[ -n "${crx_path}" ]]; then
    if [[ -z "${version}" ]]; then
      echo "Extension ${id} uses crx_path but is missing version" >&2
      exit 1
    fi

    if [[ "${crx_path}" != /* ]]; then
      crx_path="${OFFLINE_EXTENSIONS_DIR}/${crx_path}"
    fi

    if [[ ! -f "${crx_path}" ]]; then
      echo "Offline CRX not found for extension ${id}: ${crx_path}" >&2
      exit 1
    fi

    update_manifest="${OFFLINE_UPDATES_DIR}/${id}.xml"
    cat > "${update_manifest}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<gupdate xmlns="http://www.google.com/update2/response" protocol="2.0">
  <app appid="${id}">
    <updatecheck codebase="file://${crx_path}" version="${version}" />
  </app>
</gupdate>
EOF
    update_url="file://${update_manifest}"
  fi

  entry=$(jq -n --arg url "${update_url}" \
    '{installation_mode: "force_installed", update_url: $url, toolbar_pin: "force_pinned"}')
  config_file="${CONFIGS_DIR}/${id}.json"
  if [[ -f "${config_file}" ]]; then
    import_json=$(jq -c '.' "${config_file}")
    managed_policy=$(jq -n --argjson v 1 --arg j "${import_json}" \
      '{"import-version": $v, "import-json": $j}')
    entry=$(echo "${entry}" | jq --argjson p "${managed_policy}" '. + {managed_policy: $p}')

    # Derive Chrome ProxySettings from the first PAC proxy profile (first match wins).
    # Chrome ignores file:// PAC URLs, so embed the script as a data: URL instead.
    # Mandatory so it is enforced and cannot be overridden by the extension or user.
    if [[ "${PROXY_SETTINGS}" == "null" ]]; then
      first_profile=$(jq -r '.profiles[0] // empty' "${config_file}")
      if [[ -n "${first_profile}" ]]; then
        profile_mode=$(jq -r --arg k "profile.${first_profile}" '.[$k].value.mode // empty' "${config_file}")
        if [[ "${profile_mode}" == "pac_script" ]]; then
          pac_b64=$(jq -rj --arg k "profile.${first_profile}" '.[$k].value.pacScript.data' "${config_file}" | base64 -w0)
          PROXY_SETTINGS=$(jq -n --arg url "data:application/x-ns-proxy-autoconfig;base64,${pac_b64}" \
            '{ProxyMode: "pac_script", ProxyPacUrl: $url, ProxyPacMandatory: true}')
        fi
      fi
    fi
  fi
  EXTENSION_SETTINGS=$(echo "${EXTENSION_SETTINGS}" | jq --arg id "${id}" --argjson e "${entry}" \
    '. + {($id): $e}')
done < <(jq -c '.extensions[]' "${EXTENSIONS_JSON}")

jq -n \
  --argjson settings "${EXTENSION_SETTINGS}" \
  --argjson blocklist "${URL_BLOCKLIST}" \
  --argjson proxy "${PROXY_SETTINGS}" \
  '{ExtensionSettings: $settings, URLBlocklist: $blocklist}
   + (if $proxy == null then {} else {ProxySettings: $proxy} end)' > "${POLICY_FILE}"

echo "Policy written to ${POLICY_FILE}"
cat "${POLICY_FILE}"
