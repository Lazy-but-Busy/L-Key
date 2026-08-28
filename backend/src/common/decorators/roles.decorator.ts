import { SetMetadata } from '@nestjs/common';

/** Administrative roles, in ascending order of privilege (CLAUDE.md §27). */
export enum AdminRole {
  Support = 'SUPPORT',
  Editor = 'EDITOR',
  Admin = 'ADMIN',
  SuperAdmin = 'SUPER_ADMIN',
}

/** Metadata key read by `RolesGuard`. */
export const ROLES_KEY = 'lk:roles';

/**
 * Restricts a route to the listed roles.
 *
 * Authorization is enforced here on the server. CLAUDE.md §27 is explicit that
 * hiding a route in the Admin front end is not a security control.
 */
export const Roles = (...roles: AdminRole[]) => SetMetadata(ROLES_KEY, roles);
