# `profile` feature

Account, guitar collection, settings, language and theme. Authentication is optional; guests keep full access to the core tools (PRD.md §9).

**Specification:** PRD.md §9, §27 · DESIGN.md §36

## Intended structure

```
profile/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, Riverpod providers
```

Music calculations belong in `domain/` and must not import Flutter
(CLAUDE.md §10), so they stay unit-testable and reusable from the backend and
from AI services.

**Phase 02 built the presentation layer only.** The profile screen exists for a guest. Accounts, the guitar collection and the paywall do not.

Layer directories are created when there is code to put in them, because
empty folders are the "meaningless abstraction" CLAUDE.md §7 warns against.
