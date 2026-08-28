# `tuner` feature

Microphone pitch detection and tuning guidance. The highest-priority MVP tool (CLAUDE.md §54). Audio processing lives behind `core/audio/PitchDetector` and never inside a widget (CLAUDE.md §14).

**Specification:** PRD.md §10 · DESIGN.md §21–22

## Intended structure

```
tuner/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, Riverpod providers
```

Music calculations belong in `domain/` and must not import Flutter
(CLAUDE.md §10), so they stay unit-testable and reusable from the backend and
from AI services.

Not implemented in Phase 01. This README marks the boundary; layer directories
are created when there is code to put in them, because empty folders are the
"meaningless abstraction" CLAUDE.md §7 warns against.
