# 0004 — One token source, generated per platform

**Date:** 2026-08-28 · **Status:** Accepted

## Context

Design values must reach Flutter (Dart), admin and website (CSS/TS).
`DESIGN.md` §66 forbids scattering raw values; the risk is not the first
divergence but the silent one, months later.

## Decision

`packages/design-tokens/tokens.json` is the single source. `build.mjs` emits
`tokens.g.dart`, `dist/tokens.css` and `dist/tokens.ts`. Generated files are
committed. `npm run tokens:check` regenerates and diffs, failing CI on drift.

## Why generated rather than hand-authored

Hand-authoring per platform plus a comparison test was considered, and is
simpler. Rejected because the test can only compare what both sides define —
it cannot catch a token added to one platform and forgotten on another, which
is the failure that actually happens.

## Consequences

- Generated output is committed, so a fresh clone builds without Node.
- The generator runs `dart format` on its Dart output. Without this, the
  formatter and the drift check fight: the formatter rewrites the file and the
  drift check then reports it stale. Formatting at generation time makes the
  committed file the fixed point of both. (This was a real failure during
  Phase 01, not a hypothetical.)
- Generated Dart is **not** excluded from analysis. Excluding it initially hid
  a genuine compile error — a missing import — that only surfaced when the
  tests tried to build. Generated code is still code.
- The generator owns the contrast gate, so a token change cannot ship a
  regression to a semantic pair.
