# 0001 — NestJS + TypeScript for the backend

**Date:** 2026-08-28 · **Status:** Accepted

## Context

No specification names a backend language. `README.md` shows `cmd/`,
`internal/` and `migrations/` — a Go convention — but the same section says
"The exact backend structure may change as implementation progresses", so it
is descriptive rather than binding. `CLAUDE.md` §26 mandates only PostgreSQL.

Go is not installed on the development machine. Node 24 and npm 11 are.

## Decision

NestJS + TypeScript, with Prisma against PostgreSQL.

## Why

- **One language across three of four applications.** Admin and website are
  already TypeScript. A shared language means shared tooling, shared types,
  and one set of lint rules.
- **The structure matches the requirements.** Nest's modules, guards and
  validation pipes map directly onto CLAUDE.md §27 role-based authorization
  and §51 request validation, rather than being assembled by hand.
- **It can be validated today.** Go would have shipped an unverifiable
  skeleton; `npm run lint`, `typecheck` and `test` all run now.

## Rejected

**Go + chi/echo.** Matches README's implied layout and is a strong fit for a
payment webhook service. Rejected because the toolchain is absent, so Phase 01
could not validate anything it produced, and because a second language costs
more than the layout convention is worth this early.

**Deferring the choice.** Rejected because the environment strategy, CI and
the validation pipeline all need to know what the backend is.

## Consequences

- `README.md`'s repository-structure section now describes a layout the
  project does not use. It should be corrected.
- Prisma is pinned to `^7.10.0`. The `latest` tag currently points at
  `8.0.0-rc.12`, a release candidate.
- Prisma 7 removed `url` from the schema datasource block; the connection
  string lives in `backend/prisma.config.ts`.
- Resolved versions: NestJS 12, Prisma 7.10, TypeScript 5.7. TypeScript 7 was
  available but not adopted — Nest 12 has not been verified against it.
