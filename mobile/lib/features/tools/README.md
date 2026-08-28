# `tools` feature

The hub listing every utility, with Premium rows marked.

**Specification:** PRD.md §65 · DESIGN.md §32

## Intended structure

```
tools/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, Riverpod providers
```

The hub exists. Premium rows are a presentational lock only — there is no entitlement source, and PRD.md §46 puts that decision on the server.

Layer directories are created when there is code to put in them, because
empty folders are the "meaningless abstraction" CLAUDE.md §7 warns against.
