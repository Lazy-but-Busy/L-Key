import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

import { AdminRole, ROLES_KEY } from '../decorators/roles.decorator';
import { AuthenticatedUser } from './jwt-auth.guard';

interface RequestWithUser {
  user?: AuthenticatedUser;
}

/**
 * Enforces `@Roles(...)` on a route.
 *
 * Denies by default: a route annotated with roles and reached by a request
 * carrying no resolved user is rejected, so a misconfigured auth pipeline
 * fails closed rather than open.
 */
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<AdminRole[] | undefined>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    // No annotation means the route is not role-restricted.
    if (!required || required.length === 0) return true;

    const request = context.switchToHttp().getRequest<RequestWithUser>();
    const role = request.user?.role;

    if (!role || !required.includes(role)) {
      throw new ForbiddenException();
    }
    return true;
  }
}
