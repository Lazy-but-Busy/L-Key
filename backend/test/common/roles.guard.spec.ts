import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AdminRole } from '@prisma/client';

import { RolesGuard } from '../../src/common/guards/roles.guard';

function buildContext(user?: { id: string; role?: AdminRole }): ExecutionContext {
  return {
    getHandler: () => ({}),
    getClass: () => ({}),
    switchToHttp: () => ({ getRequest: () => ({ user }) }),
  } as unknown as ExecutionContext;
}

function buildReflector(required: AdminRole[] | undefined): Reflector {
  return { getAllAndOverride: () => required } as unknown as Reflector;
}

describe('RolesGuard', () => {
  it('allows a route with no @Roles() annotation', () => {
    const guard = new RolesGuard(buildReflector(undefined));
    expect(guard.canActivate(buildContext())).toBe(true);
  });

  it('denies when no user is present on the request (fails closed)', () => {
    const guard = new RolesGuard(buildReflector([AdminRole.EDITOR]));
    expect(() => guard.canActivate(buildContext(undefined))).toThrow(
      ForbiddenException,
    );
  });

  it("denies a user whose role isn't in the required list", () => {
    const guard = new RolesGuard(buildReflector([AdminRole.SUPER_ADMIN]));
    expect(() =>
      guard.canActivate(buildContext({ id: 'u1', role: AdminRole.EDITOR })),
    ).toThrow(ForbiddenException);
  });

  it('allows a user with a matching role', () => {
    const guard = new RolesGuard(
      buildReflector([AdminRole.EDITOR, AdminRole.ADMIN]),
    );
    expect(
      guard.canActivate(buildContext({ id: 'u1', role: AdminRole.EDITOR })),
    ).toBe(true);
  });
});
