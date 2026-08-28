# 0006 — Bundle Noto Sans Myanmar as the Burmese fallback

**Date:** 2026-08-28 · **Status:** Accepted

## Context

L Key is Myanmar-first. `PRD.md` §41 and `CLAUDE.md` §33 require Myanmar
throughout; `DESIGN.md` §36 insists Myanmar text receive equal design
consideration rather than being a translation pass.

DESIGN.md §8 specifies three faces: Space Grotesk, Hanken Grotesk and
JetBrains Mono. **None contains Burmese glyphs.** The design system's own
README already records that "Myanmar script is not rendered anywhere in this
system" and that no Myanmar-capable font was supplied.

Without a fallback, every Myanmar string in the product renders as tofu boxes.

## Decision

Bundle Noto Sans Myanmar (Regular and Bold) and append it to
`fontFamilyFallback` on every generated text style. The web tokens append it
to each family stack in CSS.

## Why bundled rather than system

Relying on the platform font would make Burmese rendering vary by device and
OS version, and would render nothing at all where the face is absent. For a
Myanmar-first product this is a correctness matter, not a polish one.

## Enforcement

Two tests, because a fallback that quietly disappears is invisible:

1. Every style in `LkTypeScale` includes the Myanmar family in its fallback.
2. The foundation screen renders Burmese text and asserts the resolved style
   offers a Myanmar-capable face.

## Consequences

- ~400KB added to the app bundle. Acceptable: the alternative is unreadable
  text for the primary market.
- Burmese line-height and wrapping still need testing on real devices with
  real copy. The Myanmar strings currently in `app_my.arb` are a starting
  translation and should be reviewed by a native speaker.
- The brand faces remain primary for Latin text, so English is unaffected.
