# Changelog

## 1.0.0 — 2026-03-16

### Fly.io Deployment

Deployed Paperclip to Fly.io as a single-machine app under the `crimson-sun-technologies` org.

- **App:** `paperclip` at https://paperclip.fly.dev
- **Region:** `sin` (Singapore)
- **Machine:** shared-cpu-1x / 1GB RAM
- **Volume:** 1GB encrypted persistent volume at `/paperclip`
- **Mode:** `authenticated` / `public`

### New Files

- **`fly.toml`** — Fly.io app configuration (VM sizing, health checks, volume mount, env vars)
- **`docker-entrypoint.sh`** — Pre-initializes the embedded PostgreSQL cluster on first boot, working around the `embedded-postgres` library's `initialise()` failing in containerized environments
- **`CLAUDE.md`** — Contributor guidance for Claude Code with build commands, architecture overview, and key conventions

### Dockerfile Fixes

- Added missing workspace package.json COPY lines for `packages/plugins/sdk`, `packages/plugins/create-paperclip-plugin`, and all plugin examples — the Dockerfile predated the plugin system
- Added explicit build steps for `@paperclipai/shared` and `@paperclipai/plugin-sdk` before the server build, since the server imports from the plugin SDK
- Replaced the direct `node` CMD with the new `docker-entrypoint.sh` script

### Server Fix

- Added `mkdirSync(dataDir, { recursive: true })` before embedded PostgreSQL initialization in `server/src/index.ts` to ensure parent directories exist on fresh volumes

### Lockfile

- Regenerated `pnpm-lock.yaml` to match current `server/package.json` (new deps: `hermes-paperclip-adapter`, `@paperclipai/plugin-sdk`, `ajv`, `chokidar`)

### Deployment Notes

- Embedded PostgreSQL requires at least 1GB RAM (its default `shared_buffers = 128MB` plus Node.js runtime exceeds 256MB)
- Health check grace period set to 60s to accommodate first-boot DB initialization and migrations
- Secrets (`BETTER_AUTH_SECRET`, `PAPERCLIP_PUBLIC_URL`) set via `fly secrets set`
- Bootstrap admin invite generated via `paperclipai onboard --yes` + `auth bootstrap-ceo` over SSH
