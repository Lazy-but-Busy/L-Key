# `chords` feature

Chord library, diagrams and the chord trainer. The chord engine covers names,
notes, intervals, voicings, finger positions, string states and transposition
(CLAUDE.md §11).

**Specification:** PRD.md §11–12 · DESIGN.md §23–24 ·
[ADR-0010](../../../../docs/adr/0010-guitar-voicing-generation.md)

## Structure

```
chords/
├── data/           the catalogue, the tier label, the offline repository
├── domain/         qualities, chords, symbols, shapes, voicings, the engine
└── presentation/   browser, detail, diagram, Riverpod providers
```

`domain/` imports no Flutter — not even `foundation.dart`, which is why
`package:meta` supplies `@immutable`. The primitives it builds on (`Note`,
`Interval`, `Pitch`, `Tuning`) are in `core/music/`, because the scale,
fretboard and tuner engines need the same four types.

## What exists

- **Eighteen qualities.** PRD.md §11's fourteen, plus `dim7`, `m7b5`, `m6` and
  `7sus4` — guitar notation writes "dim" when it means dim7, and m7b5 is
  unavoidable in a minor key. A nineteenth is a one-entry change to the formula
  table.
- **Correct spelling.** C♯maj7 is C♯ E♯ G♯ B♯ and E♭dim7 is E♭ G♭ B♭♭ D♭♭,
  because notes are letters and accidentals rather than numbers (ADR-0009).
- **Voicings** for all seventeen roots across all eighteen qualities: 31 movable
  shapes, 29 curated open chords, 8 curated slash chords. None of it is
  trusted — `ChordEngine.problemWith` checks every voicing, and the suite runs
  it over the whole catalogue.
- **Transposition**, preserving quality and the slash relationship, ready for
  the capo assistant and the song transposer (PRD.md §21–22).
- **Search** across the symbol and the localised quality name, in English and
  Myanmar, with `♯`/`#` and `♭`/`b` folded together (CLAUDE.md §32).
- **The browser, the detail screen and the diagram**, including a barre bar and
  a base-fret label the design system does not draw, and a semantics node that
  reads the shape out string by string.

## What does not exist

- **No audio.** `ChordAudioPlayer` is an interface; the only implementation
  reports itself unavailable and the play control is disabled with the reason
  written underneath (CLAUDE.md §47).
- **No entitlement.** `FeatureTier` labels a catalogue entry and grants
  nothing. Every chord opens. Enforcement is server-authoritative and belongs
  to the entitlement system (CLAUDE.md §23, §51).
- **No chord trainer** (PRD.md §12) and no chord recognition (CLAUDE.md §16).
- **No custom tunings.** The engine takes a `Tuning` everywhere and defaults to
  standard; nothing in the interface offers another one yet.
- **`C/D` has no shape.** A slash chord with no curated voicing shows the empty
  state rather than an invented fingering.
