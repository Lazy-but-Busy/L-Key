import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Reflector } from '@nestjs/core';
import { AdminRole } from '@prisma/client';

import { JwtAuthGuard } from '../../src/common/guards/jwt-auth.guard';
import { IS_PUBLIC_KEY } from '../../src/common/decorators/public.decorator';
import { OPTIONAL_AUTH_KEY } from '../../src/common/decorators/optional-auth.decorator';

const SECRET = 'test-secret-at-least-32-characters-long';

function buildContext(options: {
  headers?: Record<string, string>;
  metadata?: Record<string, boolean>;
}): { context: ExecutionContext; request: { headers: Record<string, string>; user?: unknown } } {
  const request: { headers: Record<string, string>; user?: unknown } = {
    headers: options.headers ?? {},
  };
  const context = {
    getHandler: () => ({}),
    getClass: () => ({}),
    switchToHttp: () => ({ getRequest: () => request }),
  } as unknown as ExecutionContext;
  return { context, request };
}

function buildReflector(metadata: Record<string, boolean>): Reflector {
  return {
    getAllAndOverride: (key: string) => metadata[key],
  } as unknown as Reflector;
}

describe('JwtAuthGuard', () => {
  const jwtService = new JwtService({ secret: SECRET });
  const configService = { get: () => SECRET } as any;

  async function signToken(role?: AdminRole) {
    return jwtService.signAsync(
      { sub: 'user-1', role, type: 'access' },
      { secret: SECRET },
    );
  }

  it('rejects a request with no Authorization header', async () => {
    const guard = new JwtAuthGuard(jwtService, configService, buildReflector({}));
    const { context } = buildContext({});
    await expect(guard.canActivate(context)).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('rejects a malformed token', async () => {
    const guard = new JwtAuthGuard(jwtService, configService, buildReflector({}));
    const { context } = buildContext({
      headers: { authorization: 'Bearer not-a-jwt' },
    });
    await expect(guard.canActivate(context)).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('populates request.user from a valid token', async () => {
    const guard = new JwtAuthGuard(jwtService, configService, buildReflector({}));
    const token = await signToken(AdminRole.EDITOR);
    const { context, request } = buildContext({
      headers: { authorization: `Bearer ${token}` },
    });

    await expect(guard.canActivate(context)).resolves.toBe(true);
    expect(request.user).toEqual({ id: 'user-1', role: AdminRole.EDITOR });
  });

  it('bypasses verification entirely for a @Public() route', async () => {
    const guard = new JwtAuthGuard(
      jwtService,
      configService,
      buildReflector({ [IS_PUBLIC_KEY]: true }),
    );
    const { context, request } = buildContext({});
    await expect(guard.canActivate(context)).resolves.toBe(true);
    expect(request.user).toBeUndefined();
  });

  it('allows a missing/invalid token on an @OptionalAuth() route, without setting a user', async () => {
    const guard = new JwtAuthGuard(
      jwtService,
      configService,
      buildReflector({ [OPTIONAL_AUTH_KEY]: true }),
    );
    const { context, request } = buildContext({});
    await expect(guard.canActivate(context)).resolves.toBe(true);
    expect(request.user).toBeUndefined();
  });

  it('still populates request.user on an @OptionalAuth() route when a valid token is present', async () => {
    const guard = new JwtAuthGuard(
      jwtService,
      configService,
      buildReflector({ [OPTIONAL_AUTH_KEY]: true }),
    );
    const token = await signToken();
    const { context, request } = buildContext({
      headers: { authorization: `Bearer ${token}` },
    });
    await expect(guard.canActivate(context)).resolves.toBe(true);
    expect(request.user).toEqual({ id: 'user-1', role: undefined });
  });
});
