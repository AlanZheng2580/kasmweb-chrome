#!/usr/bin/env bash
set -euo pipefail

PAC_FILE="${1:-tools/proxy.pac}"

if [[ ! -f "${PAC_FILE}" ]]; then
  echo "PAC file not found: ${PAC_FILE}" >&2
  echo "Usage: $0 [path/to/proxy.pac]" >&2
  exit 1
fi

PAC_CONTENT=$(printf '%s' "$(cat "${PAC_FILE}")")

if base64 --help 2>/dev/null | grep -q -- '-w'; then
  PAC_B64=$(printf '%s' "${PAC_CONTENT}" | base64 -w0)
else
  PAC_B64=$(printf '%s' "${PAC_CONTENT}" | base64 | tr -d '\n')
fi

PAC_URL="data:application/x-ns-proxy-autoconfig;base64,${PAC_B64}"

cat <<EOF
Replace chrome-policies/managed/policy.json -> ProxySettings.ProxyPacUrl with:

"ProxyPacUrl": "${PAC_URL}"

Source PAC file:

${PAC_FILE}
EOF
