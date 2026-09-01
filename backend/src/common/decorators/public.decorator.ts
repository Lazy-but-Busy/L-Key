import { SetMetadata } from '@nestjs/common';

/** Metadata key read by `JwtAuthGuard`. */
export const IS_PUBLIC_KEY = 'lk:public';

/**
 * Marks a route as reachable without authentication.
 *
 * `JwtAuthGuard` is registered globally and denies by default (CLAUDE.md
 * §51) — a route must opt out explicitly rather than every controller
 * remembering to add a guard.
 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
