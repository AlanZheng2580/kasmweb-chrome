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

Access at **https://localhost:6901** — accept the self-signed certificate warning.

| Field    | Value       |
|----------|-------------|
| Username | `kasm_user` |
| Password | `password`  |

> Change `VNC_PW` in `docker-compose.yml` to set a custom password.

## Managing Extensions

### Add an extension

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

4. Rebuild:
   ```bash
   make restart
   ```

### Remove an extension

Remove the entry from `extensions.json` and delete its config file in `extension-configs/` if present, then run `make restart`.

## Project Structure

```
.
├── Dockerfile                     # Extends kasmweb/chrome
├── docker-compose.yml             # Dev environment
├── Makefile                       # Convenience commands
├── extensions.json                # Extensions to install (by ID)
├── extension-configs/             # Per-extension managed policy configs
│   └── <extension-id>.json
└── scripts/
    └── install-extensions.sh      # Generates Chrome policy at build time
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
