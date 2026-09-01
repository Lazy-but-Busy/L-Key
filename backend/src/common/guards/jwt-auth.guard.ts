import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Reflector } from '@nestjs/core';
import { Request } from 'express';

import { AdminRole } from '@prisma/client';
import { Env } from '../../config/env.schema';
import { OPTIONAL_AUTH_KEY } from '../decorators/optional-auth.decorator';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

/** Claims carried by an access token, and the shape `request.user` takes. */
export interface AuthenticatedUser {
  id: string;
  role?: AdminRole;
}

interface AccessTokenPayload {
  sub: string;
  role?: AdminRole;
  type: 'access';
}

/**
 * Verifies the bearer access token on every request and populates
 * `request.user` in the shape `RolesGuard` already expects.
 *
 * Registered globally (`APP_GUARD`) and fails closed: a route must opt out
 * with `@Public()` rather than every controller remembering to add this
 * guard (CLAUDE.md §51).
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService<Env, true>,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(
      IS_PUBLIC_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (isPublic) return true;

    const isOptional = this.reflector.getAllAndOverride<boolean>(
      OPTIONAL_AUTH_KEY,
      [context.getHandler(), context.getClass()],
    );

    const request = context.switchToHttp().getRequest<Request>();
    const token = this.extractToken(request);

    if (!token) {
      if (isOptional) return true;
      throw new UnauthorizedException();
    }

    try {
      const payload = await this.jwtService.verifyAsync<AccessTokenPayload>(
        token,
        { secret: this.configService.get('JWT_SECRET', { infer: true }) },
      );
      if (payload.type !== 'access') throw new UnauthorizedException();

      (request as Request & { user: AuthenticatedUser }).user = {
        id: payload.sub,
        role: payload.role,
      };
      return true;
    } catch {
      if (isOptional) return true;
      throw new UnauthorizedException();
    }
  }

  private extractToken(request: Request): string | undefined {
    const header = request.headers.authorization;
    if (!header?.startsWith('Bearer ')) return undefined;
    return header.slice('Bearer '.length);
  }
}
