# `home` feature

The first screen: greeting, Quick Tune, quick tools and recent songs. The
"Continue Practice" card was cut along with Practice (ADR-0017).

**Specification:** PRD.md §8 · DESIGN.md §20

## Intended structure

```
home/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, Riverpod providers
```

Recent songs read from `features/songs/data/song_catalog.dart` — the same
sample content the song library shows — rather than a separate mock list,
which the real song API (Phase 09) will eventually replace.

Layer directories are created when there is code to put in them, because
empty folders are the "meaningless abstraction" CLAUDE.md §7 warns against.
