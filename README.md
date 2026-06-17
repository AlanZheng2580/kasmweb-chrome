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

### Add an online extension

1. Find the extension ID from the Chrome Web Store URL:
   `https://chromewebstore.google.com/detail/<name>/<extension-id>`

2. Add it to `extensions.json`:
   ```json
   {
     "id": "<extension-id>",
     "name": "Extension Name",
     "update_url": "https://clients2.google.com/service/update2/crx"
   }
   ```

3. Optionally create `extension-configs/<extension-id>.json` with managed policy settings.

4. Update `chrome-policies/managed/policy.json`, then rebuild:
   ```bash
   make restart
   ```

### Add an offline extension

For networks that cannot reach the Chrome Web Store, package the CRX into the Docker image:

1. Put the CRX file in `offline-extensions/`, for example:
   `offline-extensions/<extension-id>.crx`

2. Add the extension to `extensions.json` with `crx_path` and the CRX package `version`:
   ```json
   {
     "id": "<extension-id>",
     "name": "Extension Name",
     "crx_path": "<extension-id>.crx",
     "version": "1.0.0"
   }
   ```

3. Optionally create `extension-configs/<extension-id>.json` with managed policy settings.

4. Add or update `offline-extensions/updates/<extension-id>.xml`, update `chrome-policies/managed/policy.json`, then rebuild the image:
   ```bash
   make rebuild
   ```

The Docker image copies pre-generated policy files. It does not run `scripts/configure.sh` during build or startup.

### Remove an extension

Remove the entry from `extensions.json` and delete its config file in `extension-configs/` if present, then run `make restart`.

## Project Structure

```
.
├── Dockerfile                     # Extends kasmweb/chrome
├── docker-compose.yml             # Dev environment
├── Makefile                       # Convenience commands
├── extensions.json                # Extensions to install (by ID)
├── chrome-policies/managed/       # Pre-generated Chrome managed policies
│   └── policy.json
├── extension-configs/             # Per-extension managed policy configs
│   └── <extension-id>.json
├── offline-extensions/            # Optional CRX files for offline installs
│   ├── updates/<extension-id>.xml  # Local Chrome update manifests
│   └── <extension-id>.crx
└── scripts/
    └── configure.sh               # Optional helper to regenerate static policy files
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
