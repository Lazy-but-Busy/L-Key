# `practice` feature

Practice sessions, history, streaks and progress. Analytics beyond the basics is Premium (PRD.md §25).

**Specification:** PRD.md §24–26 · DESIGN.md §30–31

## Intended structure

```
practice/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, Riverpod providers
```

Music calculations belong in `domain/` and must not import Flutter
(CLAUDE.md §10), so they stay unit-testable and reusable from the backend and
from AI services.

**Phase 02 built the presentation layer only.** The session screen exists. The timer does not run and nothing is recorded.

Layer directories are created when there is code to put in them, because
empty folders are the "meaningless abstraction" CLAUDE.md §7 warns against.
