# `tuner` feature

Microphone pitch detection and tuning guidance. The highest-priority MVP tool (CLAUDE.md §54). Audio processing lives behind `core/audio/PitchDetector` and never inside a widget (CLAUDE.md §14).

**Specification:** PRD.md §10 · DESIGN.md §21–22 · docs/adr/0012 · docs/adr/0013

## Structure

```
tuner/
├── data/           the tunings on offer, and the tier each is labelled with
├── domain/         the tuning engine, the session state machine, the pipeline
└── presentation/   the screen, the controller, the meter
```

Music calculations belong in `domain/` and must not import Flutter
(CLAUDE.md §10), so they stay unit-testable and reusable from the backend and
from AI services. The audio half lives in `core/audio/` rather than here,
because chord recognition (CLAUDE.md §16) needs the same pipeline and should
not have to reach into a sibling feature.

## The chain

```text
Microphone → AudioInput → AudioFrameAssembler → FrequencyAnalyzer
           → PitchDetector → TuningEngine → TuningSession → TunerController → UI
           └───────────────── core/audio ──────────────┘└─ tuner/domain ─┘
```

Everything left of the controller is plain Dart. The two platform plugins,
`record` and `permission_handler`, are each imported by exactly one file, and a
layer test asserts it.

## What is verified, and what is not

The algorithm is tested against a couple of hundred synthetic signals — every
semitone from A0 to E6, five waveform shapes, five noise levels, a missing
fundamental, stiffness, decay, vibrato, clipping. That is real evidence about
the arithmetic.

**It is not evidence about a microphone.** No accuracy claim belongs anywhere
in the product until `docs/DEVICE-TESTING.md` has been filled in on real iOS
and Android hardware (mobile/CLAUDE.md §15, CLAUDE.md §47).

Run with `--dart-define=ENABLE_TUNER_DIAGNOSTICS=true` to see the raw
measurements every threshold in `domain/tuner_thresholds.dart` is set against.
