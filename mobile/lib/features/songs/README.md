# `songs` feature

Song library, viewer, transposer and capo assistant. Copyrighted lyrics may only ship where rights exist (CLAUDE.md §31).

**Specification:** PRD.md §19–22 · DESIGN.md §28–29

## Intended structure

```
songs/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, Riverpod providers
```

Music calculations belong in `domain/` and must not import Flutter
(CLAUDE.md §10), so they stay unit-testable and reusable from the backend and
from AI services.

**Phase 02 built the presentation layer only.** The library screen, search and filters exist. The song viewer, transposer and capo assistant do not.

Layer directories are created when there is code to put in them, because
empty folders are the "meaningless abstraction" CLAUDE.md §7 warns against.
