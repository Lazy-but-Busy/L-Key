# 0009 — Spelled notes in `core/music`, not integers in a feature

**Date:** 2026-08-29 · **Status:** Accepted

## Context

Phase 03 needed the first domain layer in the repository. Nothing musical
existed anywhere: no note, no interval, no tuning, and the only tuning table in
the tree was a private const inside the tuner widget.

Two questions had to be answered before a single chord could be spelled. Where
do the primitives live, and what is a note?

`CLAUDE.md §10` and `docs/ARCHITECTURE.md` say music logic contains no Flutter
and is testable without a widget tree. Neither says where it goes, and neither
says how a note is modelled — which turns out to decide what the chord engine
can and cannot express.

## Decision

Shared primitives live in `mobile/lib/core/music/`: `Note`, `Interval`,
`Pitch`, `Tuning`. A note is a **letter plus an accidental**, never a number.

## Why

**`core/` rather than `features/chords/domain/`.** Chords, scales, the
fretboard, the tuner, the capo assistant and the song transposer all need the
same four types. Putting them under `chords` would make `scales` import from
`chords`, which is a dependency between sibling features and the beginning of a
tangle. `core/audio/PitchDetector` already set the precedent for a Flutter-free
seam in `core/`.

**Spelled notes rather than pitch classes.** This is the decision the rest of
the engine rests on. C♯ and D♭ are the same sound and different chords: C♯
major is C♯ E♯ G♯, D♭ major is D♭ F A♭. Reduce either to "pitch class 1" and
the chord can still be *played* but can no longer be *written*, and every
enharmonic test over it is vacuous — the assertions all pass because there is
nothing left to get wrong.

Intervals carry a diatonic number as well as a quality for the same reason. A
diminished seventh and a major sixth both span nine semitones. Only the seventh
lands on the seventh letter, which is the difference between spelling E♭dim7 as
E♭ G♭ B♭♭ D♭♭ and spelling it as four unrelated letters.

Double accidentals follow directly: a diminished seventh chord cannot be
written without them.

`Pitch` derives its MIDI number from the letter rather than the wrapped pitch
class, so B♯3 sits at 60 beside C4 instead of jumping an octave.

**`package:meta` was added.** `@immutable` is what stops
`avoid_equals_and_hash_code_on_mutable_classes` firing on every value type, and
the usual way to get it — `package:flutter/foundation.dart` — is exactly the
import the domain layer may not have. `meta` is Dart-team maintained, is
annotations only with no runtime code, was already present transitively, and
adds nothing to the binary (CLAUDE.md §42).

## Rejected

**Integer pitch classes throughout.** Simpler arithmetic, smaller code, and
genuinely enough to draw a fretboard. Rejected because the product's whole
claim is that the musical information is exact (DESIGN.md §3), and a chord
library that cannot tell C♯ major from D♭ major is not exact. It would also
have to be undone the moment notation or a stave appeared.

**Primitives inside `features/chords/domain/`.** Fewer directories today, one
feature importing another tomorrow.

**A `PitchClass` value type.** Planned, then dropped: it would have wrapped a
single integer and added a hop to every call site without preventing a single
mistake. `CLAUDE.md §7` calls that a meaningless abstraction, and `Note` already
exposes `pitchClass`.

## Consequences

- Transposition comes in two flavours and they are not interchangeable.
  `transposeBy(Interval)` spells a chord's own tones and keeps the letter the
  interval names. `transposeChromatically(semitones)` has no diatonic anchor,
  so it picks a spelling and takes a `preferFlats` flag — that is the one the
  capo assistant and the song transposer will use.
- `Tuning` indexes strings **lowest-sounding first**, the opposite of the
  guitarist's "sixth string". It is stated in the doc comment because getting
  it backwards silently mirrors every diagram rather than failing.
- Parsers return null instead of throwing. Chord symbols arrive from song
  content and from a search box, and `CLAUDE.md §37` wants a handled outcome.
- A transposition needing a triple accidental throws. No chord in the catalogue
  produces one; if a future quality does, it fails loudly.
