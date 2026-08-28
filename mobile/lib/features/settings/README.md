# `settings` feature

Language, appearance and reference pitch, persisted across launches.

**Specification:** DESIGN.md §68 · docs/adr/0008

## Intended structure

```
settings/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, Riverpod providers
```

Complete for this phase. The controller is the single source for locale and theme, read by `MaterialApp` and by the Profile screen.

Layer directories are created when there is code to put in them, because
empty folders are the "meaningless abstraction" CLAUDE.md §7 warns against.
