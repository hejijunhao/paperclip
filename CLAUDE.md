# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What Is Paperclip

Paperclip is an open-source control plane for AI-agent companies — a Node.js server with a React UI that orchestrates agent coordination, task management, budgeting, governance, and goal alignment. The current implementation target is V1, defined in `doc/SPEC-implementation.md`.

## Build & Dev Commands

```sh
pnpm install              # install all workspace dependencies
pnpm dev                  # start API + UI in watch mode (http://localhost:3100)
pnpm dev:once             # start without file watching
pnpm dev:server           # server only
pnpm dev:ui               # UI only
pnpm build                # build all packages
pnpm typecheck            # typecheck all packages (alias: pnpm -r typecheck)
```

### Testing

```sh
pnpm test                 # vitest in watch mode
pnpm test:run             # vitest run once (CI mode)
pnpm test:e2e             # Playwright end-to-end tests
pnpm test:e2e:headed      # E2E with visible browser

# Run a single test file
pnpm vitest run path/to/file.test.ts

# Run tests matching a pattern
pnpm vitest run -t "pattern"
```

Vitest projects: `packages/db`, `packages/adapters/opencode-local`, `server`, `ui`, `cli`.

### Database

```sh
pnpm db:generate          # generate Drizzle migration after schema changes
pnpm db:migrate           # apply migrations
```

Database change workflow: edit `packages/db/src/schema/*.ts` → ensure exported from `packages/db/src/schema/index.ts` → `pnpm db:generate` → `pnpm -r typecheck`. The Drizzle config reads compiled schema from `dist/schema/*.js`, so `db:generate` compiles first.

Leave `DATABASE_URL` unset for dev — embedded PostgreSQL auto-manages at `~/.paperclip/instances/default/db`.

### Verification Before Hand-off

```sh
pnpm -r typecheck && pnpm test:run && pnpm build
```

## Monorepo Structure

pnpm workspace. Key packages:

- **`server/`** — Express 5 REST API, orchestration services, WebSocket realtime, auth (better-auth)
- **`ui/`** — React 19 + Vite SPA, Tailwind CSS, Radix UI, TanStack Query
- **`cli/`** — Commander.js CLI (setup, config, operations), built with esbuild
- **`packages/db/`** — Drizzle ORM schema, migrations, DB client
- **`packages/shared/`** — Shared types, constants, validators, API path constants
- **`packages/adapters/`** — Pluggable agent runtime adapters (claude-local, codex-local, cursor-local, gemini-local, openclaw-gateway, opencode-local, pi-local)
- **`packages/plugins/sdk/`** — Stable plugin SDK (`@paperclipai/plugin-sdk`)
- **`packages/adapter-utils/`** — Shared adapter utilities
- **`doc/`** — Product specs, architecture docs, plans
- **`skills/`** — Agent skill definitions (injected at runtime)

## Architecture Principles

1. **Company-scoped everything.** All domain entities belong to a company; boundaries enforced in routes/services.
2. **Contracts stay synchronized.** Schema/API changes must propagate across all layers: `packages/db` → `packages/shared` → `server` → `ui`.
3. **Control-plane invariants:** single-assignee task model, atomic issue checkout, approval gates, budget hard-stop auto-pause, activity logging for mutations.
4. **API standards:** base path `/api`, consistent HTTP errors (400/401/403/404/409/422/500), board = full-control operator, agent access via bearer API keys (hashed at rest).

## API & Auth

- Board access = full-control operator context
- Agent access uses bearer API keys from `agent_api_keys` table, hashed at rest
- When adding endpoints: apply company access checks, enforce actor permissions (board vs agent), write activity log entries for mutations

## Lockfile Policy

GitHub Actions owns `pnpm-lock.yaml`. Do not commit it in pull requests — CI regenerates it on master.

## Key Specs & Docs

Read before making significant changes:
1. `doc/GOAL.md` — strategic vision
2. `doc/PRODUCT.md` — product overview
3. `doc/SPEC-implementation.md` — V1 build contract
4. `doc/DEVELOPING.md` — full development guide
5. `doc/DATABASE.md` — database setup options

Plan documents go in `doc/plans/` with `YYYY-MM-DD-slug.md` filenames.
