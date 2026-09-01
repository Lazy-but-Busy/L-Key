# Environments

Four environments: `local`, `dev`, `staging`, `production`.

## Principles

1. **No real secret is ever committed.** `.env.example` files are committed as
   documentation; real values are git-ignored.
2. **Configuration is validated at boot.** A missing or malformed variable
   stops the process with a readable message rather than surfacing later as a
   confusing failure.
3. **Client-visible means public.** Anything reaching the Flutter binary or a
   `NEXT_PUBLIC_*` variable is readable by anyone who has the app. Secrets
   live only in the backend (CLAUDE.md §22, §24, §51).

## Backend — `backend/.env`

Validated by `src/config/env.schema.ts` (zod). Copy `.env.example` to start.

| Variable | Required | Notes |
| --- | --- | --- |
| `APP_ENV` | no | `local` \| `dev` \| `staging` \| `production` |
| `PORT` | no | Defaults to 3000 |
| `DATABASE_URL` | **yes** | PostgreSQL connection string |
| `JWT_SECRET` | **yes** | **SERVER-ONLY.** Minimum 32 characters |
| `MYANMYANPAY_WEBHOOK_SECRET` | no | **SERVER-ONLY.** Required wherever payments are enabled |
| `CORS_ORIGINS` | no | Comma-separated origin list |

The Prisma CLI reads `DATABASE_URL` through `prisma.config.ts`. Prisma 7 no
longer accepts `url` in the schema's datasource block.

### Local PostgreSQL

`backend/docker-compose.yml` provisions a `postgres:16` container matching
`.env.example`'s credentials:

```sh
cd backend
npm run db:up             # starts Postgres on :5432
npm run prisma:migrate    # applies migrations, generating the client
```

`npm run prisma:migrate:deploy` applies migrations without prompting or
generating a new one (used in CI and production). `npm run db:down` stops
the container.

## Admin and Website — `.env.local`

Only `NEXT_PUBLIC_*` values, validated by each app's `lib/env.ts`.

| Variable | Notes |
| --- | --- |
| `NEXT_PUBLIC_APP_ENV` | Environment name |
| `NEXT_PUBLIC_API_BASE_URL` | Backend root URL |

Never put a secret behind a `NEXT_PUBLIC_` prefix — it is compiled into the
browser bundle.

## Mobile

Configuration arrives through dart-defines, selected per build:

```sh
flutter run --dart-define-from-file=config/local.json
```

`mobile/config/local.json` is committed as the example; other environment
files are git-ignored. Values are readable from a shipped binary, so this
mechanism carries only the environment name, the API URL, and feature flags.

Native build *flavours* are deliberately deferred — see
[ADR-0005](adr/0005-environment-and-configuration.md).

## Feature flags

Defined in `mobile/lib/core/config/feature_flags.dart`, all defaulting to off
(CLAUDE.md §48): `ENABLE_AI_ASSISTANT`, `ENABLE_CHORD_RECOGNITION`,
`ENABLE_BACKING_TRACKS`, `ENABLE_RECORDING`, `ENABLE_COMMUNITY`.

## Ports in local development

| Service | Port |
| --- | --- |
| Backend | 3000 |
| Admin | 3001 |
| Website | 3002 |
