# Architecture

How L Key is put together, and which boundaries must not be crossed.

## Applications

| Path | Stack | Responsibility |
| --- | --- | --- |
| `mobile/` | Flutter + Riverpod | The product. iOS and Android. |
| `backend/` | NestJS + Prisma + PostgreSQL | Authoritative for auth, entitlements and payments. |
| `admin/` | Next.js | Operations and content management. Data-first. |
| `website/` | Next.js | Marketing and SEO. Acquisition. |
| `packages/design-tokens/` | JSON + generator | Every design value, for all three UIs. |

`mobile/` is outside the npm workspace — Flutter owns its own dependency graph.
The root `package.json` only shells out to Flutter for validation.

## The one-way flow

```text
UI  ->  State  ->  Use Case  ->  Domain Engine  ->  Result
```

Each arrow points one way. A domain engine never reaches back into state, and
state never reaches into a widget.

## Rules that are not negotiable

**Music logic contains no Flutter.** Chord, scale, fretboard, tuning,
transpose and capo engines are plain Dart (CLAUDE.md §10). This is what makes
them unit-testable without a widget tree, reusable from the backend, and
available offline.

The primitives every one of them needs — `Note`, `Interval`, `Pitch`, `Tuning`
— sit in `core/music/` beside `core/audio/`, not inside a feature, so `scales`
never has to import from `chords`. A note is a spelled letter and accidental,
never an integer: see [ADR-0009](adr/0009-music-primitives-and-note-spelling.md).

**Commercial labels stay out of the music domain.** `FeatureTier` lives in
`core/access/` and is attached in a feature's `data/` layer. A chord's notes do
not change with a subscription, and the client never decides entitlement
anyway (CLAUDE.md §23).

**Audio processing is behind an interface.** `core/audio/PitchDetector` is the
seam. Nothing outside it may depend on a specific DSP implementation
(CLAUDE.md §14), so the algorithm can be replaced without touching the tuner.
A layer test asserts it: no widget, controller or engine names a DSP class.

The detector is a **pure function of one window** — `DetectedPitch? analyze(AudioFrame)`
— with no microphone, no stream and no memory between frames. Capture is a
separate seam, `core/audio/AudioInput`, and the two platform plugins are each
imported by exactly one file. That split is what lets the algorithm be swept
across two hundred synthetic signals instead of only through a fake stream:
see [ADR-0012](adr/0012-audio-pipeline-and-pitch-detection.md).

**The tuner's state machine has no clock.** Time arrives as a frame's
timestamp, counted from samples rather than read from `DateTime.now()`, so a
tuning session replays identically on every machine
([ADR-0013](adr/0013-tuner-behaviour-and-thresholds.md)).

**Widgets lay out and nothing else.** No payment logic, no API authentication,
no database queries, no music calculation, no entitlement rules (CLAUDE.md §8).

**Design values come from tokens.** A literal colour, size, radius or duration
in a widget is a bug. See `packages/design-tokens/README.md`.

**The client is untrusted.** Premium state, prices and payment outcomes are
decided by the backend (CLAUDE.md §23, §51). The client may cache entitlement
for UX; it is never the source of truth.

## Feature structure

```text
features/<name>/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, providers
```

Layer directories are created when there is code for them. Empty scaffolding
is the "meaningless abstraction" CLAUDE.md §7 warns against.

## State management

Riverpod, everywhere, one approach (CLAUDE.md §9). See
[ADR-0002](adr/0002-flutter-state-management.md).

Anything holding a hardware resource is auto-disposing, so leaving its screen
releases it by construction rather than by remembering to — the tuner's
microphone is the case that matters (CLAUDE.md §50).

Every asynchronous surface models four states — loading, success, empty, error
— because CLAUDE.md §55 does not consider a feature done until all four exist.

## Backend layering

```text
Controller  ->  Service  ->  Prisma
   DTO           rules       data
validation
```

Cross-cutting concerns live in `src/common/`: role guards, the exception
filter that keeps stack traces away from clients, and the logging interceptor
that redacts credentials before anything is written.
