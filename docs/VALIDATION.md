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

### The scale and fretboard engines

The second body of data-checking assertions, for the same reason as the first:
much of Phase 04 is arithmetic and the rest is hand-written fret data.

- Eighteen scale formulas: each ascends, starts on the root, names no pitch
  class twice, and each of the seven modes is the major scale rotated.
- Spelling over all seventeen roots — a seven-note scale uses each of the seven
  letters exactly once; Lydian's fourth is a ♯4 and not a ♭5; F♯ major keeps
  E♯ and G♭ major keeps C♭; the diminished scale spells its B♭♭.
- The case a spelled model has to admit: A♯ whole tone needs an F triple sharp,
  so `isSpellable` is false, the catalogue does not offer that root, and B♭
  whole tone is what the picker shows.
- Fourteen tunings: string counts, open pitches, ordering lowest-first, drop D
  lowering one string, the extended-range necks extending the standard one
  downward, and a bass sounding an octave below the guitar strings it shares.
- Fretboard positions across every catalogue tuning and every scale: every
  position sounds a note the selection contains, spelled by the selection
  rather than by the tuning, ordered by string then fret, inside the range.
- **A minor pentatonic box 1 is frets 5–8, note for note against the marker
  data in the design system's ScalesScreen** — and the five boxes come out
  5–8, 7–10, 9–13, 12–15, 14–17, with box 3 five frets wide because the B
  string reaches from 10 to 13.
- Every box on every scale, root and tuning carries at least two notes on every
  string, which is the property that defines a box.
- **Every CAGED placement over all twelve roots against
  `CagedEngine.problemWith`**: no foreign notes, no missing chord tone, four
  frets, and every note re-read through the tuning rather than trusted. The
  five shapes tile the neck in a rotation of C-A-G-E-D with no gaps, and the E
  and A shapes are asserted equal to the corresponding entries in the chord
  voicing library so the two copies cannot drift.
- That the guard has teeth: move one fret of the open C shape and it is
  rejected.
- That nothing under `core/music/`, `chords/domain/` or `fretboard/domain/`
  imports Flutter or a subscription tier, and that no feature `domain/` imports
  a sibling feature.

### The fretboard and scale screens

- The four states on both, with the failure showing localised copy and no
  exception text.
- Changing the root, the tuning, the scale, the labels, the position and the
  fret window each change what the neck actually shows — asserted against the
  neck's accessible description, which is the same information as the dots.
- A seven-string tuning grows the neck by a string and removes the CAGED
  shapes, with the reason on screen.
- An arpeggio draws exactly the chord's four degrees and not the scale's fifth.
- A Premium-labelled scale selects exactly like a free one, because the label
  authorizes nothing.
- The scales screen shows a computed formula and computed notes, and no
  playback control.

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
