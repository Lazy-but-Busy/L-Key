# 0015 — The chord engine, run backwards, and what it refuses to name

**Date:** 2026-08-30 · **Status:** Accepted

## Context

The chord library answers "what does Cmaj7 look like?". A player with a shape
under their fingers and no name for it has the opposite question, and nothing
in the product answered it.

PRD.md does not describe a chord analyzer. §12's Chord Trainer is adjacent and
§67 puts *audio* chord recognition in V3; this is neither. It is arithmetic
over a shape the player has typed in, which is the same deterministic work the
chord engine already does in the other direction (CLAUDE.md §17).

## Decision

- **`features/chords/domain/chord_analyzer.dart`** takes a `ChordVoicing` and
  a `Tuning` and returns a `ChordAnalysis`: the pitches, the bass, the notes,
  the degrees, and a ranked list of `ChordCandidate`s.
- **Candidate roots are the seventeen `Note.spellings`**, not twelve pitch
  classes, and every quality is one of the eighteen in `core/music`.
- **A candidate must contain every note played.** No alteration, no added
  tone, no formula the library does not already have.
- **A candidate may omit only what `ChordQuality.omittableIntervals` allows.**
- **Root and bass are separate**, so `C/E` is a C chord whose lowest note is
  an E.
- The ranking is six integer terms with exhaustive tie-breakers.

## Why

**It is the same engine, not a second one.** `ChordVoicing.soundingPitches`,
`soundingPitchClasses` and `soundingNotes` already do the fretboard
arithmetic; `ChordQuality.intervals` already holds the formulas;
`ChordEngine.intervalsPerString` already labels the degrees. The analyzer adds
a search over roots and qualities and nothing else. A library that draws C
major one way and reads it back another is two engines wearing one name
(CLAUDE.md §4, §11).

There is a test for exactly that: every voicing `ChordEngine` draws — all
seventeen roots across all eighteen qualities — is fed back through the
analyzer, and the chord it was drawn for has to be in the answer.

**Spelled roots, because a spelling is information.** C♯ major and D♭ major
are the same three sounds and two different chords to read (ADR-0009). Both
are offered. Which one *leads* is decided by counting accidentals, double
accidentals counting twice, and that turns out to reproduce what a chord chart
actually prints: D♭ over C♯, E♭ over D♯, A♭ over G♯, B♭ over A♯. F♯ and G♭ are
the genuine coin flip — six of each — and the declaration order in
`Note.spellings` settles it. That is arbitrary, deterministic, and said out
loud in the test rather than dressed up as a musical judgement.

**Refusing is a feature.** A shape whose notes no supported formula accounts
for gets an empty list and a screen that says so. Inventing `C7♭9♯11` from a
formula table that has no such entry would be exactly the fake CLAUDE.md §47
forbids, and §36 of the brief rules out adding formulas just to give the
analyzer something to say. Two notes are the common case: `C E` matches
nothing today, and the test that asserts it is what will notice when
`C(no5)` arrives.

**One omission rule, not two.** "The perfect fifth is omittable from a chord
of four or more tones; an altered fifth never is" is already written down, in
`ChordQuality.omittableIntervals`, because ADR-0010 needed it to validate
voicings. The analyzer calls it rather than restating it. This is what makes
`A C E` come back as `Am` first and `C6` — a real reading, missing its fifth —
second, with the missing tone printed beside it.

**Root is not bass, and the analyzer would be wrong if it were.** The lowest
note of `x32010` with the A string muted is an E, and the chord is still C.
`Chord` already models this as a separate `bass` field rather than a quality
(§18 of the brief), so the analyzer fills that field and nothing else changes.

## The ranking, and what each term is for

| Term | Points | Why |
| --- | --- | --- |
| nothing omitted | +1000 | An exact reading always beats one with a hole in it |
| the root is sounding | +500 | A name whose root nobody is playing is a weaker claim |
| the bass is the root | +300 | Root position over an inversion, all else equal |
| simpler quality | `+200 − 10 × index` | `ChordQuality` is declared simplest-first, so its own order *is* the preference. No second table |
| each omitted tone | −150 | More than the quality term can recover, so an omission never wins on convenience |
| each accidental | −5 | Small: it only ever separates two otherwise identical readings |

Ties break on the quality's index, then the root's. The order is total, and a
test runs the same shape twice and compares.

`C E G` scores C major at 2000 and produces nothing else at all, which is
§16's requirement that a simple valid reading must never lose to an elaborate
one.

## Consequences

- **A symmetrical chord has several true names and shows them.** An augmented
  triad is three, a diminished seventh is four; the bass decides which leads
  and the rest stay in the list, capped at eight.
- **`ChordCandidate.omitted` exists from the first version** even though
  nothing prints `(no5)` yet. Adding that suffix is a copy change rather than
  an engine change (§19 of the brief).
- **`ChordCatalog.tunings` was added**, labelled exactly like the tuner's and
  the fretboard's, so the three screens do not disagree about which tunings
  are Premium. As everywhere, the label grants nothing.
- **The editor is a new widget, not a flag on `LkFretboard`.** That widget is
  driven by `List<FretPosition>`, and a `FretPosition` requires the degree it
  sounds — which does not exist until a chord has been named. Here the shape
  comes first and the name second, so the two want opposite inputs. The
  editor lives in the chords feature rather than `shared/` because it speaks
  `FrettedString`, which `shared/widgets` may not import (ADR-0009), and it
  reuses `LkFretboard`'s geometry tokens so the two read as one component.
- **No audio.** `ChordAudioPlayer` is still the interface with no
  implementation, so Play is disabled with the reason underneath, exactly as
  the chord detail screen already does.
- **No entitlement.** PRD.md does not name the analyzer, so it carries no
  tier and every part of it opens.

## Rejected

**Deriving a name for anything.** Allowing an unmatched note to become an
added tone or an alteration would name every shape, and most of the names
would be ones no musician writes.

**Twelve integer roots.** Half the search, and it cannot tell C♯ major from
D♭ major — the exact loss ADR-0009 exists to prevent.

**Scoring by "how common is this chord".** A frequency table would rank better
in a few cases and would be a set of opinions nobody could check.
`ChordQuality`'s declaration order is already simplest-first and is checkable
by reading one file.
