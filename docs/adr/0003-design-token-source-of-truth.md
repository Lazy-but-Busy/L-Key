# 0003 — DESIGN.md is authoritative; the design system fills its silences

**Date:** 2026-08-28 · **Status:** Accepted

## Context

Two sources describe L Key's visual language and they disagree.

`DESIGN.md` states values in prose. The committed design system at
`.claude/skills/L_Key_Design_System/` carries 170 tokens transcribed from
Figma frames. `CLAUDE.md` §2 makes DESIGN.md a source of truth; §34 forbids
inventing a value when a token already exists.

## Decision

Where DESIGN.md states a value, it wins. Where DESIGN.md is silent, the value
comes from the committed design system. Nothing is invented.

## Deviations from the design system

| Concern | DESIGN.md | Design system | Phase 01 |
| --- | --- | --- | --- |
| Light background | `#F0F0F0` | `#F9F9F9` | **`#F0F0F0`** |
| H1 | 32 | 36 | **32** |
| Display | 36–48 | 48 | **48** |
| Display XL | 48–64 | 96 | **64** |

## Silences filled from the design system

DESIGN.md §41 requires motion be "short, functional, tactile, predictable" but
names no durations. It names no component dimensions at all. Both are required
token categories, so:

- 90ms / 140ms, `cubic-bezier(0.2, 0, 0, 1)`, 3px press displacement
- 44px tap target (also WCAG 2.5.5), 71px bottom nav, 76px top bar, 320px
  sidebar, 1232px content maximum

## Silences filled by necessity

DESIGN.md §38 and §56 require error and status states but name no colours, and
§6's dark palette has no status entries. Four values were added:

| Token | Value | Reason |
| --- | --- | --- |
| `danger` | `#BA1A1A` | From the design system |
| `success` | `#1E7A34` | Adjusted for AA on light surfaces |
| `dangerDark` | `#F87171` | `#BA1A1A` is 2.92:1 on `#111111` |
| `successDark` | `#3DD68C` | `#1E7A34` is 3.50:1 on `#111111` |

## The consequence nobody anticipated

Choosing DESIGN.md's darker `#F0F0F0` background makes **Guitar Orange
unusable as a boundary colour on the app ground**: it measures 2.92:1, below
even the 3:1 non-text minimum. On the design system's lighter `#F9F9F9` it was
3.16:1 and passed.

This was caught by the contrast gate, not by review. Two things follow:

1. `focusRing` is a distinct semantic role — black on light (18.43:1), orange
   on dark (6.31:1). Orange cannot carry focus on the light ground.
2. An orange fill never establishes its own boundary. It always carries a
   border or hard shadow. The design system already did this universally, so
   nothing visual changes — but it is now a stated rule rather than a habit,
   and it is consistent with DESIGN.md §42's ban on meaning by colour alone.

`grey400` (`#888888`) is retained in the ramp because DESIGN.md defines it, but
it is marked decorative-only: it fails AA as text on every L Key ground.

## Open

DESIGN.md §7 does not yet carry the rule that produced these fixes — that
Guitar Orange is a surface and marker colour on light grounds, never small
text. It should be added.
