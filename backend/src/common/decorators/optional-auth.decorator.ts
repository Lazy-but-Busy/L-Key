import { SetMetadata } from '@nestjs/common';

/** Metadata key read by `JwtAuthGuard`. */
export const OPTIONAL_AUTH_KEY = 'lk:optional-auth';

/**
 * Marks a route as open to both anonymous and authenticated callers.
 *
 * Unlike `@Public()`, `JwtAuthGuard` still verifies a token when one is
 * present and populates `request.user` — so a route can serve public
 * content to everyone while giving an authenticated admin a richer result
 * (e.g. draft content visibility), without a second route.
 */
export const OptionalAuth = () => SetMetadata(OPTIONAL_AUTH_KEY, true);
