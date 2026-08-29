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
| | CI splits this: the Node job runs `tokens:check:web`, the Flutter job `tokens:check:dart` |
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
- Every screen rendering in light, dark and Burmese without throwing, and the
  shell restoring the right tab for a deep link — including a chord id.

### The chord engine

The largest body of assertions in the suite, because it is checking data as
much as code (CLAUDE.md §39).

- Notes, intervals, pitches and tunings: pitch classes, spelled transposition
  (`C` + minor third is `Eb`, never `D#`), double accidentals, parse and print
  round trips over all 35 spellings, MIDI numbers and A440 frequencies.
- Chord spelling for all eighteen qualities, and the cases that only a spelled
  model gets right: `C#maj7`, `Dbmaj7`, `Ebdim7`, `G#dim7`, `Cm7b5`.
- Chord symbols round-tripping across every catalogue entry, plus the
  spellings other people write — `CM7`, `CΔ7`, `C-7`, `C°7`, `Cø`, `C+`.
- **Every voicing of all 306 root-and-quality combinations**, checked against
  `ChordEngine.problemWith`: no foreign notes, no missing tones, four frets,
  four fingers, a consistent barre, and a named bass sounding lowest.
- The open chords PRD.md §11 names as free, asserted against the fret arrays
  every chord book prints, and the F barre's computed barre.
- Search folding accidentals and case, and matching a Myanmar query against an
  English-named chord.
- That the audio placeholder reports itself unavailable and never claims to
  have played (CLAUDE.md §47).
- That nothing under `core/music/` or `chords/domain/` imports Flutter or a
  subscription tier — the layer rule asserted rather than trusted.

### The chord screens

- The four states: skeleton, list, empty search, and a failure showing
  localised copy with no exception text.
- The diagram's semantics reading out every string, its barre and its base
  fret.
- A Premium-labelled chord opening exactly like a free one, because the label
  authorizes nothing.
- The play control disabled with its reason visible.

## Things `verify` does not do yet

- No database runs locally, so Prisma migrations are not applied. Schema
  correctness is checked with `cd backend && npm run prisma:validate`.
- `next build` is not in `verify` — it is slow and needs no network-free
  guarantee at this stage. Run it before shipping a web change.
- No integration or end-to-end tests. The flow in README.md "Integration
  Tests" arrives with the features it exercises.
