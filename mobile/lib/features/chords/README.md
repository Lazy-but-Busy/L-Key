# `chords` feature

Chord library, diagrams and the chord trainer. Needs a reusable chord engine covering names, notes, intervals, voicings and transposition (CLAUDE.md §11).

**Specification:** PRD.md §11–12 · DESIGN.md §23–24

## Intended structure

```
chords/
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
