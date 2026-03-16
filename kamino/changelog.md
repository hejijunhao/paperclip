# Changelog

## 1.0.2 — 2026-03-16

### Bootstrap Invite from UI

Added a self-service bootstrap flow so the first admin can claim the instance directly from the browser — no SSH or CLI access needed.

- **New endpoint:** `POST /api/health/bootstrap-rotate` — generates (or rotates) a bootstrap CEO invite and returns the invite URL. Only available when no instance admin exists yet; returns `403` once an admin is set.
- **Updated `BootstrapPendingPage`** — replaced the static "check your logs" message with a "Generate invite link" button. Clicking it calls the new endpoint and displays a clickable invite URL. The CLI command is still available in a collapsible `<details>` block.

## 1.0.1 — 2026-03-16

### Fly.io Stability Fix

Resolved intermittent 503 errors caused by health check flapping under resource pressure.

- **Health check interval:** 15s → 30s — reduces unnecessary probe frequency
- **Health check timeout:** 5s → 10s — tolerates brief slowdowns without marking the instance as dead

**Root cause:** Two issues combined — (1) the startup banner crashed the process with `EACCES` when reading `/paperclip/instances/default/.env` (permission mismatch on the volume), and (2) the 1GB shared-cpu machine couldn't consistently respond to `/api/health` within 5s. Fly's proxy marked the instance unhealthy and returned `503`.

### Server Fix

- Wrapped `.env` file read in `startup-banner.ts:resolveAgentJwtSecretStatus()` with try-catch so a permission error on the diagnostic banner doesn't crash the entire server

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
