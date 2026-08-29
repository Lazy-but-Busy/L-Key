# Architecture decision records

One file per structural decision. Short, dated, and honest about what was
rejected — the rejected options are usually what you need to remember later.

| # | Decision | Status |
| --- | --- | --- |
| [0001](0001-backend-runtime.md) | NestJS + TypeScript for the backend | Accepted |
| [0002](0002-flutter-state-management.md) | Riverpod for Flutter state | Accepted |
| [0003](0003-design-token-source-of-truth.md) | DESIGN.md is authoritative; the design system fills its silences | Accepted |
| [0004](0004-token-distribution.md) | One token source, generated per platform | Accepted |
| [0005](0005-environment-and-configuration.md) | dart-defines and zod-validated env | Accepted |
| [0006](0006-myanmar-font-fallback.md) | Bundle Noto Sans Myanmar as the Burmese fallback | Accepted |
| [0007](0007-shell-topology.md) | One shell, five branches, and where detail screens live | Superseded in part by 0014 |
| [0008](0008-settings-persistence.md) | shared_preferences for settings | Accepted |
| [0009](0009-music-primitives-and-note-spelling.md) | Spelled notes in `core/music`, not integers in a feature | Accepted |
| [0010](0010-guitar-voicing-generation.md) | Movable shapes plus a curated open table, checked by an invariant | Accepted |
| [0011](0011-scale-fretboard-and-caged.md) | The neck is arithmetic; the five CAGED shapes are data with a guard | Accepted |
| [0012](0012-audio-pipeline-and-pitch-detection.md) | The pitch detector is a pure function, and the FFT is ours | Accepted |
| [0013](0013-tuner-behaviour-and-thresholds.md) | The tuner's state machine has no clock, and every threshold is one file | Accepted |
| [0014](0014-full-screen-tool-navigation.md) | Every detail screen is a tool, above the shell | Accepted |
| [0015](0015-chord-analysis.md) | The chord engine, run backwards, and what it refuses to name | Accepted |
