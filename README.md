# KasmWeb Custom Chrome

A customized KasmWeb Chrome workspace with pre-generated Chrome managed policies.

## Requirements

- Docker
- Docker Compose

## Quick Start

```bash
# Build and start
make up

# Open in browser
make open
```

Access at **https://localhost:6902** — accept the self-signed certificate warning.

| Field    | Value       |
|----------|-------------|
| Username | `kasm_user` |
| Password | `password`  |

> Change `VNC_PW` in `docker-compose.yml` to set a custom password.

## Managing Chrome Policy

This image uses pre-generated Chrome managed policy files. Docker only copies the
files into the image; it does not generate policy during build or startup.
Edit `chrome-policies/managed/policy.json` directly for URL blocklists, proxy
settings, and other Chrome policies. Rebuild the image after policy changes:

```bash
make restart
```

## Offline Extension

The Proxy Switcher and Manager extension is still installed offline so the UI is
available to users. Its CRX lives in `offline-extensions/`, and Chrome installs it
from the local update manifest in `offline-extensions/updates/`.

To add or update an offline extension:

1. Put the CRX file in `offline-extensions/`, for example:
   `offline-extensions/<extension-id>.crx`

2. Add or update `offline-extensions/updates/<extension-id>.xml`:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <gupdate xmlns="http://www.google.com/update2/response" protocol="2.0">
     <app appid="<extension-id>">
       <updatecheck codebase="file:///opt/kasm/offline-extensions/<extension-id>.crx" version="1.0.0" />
     </app>
   </gupdate>
   ```

3. Reference that local update manifest from
   `chrome-policies/managed/policy.json -> ExtensionSettings`:
   ```json
   "<extension-id>": {
     "installation_mode": "force_installed",
     "update_url": "file:///opt/kasm/offline-extensions/updates/<extension-id>.xml",
     "toolbar_pin": "force_pinned"
   }
   ```

4. Rebuild and restart:
   ```bash
   make restart
   ```

Do not add `managed_policy` under `ExtensionSettings`; Chrome does not support
that field there. Proxy routing is configured through Chrome's native
`ProxySettings` policy instead.

## Managing Proxy PAC

Chrome uses the native policy value at `ProxySettings.ProxyPacUrl` in
`chrome-policies/managed/policy.json`. Proxy routing is controlled by Chrome's
native `ProxySettings` policy.

1. Edit the readable PAC source:
   ```bash
   $EDITOR tools/proxy.pac
   ```

2. Generate the replacement policy value:
   ```bash
   tools/generate-proxy-pac-url.sh
   ```

3. Copy the generated `"ProxyPacUrl": "data:..."` line into:
   `chrome-policies/managed/policy.json -> ProxySettings.ProxyPacUrl`

4. Rebuild and restart:
   ```bash
   make restart
   ```

## Project Structure

```
.
├── Dockerfile                     # Extends kasmweb/chrome
├── docker-compose.yml             # Dev environment
├── Makefile                       # Convenience commands
├── chrome-policies/managed/       # Pre-generated Chrome managed policies
│   └── policy.json
├── offline-extensions/            # CRX files and local update manifests
│   ├── updates/<extension-id>.xml
│   └── <extension-id>.crx
├── tools/                         # Local helper scripts
│   ├── generate-proxy-pac-url.sh
│   └── proxy.pac                  # Editable PAC source for ProxyPacUrl
└── kasmvnc.yaml                   # KasmVNC server settings
```

## Available Commands

| Command        | Description                        |
|----------------|------------------------------------|
| `make build`   | Build the Docker image             |
| `make up`      | Start the container                |
| `make down`    | Stop and remove the container      |
| `make restart` | Rebuild and restart the container  |
| `make logs`    | Tail container logs                |
| `make shell`   | Open a shell in the container      |
| `make open`    | Open the browser UI                |
