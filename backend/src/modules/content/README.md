# `content` module

Not implemented in Phase 01. This directory marks the intended module boundary
so later work has an obvious home rather than growing a shared "services" bag.

Expected shape when implemented:

```
content/
├── content.module.ts
├── content.controller.ts    HTTP surface, DTO validation only
├── content.service.ts       business rules
└── dto/                request and response shapes
```
