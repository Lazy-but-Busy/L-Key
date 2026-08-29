# 0013 — The tuner's state machine has no clock, and every threshold is one file

**Date:** 2026-08-29 · **Status:** Accepted

## Context

ADR-0012 settles how a frequency is found. This is about everything after it:
what the tuner does with a stream of them, and what it says when the answer is
not a note.

`PRD.md §10` requires the engine to expose `DetectedNote`, `Frequency`,
`TargetFrequency`, `Cents`, `Confidence` and `IsInTune`, and says the interface
must not implement pitch logic itself. `CLAUDE.md §16` forbids telling a player
something is right when the algorithm is unsure. `§47` forbids faking. `§50`
requires the microphone released on every path out. `DESIGN.md §22` gives the
needle its directions and §40 asks for a haptic on tuning lock.

The hard part is not the arithmetic. It is that a microphone hears a room, and
a room contains silence, talking, a television, a hand knocking the body of the
guitar, one string decaying while another still rings, and a note that is
genuinely moving because a peg is turning.

## Decision

- **`features/tuner/domain/tuning_engine.dart`** turns a frequency and a target
  into a `TunerReading` carrying PRD.md §10's list.
- **`features/tuner/domain/tuning_session.dart`** is the state machine. Every
  method is `(state, input) -> state`; **there is no clock in it**.
- **`features/tuner/domain/tuner_thresholds.dart`** holds every number the
  behaviour turns on, in one object.
- **`features/tuner/domain/tuner_pipeline.dart`** wires the microphone, the
  permission and the session together and publishes states.
- Nine statuses: idle, permissionRequired, permissionBlocked, starting,
  listening, noisy, imperfectInput, tracking, failed.
- Listening starts on an explicit press, not on arrival.

## Why

**Time arrives as data, not from a clock.** Every timestamp comes from
`AnalysisFrame.timestamp`, which the assembler counts from samples. A test that
feeds forty-three frames advances the session by exactly one second, on every
machine and every run, and the settle timing, the silence hold and the string
guard are all directly assertable. A layer test asserts that `DateTime.now()`
appears nowhere the session can reach.

**Flat, sharp and in tune are not statuses.** They are read off
`TunerReading.cents` against the tolerance. PRD.md §10 asks for `IsInTune` as a
field, and putting the same fact in two places is how the two come to disagree.

**Two thresholds wherever a value crosses a line.** Eight decibels of
hysteresis between the silence floor and the signal onset, so a decaying note
does not flicker between listening and tracking several times a second. A lower
confidence to keep a reading than to start one, so a signal hovering at one
threshold does not switch the whole screen on and off. A release band twice the
tolerance, so a needle resting on the boundary does not flash the lock.

**A median of five, not a mean.** A mean smears a single octave slip across
five frames and visibly moves the needle; a median ignores it completely. Five
frames is about a tenth of a second of lag, which is the last defence in the
chain and the only one a player actually experiences.

**"More than one string is ringing" is measured, not guessed.** Two conditions,
both required: more than a third of the peak energy is unexplained by any
harmonic of the detected pitch, *and* the leftovers line up into a series of
their own. One loud stray peak is a room resonance or a buzz; two in a series
is a note. And a period has to have been found first — claiming two notes when
none could be identified would be inventing the first one (§47).

**The claim it makes is narrower than "there are two notes", and the limit is
tested.** An octave double-stop is invisible: E2 with E3 is the same set of
frequencies as one E2 with a strong second harmonic, and no method that only
looks at which frequencies are present can separate them. A fifth is nearly as
bad. There is a test asserting the heuristic *fails* on an octave, so it stays
a known property rather than arriving later as a bug report.

**No level gate on confidence.** There was one, and the tests removed it.
Whether anything is happening is already decided by the silence thresholds, and
how loudly it happens says nothing about whether it is a note — a quietly
plucked string is exactly as measurable as a hard one. The gate turned out to
fire only in a sliver a third of a decibel wide, where it did nothing but
punish a light touch. Spectral flatness does the job loudness was being asked
to do, and does it correctly: it is what separates someone talking from someone
playing, which no level meter can.

**Listening is a press.** The microphone is the largest battery cost in the
product (§50, PRD.md §63) and a player should be able to see when it is open.
It also puts the permission prompt at a moment the player has just asked for
something, which is when people grant them.

**The haptic fires on an edge, once.** DESIGN.md §40 asks for a haptic on
tuning lock and warns against overusing them; at forty-three windows a second
the naive version buzzes continuously. The session exposes the false-to-true
edge into settled and the controller fires on it, with a two-second re-arm.
The session stays pure and never touches the platform, which is also what lets
a test count the buzzes.

**In tune is not finished.** A needle sweeping through centre while a peg turns
is in tune for an instant. Six hundred milliseconds of holding it is what makes
`isSettled` true, and that is what the haptic and the orange lock respond to.

## The numbers, and how much to trust them

| Constant | Value | Confidence |
| --- | --- | --- |
| `inTuneToleranceCents` | 3 | High — the design system's own default, and inside what a player can hear. |
| `settleDuration` | 600 ms | Medium — feel, not measurement. |
| `medianWindow` | 5 | Medium — about 116 ms of lag at the shipped hop. |
| `enterTracking` / `leaveTracking` | 0.75 / 0.5 | **Low.** The most likely constant to be wrong on a real device. |
| `silenceFloorDbfs` / `signalOnsetDbfs` | −50 / −42 | **Low.** dBFS is not comparable across devices, because input gain is not. |
| `targetSwitchGuard` | 300 ms | Medium — real on a seven- or eight-string neck. |
| polyphony thresholds | 0.35, 2 partials, ±35 cents | Medium — the tolerance absorbs a steel string's stiffness by the eighth partial. |

They live in one object so that a device session moves them by editing one
file, and `FeatureFlags.tunerDiagnostics` exists so that session produces
numbers rather than impressions. See `docs/DEVICE-TESTING.md`.

## Rejected

**Flat, sharp, in tune and settled as statuses.** See above.

**A timeout on a manually chosen string.** Tuning an A up to an E is a real
thing to do, and a target that silently reverts partway through is a surprise.
It stays until the player changes it.

**Auto-starting the microphone on arrival.** Faster to a first reading, and
worse on every other count.

**Snapping a reading to the selected string's octave.** Would make the needle
behave beautifully and would hide a genuinely octave-off string. §47.

## Consequences

- `PermissionFailure` gets its own copy in `failure_messages.dart` rather than
  folding into "Something went wrong." — telling a player a bug occurred when
  they declined a prompt is both untrue and useless.
- `LkErrorState` gains an optional `action`, because retrying is not always the
  way forward and for a permanently refused microphone it never is.
- The reference pitch is now editable, clamped to 415–445 on the way in as well
  as out. It was persisted and read-only from Phase 02, which made it a number
  a player could look at and not change.
- `tuningName` moved to `app/localization/music_names.dart`, since the tuner
  and the fretboard both need it and neither should import the other.
- **Nothing here has been verified on a device.** Every threshold above is an
  engineering estimate against typical behaviour. The tuner ships implemented
  and unverified, and no accuracy claim belongs anywhere in the product until
  `docs/DEVICE-TESTING.md` has been filled in.
