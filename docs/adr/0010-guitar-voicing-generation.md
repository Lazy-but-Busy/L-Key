# 0010 — Movable shapes plus a curated open table, checked by an invariant

**Date:** 2026-08-29 · **Status:** Accepted

## Context

A chord's notes are arithmetic. Where a hand goes on a fretboard is not.

`CLAUDE.md §11` requires voicings, finger positions, string states and barre
information from the chord engine, and PRD.md §11 promises alternative voicings
and movable shapes. Seventeen roots and eighteen qualities is 306 chords, and
every one of them needs at least one fingering a person can actually hold.

There were three ways to get them, and the choice decides how much of the
library is data, how much is algorithm, and what can go wrong silently.

## Decision

A hybrid, and an invariant that checks all of it.

- **31 movable shapes.** A fingering expressed as fret offsets from a base
  fret, with the root on the sixth or fifth string. Slide it up the neck and it
  names a different chord at every fret, so one entry covers all twelve roots.
- **29 curated open-position voicings.** Written as absolute frets, because an
  open chord is not a transposition of anything — the open strings are what
  make it sound the way it does.
- **8 curated slash chords**, for the same reason.
- **`ChordEngine.problemWith`** is run over every voicing before it leaves the
  engine, and over the entire catalogue by the test suite.

## Why

Neither pure approach was good enough on its own, and the invariant is what
makes the hybrid safe.

Movable shapes are how guitarists actually think, and they guarantee coverage:
every quality has at least one family, so every root has at least one shape.
They also produce the barre for free — the shape declares it, rather than the
diagram guessing that three markers at one fret are one finger.

But movable shapes cannot express an open chord. The open C is x32010 and there
is no fret you can slide it to; the open strings are the voicing. Those had to
be written down.

Slash chords had to be written down too, and that was not obvious. Deriving one
— muting strings until the right note is lowest, or reaching for a fret outside
the shape — is easy to code and produces fingerings no one would teach.
`CLAUDE.md §47` would rather the library return nothing than invent something,
so an uncurated slash chord yields an empty state and says so.

**The invariant is the part that matters.** Hand-written fret data is data, and
data has typos that a compiler cannot see. `problemWith` rejects a voicing that
sounds a note outside its chord, leaves out a tone it needs, spans more than
four frets, asks for more than four fingers, carries a barre inconsistent with
its strings, or fails to put a named bass lowest. It earned its keep
immediately: it caught an open C7 written with a fifth that voicing does not
have, and two fingerings that crossed the player's hand over itself.

Two rules inside it are worth stating, because both look arbitrary and neither
is:

**The perfect fifth is omittable from a chord of four or more tones; an altered
fifth never is.** Six strings and four fingers cannot carry a five-note chord,
and the fifth is the tone the ear supplies for itself — the open C7 every chord
book prints is x32310, which has no G in it. Drop the ♭5 from a diminished
seventh, by contrast, and what is left is a minor sixth chord, not a dim7 with
a missing note.

**Fingers are counted as fingers, not as stopped strings.** One finger laid
across four strings is one finger, and it is not only the index that does it:
the A-shape sixth chord is an index finger plus a ring finger flat across four
strings. Counting strings would have rejected shapes a hand plays comfortably.

## The diagram extends the design system twice

`components/music/ChordDiagram.jsx` draws neither a barre nor a base fret.
Both were added, deliberately:

| Addition | Why |
| --- | --- |
| A bar across the barred strings | PRD.md §11 requires a barre indicator, and three separate markers at one fret describe a different chord to play |
| The fret number beside the grid | A movable shape without it is unreadable — 355433 and 8-10-10-9-8-8 draw identically |

Everything else follows DESIGN.md §24 and the design system geometry, and the
measurements are tokens (`chordNutHeight`, `chordMarkerSize`, and the rest), not
literals.

## Rejected

**A fully curated dataset.** Every voicing hand-written. The best musical
quality per shape and no algorithm to be wrong — but 306 chords times several
positions is thousands of numbers to type and verify, coverage is only as
complete as whoever was typing, and a gap is silent rather than loud.

**Generative fretboard search.** Enumerate every playable combination, keep the
ones whose pitch classes match, score by hand span and finger count, rank. Full
coverage, no data file at all, genuinely deterministic. Rejected because the
voicings are only as good as the scoring function, and a scoring function does
not know that x32010 is the chord a beginner should be shown first.

It was not wasted, though: a search of exactly this shape was used to *derive*
the movable shape table, and the shapes it produced were the classic ones. The
difference is that the search ran once, its output was reviewed, and what
shipped is a reviewed table rather than a function that re-decides at runtime.
Where the search preferred a clever fingering to the conventional one — a
three-finger F barre rather than the 1-3-4-2 every teacher uses — the
conventional fingering was written in by hand and re-checked.

## Consequences

- Five quality-and-family combinations have no playable shape inside a
  four-fret span: there is no A-shape ninth and no E-shape sus2. That is fine
  and asserted — the other family covers those qualities on every root.
- Movable shapes stop at the twelfth fret. Past it a shape simply repeats an
  octave higher and there is nothing new to show.
- Adding a quality is a formula-table entry plus, ideally, a shape. Without a
  shape the coverage test fails loudly rather than the chord quietly having
  none.
- `C/D` has no voicing and the screen says so. That is the honest answer, not a
  gap to be papered over.
