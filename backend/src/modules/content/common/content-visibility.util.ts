import { AdminRole, ContentStatus } from '@prisma/client';

import { AuthenticatedUser } from '../../../common/guards/jwt-auth.guard';

const CONTENT_EDITOR_ROLES: AdminRole[] = [
  AdminRole.EDITOR,
  AdminRole.ADMIN,
  AdminRole.SUPER_ADMIN,
];

/** Whether this (possibly anonymous) caller may see non-published content. */
export function canSeeUnpublished(user: AuthenticatedUser | undefined): boolean {
  return !!user?.role && CONTENT_EDITOR_ROLES.includes(user.role);
}

/** Statuses a public list/detail request should ever return. */
export const PUBLIC_STATUSES: ContentStatus[] = [ContentStatus.PUBLISHED];
