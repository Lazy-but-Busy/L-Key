# `fretboard` feature

The interactive fretboard across 6/7/8-string and bass. The engine calculates
strings, frets, tuning, notes and intervals; the widget only renders the result
(CLAUDE.md §13).

**Specification:** PRD.md §13, §15 · DESIGN.md §25 ·
[ADR-0011](../../../../docs/adr/0011-scale-fretboard-and-caged.md)

## Structure

```
fretboard/
├── data/           the tuning, scale and arpeggio catalogues with tier labels
├── domain/         selections, scale patterns, CAGED, the repository interface
└── presentation/   the screen, its Riverpod providers, the neck wrapper
```

The engines it builds on are in `core/music/` — `Scale`, `FretboardEngine`,
`ChordQuality`, and the four primitives from Phase 03 — because the scales
screen needs them too and a feature must not import a sibling's domain
(ADR-0009, ADR-0011). `domain/` imports no Flutter; `@immutable` comes from
`package:meta`.

## String numbering

The neck's left column carries the guitarist's string number beside the note —
`6 E` — counted from the highest-sounding string down, which is the opposite
of the engine's low-first indexing. The spoken description already counted
that way; the picture now agrees with it (DESIGN.md §25).

## What exists

- **The neck, calculated.** No table of note positions anywhere. A tuning knows
  what each open string sounds and a fret adds a semitone, so a seven-string,
  an eight-string and a bass are the same code path as a guitar.
- **Fourteen tunings** (`Tuning.catalogue`): standard, drop D/C/B, half and
  full step down, DADGAD, open G/D/E, 7- and 8-string, and four- and
  five-string bass.
- **Eighteen scales** (`ScaleType`): PRD.md §14's five free and eleven Premium,
  plus Ionian and Aeolian so the modes list is all seven.
- **Arpeggios** from `ChordQuality`, not from a second formula table.
- **Boxes and three-notes-per-string patterns**, searched rather than stored: a
  box is a fret window with at least two of the scale's notes on every string,
  and that definition reproduces the five pentatonic shapes exactly.
- **CAGED**, five shapes slid to any root, every placement checked by
  `CagedEngine.problemWith` before it leaves the engine.
- **The screen**: tuning, root, scale/mode/arpeggio, position, note-vs-interval
  labels and a fret window, with the neck read out string by string for a
  screen reader.

## What does not exist

- **No audio.** There is no engine to play a scale with, so the screen offers
  no play control and says so (CLAUDE.md §47).
- **No entitlement.** `FeatureTier` labels a catalogue entry and grants
  nothing. Every tuning, scale and arpeggio selects. Enforcement is
  server-authoritative (CLAUDE.md §23, §51).
- **No CAGED outside standard tuning.** It is a claim about a six-string guitar
  in standard tuning; in any other tuning the shapes are absent and the screen
  explains why rather than inventing them.
- **No custom tunings.** `Tuning` takes any pitch list; nothing in the
  interface builds one yet (PRD.md §10.2).
- **No scale trainer** (PRD.md §66) and no chord-on-the-neck selection.
