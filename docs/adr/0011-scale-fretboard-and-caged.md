# 0011 — The neck is arithmetic; the five shapes are data with a guard

**Date:** 2026-08-29 · **Status:** Accepted

## Context

Phase 03 left `Note`, `Interval`, `Pitch` and `Tuning` in `core/music/` and a
chord engine on top of them. Phase 04 had to add the fretboard, scales, scale
patterns, modes, arpeggios and CAGED across six-, seven-, eight-string and bass
necks (PRD.md §13–§15).

Three questions decided the shape of it. Where does a scale live when both the
scales screen and the fretboard screen need it? How much of a "position" is
data and how much is derived? And where do arpeggios get their chord formulas,
given ADR-0009 forbids one feature importing another's domain?

## Decision

- **`core/music/scale.dart` and `core/music/fretboard.dart`.** Eighteen scale
  formulas, and an engine that turns a tuning plus a root plus a degree list
  into positions. No stored note positions anywhere.
- **`ChordQuality` moved from `features/chords/domain/` to `core/music/`.**
- **Boxes and three-notes-per-string patterns are searched, not tabulated**
  (`features/fretboard/domain/scale_pattern.dart`).
- **CAGED is five hand-written open shapes plus `CagedEngine.problemWith`**
  (`features/fretboard/domain/caged.dart`).
- **`shared/widgets/lk_fretboard.dart`** renders; it computes nothing.

## Why

**The engines are in `core/music/` for the reason ADR-0009 gave.** The scales
screen draws a fretboard and the fretboard screen selects a scale. If `Scale`
lived under `features/scales/` the fretboard would import it, and if
`FretboardEngine` lived under `features/fretboard/` the scales screen would
import that — a cycle, and exactly the tangle ADR-0009 exists to prevent.

**`ChordQuality` moved for the same reason, and it is the change that needed
justifying.** An arpeggio is a chord played one note at a time, and a CAGED
shape is a major triad anchored to a root. Both need chord formulas. There were
three ways to get them: import from `features/chords/domain` (a sibling edge
ADR-0009 rules out), write a second table of arpeggio formulas (a duplicate
model, CLAUDE.md §4), or move the one file that both features need into the
place ADR-0009 already designated for shared musical types. The move is
mechanical — an import path in six library files and five tests, no behaviour
change — and it is what the architecture already said to do.

**The engine takes a root and a degree list, not a `Scale` or a `Chord`.**
`Scale.intervals` and `ChordQuality.intervals` both fit it, so a scale, a mode,
an arpeggio and a CAGED shape are one code path. `FretboardSelection` is the
thin sealed type that names the four for the picker; the engine never sees it.

**Positions are derived, and the derivation is the definition.** A pentatonic
"box" is not a picture to be typed in; it is a fret window in which every
string carries at least two of the scale's notes. Search the neck for windows
with that property and the five shapes every guitarist is taught come back —
frets 5–8, 7–10, 9–13, 12–15 and 14–17 for A minor pentatonic — for any root,
any scale and any tuning, including the seven-string, eight-string and bass
necks no hand-typed table would have covered.

Box 3 is why this matters rather than being merely tidy. It spans five frets,
not four: the B string reaches from 10 to 13 and no four-fret window holds it.
A fixed window length looked right, passed a casual eye, and silently reported
the wrong shape. Searching for the property found it.

**Spelled degrees, again.** Lydian's fourth is a ♯4 and Locrian's fifth is a
♭5 and both span six semitones. F Lydian is F G A B C D E; spell that B as a
C♭ and the scale has two Cs and no B. This is ADR-0009's argument applied to
scales, and it is what `Scale.notes` asserts in the suite: a seven-note scale
uses each of the seven letters exactly once.

It has one honest consequence. A♯ whole tone needs an F triple sharp for its
♯6 and cannot be written. A musician writes B♭ whole tone instead, so
`Scale.isSpellable` says so, `Note.tryTransposeBy` answers without throwing,
and `FretboardCatalog.rootsFor` offers only roots the scale can be written on.
Nothing in the interface can reach the unspellable case, and `Scale.notes`
still throws loudly if code does.

**CAGED is data because a shape is a fingering.** The five open chords are not
derivable from anything — they are what guitarists' hands do — so they are
written down, and then slid: for root R, shape S sits at the fret that carries
S's own letter to R. That single line produces the C-A-G-E-D order, its
rotation for every other root, and the overlap between consecutive shapes.

Hand-typed fret data has typos a compiler cannot see, so `problemWith` runs
over every position the engine returns and over all twelve roots in the suite:
no foreign notes, no missing chord tone, no more than four frets, and every
note checked by reading its string and fret back through the tuning rather than
by trusting the note the position carries. The E and A shapes are asserted
equal to the corresponding entries in `voicing_library.dart`, because the same
two shapes are now written down in two files for two purposes and must not
drift.

CAGED returns nothing outside six-string standard tuning. It is a claim about
that instrument and it is not true of a bass or a seven-string; the screen says
so rather than inventing a sixth system (CLAUDE.md §47).

## The design system is extended twice, and once deliberately narrowed

`components/music/Fretboard.jsx` positions a marker at
`fret * fretWidth - fretWidth / 2`, so fret 0 has nowhere to go. A scale in
open position is most of the scale, so **an open-string column** was added left
of the nut. **Every marker prints its label**, root included — DESIGN.md §25
puts the root in Guitar Orange and DESIGN.md §42 forbids meaning by colour
alone. Geometry is otherwise the design system's, and the measurements are
tokens (`fretboardFretWidth`, `fretboardMarkerSize`, and the rest), not
literals.

The narrowing: the neck's accessible description follows the label choice. Show
degrees in the picture and the screen reader hears degrees. Leaving it on note
names would hand a screen-reader user a different fretboard.

## One cross-feature edge, at the presentation layer

`features/scales/presentation` imports providers from
`features/fretboard/presentation`. A scale screen *is* a fretboard view of one
scale, the two share their state so that choosing A Dorian on one shows A
Dorian on the other, and one owner for the catalogue is better than two that
can disagree. The edge is presentation-only, one-directional, and asserted
absent from `domain/` by the layer test.

## Rejected

**A stored pattern dataset.** Five boxes times eighteen scales times seventeen
roots times fourteen tunings is not a table anyone types, and every entry would
be a place to be silently wrong. The searched definition is shorter than the
data would have been and it explains itself.

**Integer pitch classes on the neck.** Enough to draw dots. Not enough to write
the ♯4 that makes Lydian Lydian, and every enharmonic assertion over it would
be vacuous. Rejected for the reasons ADR-0009 already gave.

**Deriving CAGED from `voicing_library.dart` alone.** The movable-shape table
has the E and A shapes; C, G and D are not barre shapes and are not in it.
Half-deriving and half-typing would have been worse than typing five and
checking all five.

**A `NoteMapSelection` alongside the scale and arpeggio selections.** The note
map has no root-and-degree set to select — it is every note there is — so it is
a null selection and `FretboardEngine.allNotes`, not a third subclass that
exists to represent absence.

## Consequences

- Adding a scale is one enum entry plus one formula and two ARB strings. Adding
  a tuning is a `Pitch` list. Neither needs a position, a box or a pattern.
- `FretRange` validates rather than defaulting: a negative or inverted range
  throws instead of quietly drawing an empty neck.
- The scales screen no longer has a "next phase" note, and it has no play
  button either — there is no audio engine, and CLAUDE.md §47 prefers the
  sentence to a control that does nothing.
- `Interval` gained five named degrees (`#1`, `#2`, `#4`, `b6`, `#6`). They are
  constants over the existing constructor, not new arithmetic.
- The layer test now asserts that no feature `domain/` imports a sibling
  feature, so the rule this ADR turns on cannot erode quietly.
