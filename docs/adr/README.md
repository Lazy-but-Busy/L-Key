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
| [0007](0007-shell-topology.md) | One shell, five branches, and where detail screens live | Accepted |
| [0008](0008-settings-persistence.md) | shared_preferences for settings | Accepted |
| [0009](0009-music-primitives-and-note-spelling.md) | Spelled notes in `core/music`, not integers in a feature | Accepted |
| [0010](0010-guitar-voicing-generation.md) | Movable shapes plus a curated open table, checked by an invariant | Accepted |
