# KasmWeb Custom Chrome

A customized KasmWeb Chrome workspace with pre-installed browser extensions managed via Chrome policy.

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

## Managing Extensions

This image uses pre-generated Chrome managed policy files. Docker only copies the
files into the image; it does not generate policy during build or startup.

### Add an online extension

1. Find the extension ID from the Chrome Web Store URL:
   `https://chromewebstore.google.com/detail/<name>/<extension-id>`
2. Add an entry under `ExtensionSettings` in `chrome-policies/managed/policy.json`:
   ```json
   "<extension-id>": {
     "installation_mode": "force_installed",
     "update_url": "https://clients2.google.com/service/update2/crx",
     "toolbar_pin": "force_pinned"
   }
   ```
3. Rebuild:
   ```bash
   make restart
   ```

### Add an offline extension

For networks that cannot reach the Chrome Web Store, package the CRX into the Docker image:

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

3. Reference the local update manifest from `chrome-policies/managed/policy.json`:
   ```json
   "<extension-id>": {
     "installation_mode": "force_installed",
     "update_url": "file:///opt/kasm/offline-extensions/updates/<extension-id>.xml",
     "toolbar_pin": "force_pinned"
   }
   ```
4. Rebuild the image:
   ```bash
   make rebuild
   ```

### Remove an extension

Remove the entry from `chrome-policies/managed/policy.json`, delete the CRX and
update XML if they are no longer needed, then run `make restart`.

## Managing Proxy PAC

Chrome uses the native policy value at `ProxySettings.ProxyPacUrl` in
`chrome-policies/managed/policy.json`. Proxy Switcher and Manager uses
`ExtensionSettings.onnfghpihccifgojkpnnncpagjcdbjod.managed_policy.import-json`
to show the same PAC profile in the extension UI. Keep both values in sync.

1. Edit the readable PAC source:
   ```bash
   $EDITOR tools/proxy.pac
   ```

2. Generate the replacement policy values:
   ```bash
   tools/generate-proxy-pac-url.sh
   ```

   To use a different extension profile name:
   ```bash
   tools/generate-proxy-pac-url.sh tools/proxy.pac "Corporate PAC"
   ```

3. Copy the generated `"ProxyPacUrl": "data:..."` line into:
   `chrome-policies/managed/policy.json -> ProxySettings.ProxyPacUrl`

4. Copy the generated `"import-json": "..."` line into:
   `chrome-policies/managed/policy.json -> ExtensionSettings.onnfghpihccifgojkpnnncpagjcdbjod.managed_policy.import-json`

5. Rebuild and restart:
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
├── offline-extensions/            # Optional CRX files for offline installs
│   ├── updates/<extension-id>.xml  # Local Chrome update manifests
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
