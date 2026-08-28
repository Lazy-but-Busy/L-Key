# `fretboard` feature

Interactive fretboard across 6/7/8-string and bass. The engine calculates strings, frets, tuning, notes and intervals; the widget only renders the result (CLAUDE.md §13).

**Specification:** PRD.md §13 · DESIGN.md §25

## Intended structure

```
fretboard/
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
