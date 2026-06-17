# Repository Guidelines

## Project Structure & Module Organization

This repository builds a customized `kasmweb/chrome` container with managed Chrome policies. Core files live at the repository root:

- `Dockerfile` extends the upstream Kasm Chrome image and runs policy configuration.
- `docker-compose.yml` defines the local `kasm-chrome` service, port mapping, environment, and mounted config files.
- `Makefile` provides the standard development commands.
- `extensions.json` lists forced Chrome extensions by ID.
- `blacklist.json` lists blocked domains for Chrome policy.
- `extension-configs/<extension-id>.json` stores optional managed policy for a specific extension.
- `scripts/configure.sh` generates `/etc/opt/chrome/policies/managed/policy.json`.

`scripts/install-extensions.sh` is retained as an older extension policy generator; prefer `scripts/configure.sh` for current behavior.

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

Shell scripts use Bash with `set -euo pipefail`, two-space indentation inside control blocks, uppercase constants for paths, and `jq` for JSON generation. Keep JSON files pretty-printed with two-space indentation. Name extension config files exactly after the Chrome extension ID, for example `extension-configs/onnfghpihccifgojkpnnncpagjcdbjod.json`.

## Testing Guidelines

There is no automated test suite. Validate changes with:

```bash
jq . extensions.json blacklist.json extension-configs/*.json
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
