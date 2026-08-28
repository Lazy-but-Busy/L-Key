# Security notes

Standing record of accepted risks and the reasoning behind them. Reviewed at
the start of each phase.

---

## Accepted: `deepmerge-ts` advisory via the Prisma CLI

**Advisory:** GHSA-ggr8-5vv4-36mx — stack exhaustion when merging recursive
object graphs. Severity: high.

**Path:** `prisma` (devDependency) → `@prisma/config` → `deepmerge-ts@7.1.5`

**Decision: accepted, not remediated.** Three reasons.

1. **Not reachable in production.** `prisma` is a devDependency used for
   `validate`, `format`, `generate` and `migrate`. The runtime dependency is
   `@prisma/client`, which does not depend on `@prisma/config`. No deployed
   L Key process loads the vulnerable code.
2. **The trigger is our own config.** The vulnerable path merges a Prisma
   configuration file. That file is `prisma.config.ts` in this repository —
   there is no untrusted input reaching it.
3. **Both fixes are worse than the risk.** `npm audit fix --force` downgrades
   to `prisma@6.12.0`, a major version behind. An npm `override` to
   `deepmerge-ts@^8` was attempted and rejected: `@prisma/config` pins `7.1.5`
   exactly, so forcing a major bump into a vendor's pinned internal is
   unsupported and risks silently breaking `prisma generate`.

**Revisit when:** Prisma ships a release depending on `deepmerge-ts@^8`. Check
with `npm view @prisma/config dependencies`. At that point, bump Prisma and
confirm `npm audit` is clean.

**Not acceptable to:** move `prisma` to a runtime dependency, or run the
Prisma CLI against a configuration file from an untrusted source, while this
stands.
