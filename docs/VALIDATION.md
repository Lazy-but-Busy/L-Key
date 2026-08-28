# Validation

One entry point:

```sh
npm run verify
```

It runs everything below in order and is exactly what CI runs, so a green
local run means a green pipeline.

| Command | What it catches |
| --- | --- |
| `npm run tokens:check` | Generated Dart/CSS/TS drifting from `tokens.json` |
| `npm run lint` | ESLint across backend, admin, website |
| `npm run typecheck` | `tsc --noEmit` across all three |
| `npm run test` | Jest (backend) and the token drift check |
| `npm run mobile:format` | Unformatted Dart |
| `npm run mobile:analyze` | Dart static analysis under `very_good_analysis` |
| `npm run mobile:test` | Flutter unit and widget tests |

## The contrast gate

`npm run tokens` fails the build when any semantic colour pair drops below its
WCAG threshold. It is not advisory.

This exists because the design-system review found real failures shipped in
the UI kits — tertiary text at 3.37:1 and a stat-card note at 2.05:1, below
even the large-text floor. The gate caught two more while Phase 01 was being
written: Guitar Orange is only 2.92:1 on the `#F0F0F0` ground, and the light
danger red is 2.92:1 on the dark surface. Both were fixed at the token layer
rather than waived.

To see the report:

```sh
npm run tokens
```

## What the Flutter tests cover

- Token drift, and that every type style carries the Myanmar fallback.
- Contrast for every text role in both themes, asserted in Dart as well as in
  the generator — the same rule enforced on both sides of the pipeline.
- Light and dark `ThemeData` resolving with no missing slots.
- ARB key parity between English and Myanmar, plus a check that the Myanmar
  file actually contains Burmese script rather than a copied English string.
- Feature flags defaulting to off.
- The foundation screen rendering in both themes, Burmese resolving through a
  Myanmar-capable font, and the press target meeting the 44px minimum.

## Things `verify` does not do yet

- No database runs locally, so Prisma migrations are not applied. Schema
  correctness is checked with `cd backend && npm run prisma:validate`.
- `next build` is not in `verify` — it is slow and needs no network-free
  guarantee at this stage. Run it before shipping a web change.
- No integration or end-to-end tests. The flow in README.md "Integration
  Tests" arrives with the features it exercises.
