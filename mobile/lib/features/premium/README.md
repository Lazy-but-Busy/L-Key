# `premium` feature

Paywall, plans and the MMQR payment flow. Entitlement is server-authoritative — the client never decides that a payment succeeded (CLAUDE.md §23–24).

**Specification:** PRD.md §43–47 · DESIGN.md §32–35

## Intended structure

```
premium/
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
