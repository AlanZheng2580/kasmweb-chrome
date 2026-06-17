#!/usr/bin/env bash
set -euo pipefail

PAC_FILE="${1:-tools/proxy.pac}"
PROFILE_NAME="${2:-Example PAC}"

if [[ ! -f "${PAC_FILE}" ]]; then
  echo "PAC file not found: ${PAC_FILE}" >&2
  echo "Usage: $0 [path/to/proxy.pac] [profile-name]" >&2
  exit 1
fi

PAC_CONTENT=$(printf '%s' "$(cat "${PAC_FILE}")")

if base64 --help 2>/dev/null | grep -q -- '-w'; then
  PAC_B64=$(printf '%s' "${PAC_CONTENT}" | base64 -w0)
else
  PAC_B64=$(printf '%s' "${PAC_CONTENT}" | base64 | tr -d '\n')
fi

PAC_URL="data:application/x-ns-proxy-autoconfig;base64,${PAC_B64}"
IMPORT_JSON=$(PAC_CONTENT="${PAC_CONTENT}" PROFILE_NAME="${PROFILE_NAME}" python3 - <<'PY'
import json
import os

profile_name = os.environ["PROFILE_NAME"]
pac_content = os.environ["PAC_CONTENT"]
profile_key = f"profile.{profile_name}"
extension_config = {
    "profiles": [profile_name],
    profile_key: {
        "value": {
            "mode": "pac_script",
            "pacScript": {
                "mandatory": True,
                "data": pac_content,
            },
        },
    },
}
print(json.dumps(extension_config, separators=(",", ":")))
PY
)
IMPORT_JSON_VALUE=$(IMPORT_JSON="${IMPORT_JSON}" python3 - <<'PY'
import json
import os

print(json.dumps(os.environ["IMPORT_JSON"]))
PY
)

cat <<EOF
Update chrome-policies/managed/policy.json in both places below.

1. Replace ProxySettings.ProxyPacUrl with:

"ProxyPacUrl": "${PAC_URL}"

2. Replace ExtensionSettings.onnfghpihccifgojkpnnncpagjcdbjod.managed_policy.import-json with:

"import-json": ${IMPORT_JSON_VALUE}

The import-json value is a JSON-encoded string used by Proxy Switcher and Manager
so users can see the PAC profile in the extension UI.

Source PAC file:

${PAC_FILE}
EOF
