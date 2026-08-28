# Contributing

## Before writing code

Read `CLAUDE.md`, `PRD.md` and `DESIGN.md`. They are the source of truth; when
a request conflicts with them, raise the conflict rather than quietly
diverging.

## Branches

```text
phase-NN-<topic>     phase work
feat/<area>-<thing>  a feature
fix/<area>-<thing>   a fix
```

## Commits

Conventional commits, scoped by area (CLAUDE.md §45):

```text
feat(tuner): add standard tuning engine
fix(tuner): release the microphone on background
chore(tokens): regenerate after spacing change
```

Keep commits focused. A commit mixing a token change, a new screen and a
dependency bump cannot be reviewed or reverted cleanly.

## Definition of done

A feature is not done because the UI exists (CLAUDE.md §55). Before opening a
pull request, confirm each of these has been *considered* — and say so where
one does not apply:

- UI, domain logic, persistence, API
- loading, success, empty and error states
- localisation (both `app_en.arb` and `app_my.arb`)
- accessibility: semantics, 44px targets, contrast, reduced motion
- tests
- offline behaviour
- analytics

## Design values

Never write a literal colour, size, radius, duration or spacing value in a
widget or component. Add it to `packages/design-tokens/tokens.json`, run
`npm run tokens`, and use the generated token. If the value does not belong in
the system, that is a signal the design needs a decision, not a local override.

## Adding a dependency

CLAUDE.md §42 applies. Before adding one, check the platform does not already
provide it, and check maintenance, licence, platform support and size. Record
anything non-obvious in an ADR.

Pin deliberately: `prisma@latest` currently resolves to a release candidate,
which is why the backend pins `^7.10.0`.

## Architecture decisions

Anything structural gets an ADR in `docs/adr/`. Number sequentially, keep it
short, and state what was rejected and why — the rejected options are usually
the useful part later.

## Before pushing

```sh
npm run verify
```
