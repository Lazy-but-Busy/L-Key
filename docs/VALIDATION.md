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

### The tuner

Two bodies of assertions, because Phase 05 is half arithmetic and half a state
machine, and neither can be checked by looking at it.

- The FFT against a naive DFT written out longhand, to 1e-9 — which is what
  earns the right not to depend on one (docs/adr/0012). Plus impulse, single
  bin, round trip and Parseval.
- The frame assembler's overlap and timestamps, and the two bugs that work on
  one device and fail on another: a chunk ending between a sample's two bytes,
  and a platform buffer that does not start on an even one.
- **Every semitone from A0 to E6**, on sine, sawtooth and square: within a cent
  of the truth on a pure tone, two on a rich one, and never on the wrong
  octave. Then every open string of all fourteen tunings.
- The cases that make a time-domain method worth its cost: a tone whose
  fundamental has been removed entirely, and one where it sits twenty decibels
  under the second harmonic. A spectral tuner reads both an octave high.
- Noise at 40, 30, 20 and 10 dB with tightening budgets, and at 6 dB **no
  accuracy claim at all** — only that the reading arrives carrying its own
  doubt (CLAUDE.md §16).
- Stiffness, decay, vibrato, a constant offset, clipping, silence, white noise,
  and a frequency above the instrument's range.
- That two constants are load-bearing rather than decorative: loosening the
  peak threshold makes the octave error appear, and turning off the refinement
  measurably worsens the worst case at the top of the range.
- Two limits asserted as failures, so they stay known properties: the harmonic
  ratio cannot resolve an octave, and an octave double-stop cannot be detected
  as two notes by any method that only sees which frequencies are present.
- Every string of every tuning read against its target, spelled the way the
  tuning writes it — half-step-down reads E♭2 and never D♯2 — and a locked
  string that stays locked at 2400 cents while still naming what is sounding.
- The state machine driven entirely by injected timestamps: silence hysteresis,
  confidence hysteresis, a single octave slip that never reaches the screen,
  the settle timing to the frame, the lock buzzing exactly once in a hundred
  in-tune windows, and the guard that stops the target flapping between two
  strings of an eight-string neck.
- The four states on the screen, the three permission outcomes with their three
  different next steps, and that the in-tune state is spelled out in words as
  well as shown in orange (DESIGN.md §42).
- That disposing the tuner releases the microphone, asserted rather than
  trusted (CLAUDE.md §50).
- That nothing above the seam names a DSP class, nothing in `core/audio/`,
  `core/permissions/` or `tuner/domain/` imports Flutter or a subscription
  tier, no clock appears anywhere the state machine can reach, and each of the
  two platform plugins is imported by exactly one file.

### The chord screens

- The four states: skeleton, list, empty search, and a failure showing
  localised copy with no exception text.
- The diagram's semantics reading out every string, its barre and its base
  fret.
- A Premium-labelled chord opening exactly like a free one, because the label
  authorizes nothing.
- The play control disabled with its reason visible.

## Things `verify` does not do yet

- **Audio is not verified by `verify`, and cannot be.** Everything above proves
  the tuner's algorithm against signals generated in the test. It proves
  nothing about a real microphone: not the granted sample rate, not a phone's
  response below 100 Hz, not what the operating system does to the signal, not
  interruptions, latency, battery or accuracy on an actual guitar.
  `mobile/CLAUDE.md §15` says simulator-only testing is not sufficient for
  audio, and it is right. See `docs/DEVICE-TESTING.md`, which has not been run.
- No database runs locally, so Prisma migrations are not applied. Schema
  correctness is checked with `cd backend && npm run prisma:validate`.
- `next build` is not in `verify` — it is slow and needs no network-free
  guarantee at this stage. Run it before shipping a web change.
- No integration or end-to-end tests. The flow in README.md "Integration
  Tests" arrives with the features it exercises.
