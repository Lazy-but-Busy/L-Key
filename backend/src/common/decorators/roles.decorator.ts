import { SetMetadata } from '@nestjs/common';
import { AdminRole } from '@prisma/client';

/**
 * Administrative roles (CLAUDE.md §27), re-exported from the Prisma-generated
 * enum so `request.user.role` (populated from a DB-backed JWT claim) and
 * `@Roles(...)` always agree on the same values — no second, hand-written
 * enum to drift out of sync.
 */
export { AdminRole };

/** Metadata key read by `RolesGuard`. */
export const ROLES_KEY = 'lk:roles';

/**
 * Restricts a route to the listed roles.
 *
 * Authorization is enforced here on the server. CLAUDE.md §27 is explicit that
 * hiding a route in the Admin front end is not a security control.
 */
export const Roles = (...roles: AdminRole[]) => SetMetadata(ROLES_KEY, roles);
