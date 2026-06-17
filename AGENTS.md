# Repository Guidelines

## Project Structure & Module Organization

This repository builds a customized `kasmweb/chrome` container with managed Chrome policies. Core files live at the repository root:

- `Dockerfile` extends the upstream Kasm Chrome image and copies static policy/config files.
- `docker-compose.yml` defines the local `kasm-chrome` service, port mapping, environment, and KasmVNC mount.
- `Makefile` provides the standard development commands.
- `chrome-policies/managed/policy.json` is the committed Chrome managed policy.
- `offline-extensions/<extension-id>.crx` stores bundled CRX packages.
- `offline-extensions/updates/<extension-id>.xml` stores local Chrome update manifests.
- `kasmvnc.yaml` customizes the KasmVNC server.

## Build, Test, and Development Commands

- `make build` builds the Docker image with the current policy inputs.
- `make up` starts the container in the background.
- `make restart` rebuilds and restarts after config changes.
- `make rebuild` performs a no-cache rebuild, then starts the service.
- `make logs` tails container logs for startup and policy debugging.
- `make shell` opens `/bin/bash` inside the running container.
- `make down` stops and removes the container.

The service is exposed at `https://localhost:6902` from `docker-compose.yml`; credentials default to `kasm_user` / `password`.

## Coding Style & Naming Conventions

Keep JSON files pretty-printed with two-space indentation. Name CRX and update manifest files exactly after the Chrome extension ID, for example `offline-extensions/onnfghpihccifgojkpnnncpagjcdbjod.crx` and `offline-extensions/updates/onnfghpihccifgojkpnnncpagjcdbjod.xml`. Policy changes should be made directly in `chrome-policies/managed/policy.json`.

## Testing Guidelines

There is no automated test suite. Validate changes with:

```bash
jq . chrome-policies/managed/policy.json
make build
make up
make logs
```

For policy changes, use `make shell` and inspect `/etc/opt/chrome/policies/managed/policy.json`. Confirm Chrome behavior through the Kasm UI after `make restart`.

## Commit & Pull Request Guidelines

Recent commits use short Conventional Commit prefixes such as `feat:` and `fix:`. Follow that style, for example `feat: add extension policy config` or `fix: preserve proxy settings`.

Pull requests should describe the policy or container behavior changed, list manual validation commands run, link related issues when applicable, and include screenshots only when browser UI behavior changes.

## Security & Configuration Tips

Do not commit production passwords in `docker-compose.yml`; override `VNC_PW` locally or in deployment configuration. Treat extension IDs, update URLs, PAC scripts, and domain blocklists as security-sensitive inputs and review generated Chrome policy before shipping.
