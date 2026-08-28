# `home` feature

The first screen: greeting, Quick Tune, quick tools, the daily session and recent songs.

**Specification:** PRD.md §8 · DESIGN.md §20

## Intended structure

```
home/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, Riverpod providers
```

The screen exists against placeholder content in `home_mock_data.dart`, which the song and practice APIs replace.

Layer directories are created when there is code to put in them, because
empty folders are the "meaningless abstraction" CLAUDE.md §7 warns against.
