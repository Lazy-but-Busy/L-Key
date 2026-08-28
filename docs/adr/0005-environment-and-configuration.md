# 0005 — dart-defines and zod-validated environment

**Date:** 2026-08-28 · **Status:** Accepted

## Context

Four environments across four applications, with hard constraints:
`CLAUDE.md` §22 forbids secrets in Flutter, §24 forbids payment and signing
keys anywhere near a client, and §51 treats the mobile client as untrusted.

## Decision

**TypeScript apps** validate configuration with zod at boot. The backend
schema fails the process on a missing or malformed variable; the web apps
validate only `NEXT_PUBLIC_*` values.

**Flutter** uses `--dart-define-from-file=config/<env>.json`.

`.env.example` files are committed; real values are git-ignored.

## Why fail at boot

A missing variable that surfaces as a 500 three requests later costs far more
than one that stops the process with a readable message. Both schemas list
every problem at once rather than one per restart.

## Native flavours deferred

iOS schemes and Android product flavours are not configured. They add signing
and build plumbing that nothing needs until there is something to release, and
dart-defines carry everything Phase 01 requires. Revisit at first TestFlight
or Play Console upload.

## Consequences

- Dart-define values are readable from a shipped binary. This mechanism
  therefore carries only the environment name, the API URL, and feature flags
  — never a credential.
- `NEXT_PUBLIC_*` is likewise public by construction; `lib/env.ts` accepts
  nothing else, so a secret cannot be added by accident.
- All five feature flags from CLAUDE.md §48 default to off, asserted by test.
