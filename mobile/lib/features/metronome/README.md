# `metronome` feature

Tempo, tap tempo, time signatures and subdivisions. Audio timing must not drift; scheduling belongs in the domain layer, not a widget timer.

**Specification:** PRD.md §16–18 · DESIGN.md §27

## Intended structure

```
metronome/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, Riverpod providers
```

Music calculations belong in `domain/` and must not import Flutter
(CLAUDE.md §10), so they stay unit-testable and reusable from the backend and
from AI services.

**Phase 02 built the presentation layer only.** The metronome screen exists and its tempo is editable. Nothing sounds and no beat advances.

Layer directories are created when there is code to put in them, because
empty folders are the "meaningless abstraction" CLAUDE.md §7 warns against.
