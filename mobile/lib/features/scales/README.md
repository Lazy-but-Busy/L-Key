# `scales` feature

Scale formulas, positions and fretboard boxes.

**Specification:** PRD.md §14 · DESIGN.md §25–26

## Intended structure

```
scales/
├── data/           DTOs, datasources, repository implementations
├── domain/         entities, repository interfaces, use cases, engines
└── presentation/   pages, widgets, Riverpod providers
```

The screen layout exists. Nothing is computed — the scale engine must stay Flutter-free (CLAUDE.md §12) and is the next phase.

Layer directories are created when there is code to put in them, because
empty folders are the "meaningless abstraction" CLAUDE.md §7 warns against.
