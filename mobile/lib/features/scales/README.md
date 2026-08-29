# `scales` feature

The scale screen: one scale, its formula, its notes and its shape on the neck
(DESIGN.md §26).

**Specification:** PRD.md §14 · DESIGN.md §25–26 ·
[ADR-0011](../../../../docs/adr/0011-scale-fretboard-and-caged.md)

## Structure

```
scales/
└── presentation/   the screen
```

There is no `domain/` or `data/` here on purpose. A scale is `Scale` and
`ScaleType` in `core/music/scale.dart`, because the fretboard needs the same
type; the catalogue and its tier labels belong to `features/fretboard/data/`,
because a scale screen is a fretboard view of one scale and one owner is better
than two that can disagree. Empty layer directories are the "meaningless
abstraction" CLAUDE.md §7 warns against.

This screen reads the fretboard feature's providers — the one cross-feature
edge in the codebase, presentation-only and one-directional, recorded in
ADR-0011. It is what makes choosing A Dorian here show A Dorian in the
fretboard tool.

## What exists

The scale name and box in the header, a scale picker, a root picker filtered to
the roots the scale can be written on, the computed formula and notes, a box
selector, and the neck. Nothing on the screen is a placeholder: the `1 b3 4 5
b7` and the `A` it used to print are now `Scale.formula` and `Scale.root`.

## What does not exist

No playback and no practice mode. PRD.md §14 asks for both; there is no audio
engine and no metronome yet, and CLAUDE.md §47 prefers a sentence saying so to
a control that does nothing.
