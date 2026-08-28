# `users` module

Not implemented in Phase 01. This directory marks the intended module boundary
so later work has an obvious home rather than growing a shared "services" bag.

Expected shape when implemented:

```
users/
├── users.module.ts
├── users.controller.ts    HTTP surface, DTO validation only
├── users.service.ts       business rules
└── dto/                request and response shapes
```
