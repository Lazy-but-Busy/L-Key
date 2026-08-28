# `learning` feature

Course → Module → Lesson → Exercise. Content is authored in the Admin CMS and must respect draft/published status (CLAUDE.md §29).

**Specification:** PRD.md §29–30 · DESIGN.md §54

## Intended structure

```
learning/
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
