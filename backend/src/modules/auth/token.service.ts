import { randomBytes, createHash, randomUUID } from 'node:crypto';

import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { AdminRole } from '@prisma/client';

import { Env } from '../../config/env.schema';
import { PrismaService } from '../../common/prisma/prisma.service';

const ACCESS_TOKEN_TTL = '15m';
const REFRESH_TOKEN_TTL_MS = 30 * 24 * 60 * 60 * 1000; // 30 days

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

/**
 * Issues, rotates and revokes the token pair. Access tokens are stateless
 * JWTs (cheap to verify on every request); refresh tokens are opaque random
 * values whose SHA-256 hash is the only thing persisted (CLAUDE.md §22 —
 * tokens must be securely stored, never logged or stored raw).
 *
 * Refresh tokens rotate on every use and share a `familyId` per login.
 * Presenting an already-revoked token from a family is treated as theft —
 * the whole family is revoked, forcing re-login.
 */
@Injectable()
export class TokenService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService<Env, true>,
    private readonly prisma: PrismaService,
  ) {}

  private get secret(): string {
    return this.configService.get('JWT_SECRET', { infer: true });
  }

  async signAccessToken(userId: string, role?: AdminRole): Promise<string> {
    return this.jwtService.signAsync(
      { sub: userId, role, type: 'access' },
      { secret: this.secret, expiresIn: ACCESS_TOKEN_TTL },
    );
  }

  /** Issues a brand-new token pair, starting a new refresh-token family. */
  async issueTokenPair(userId: string, role?: AdminRole): Promise<TokenPair> {
    const accessToken = await this.signAccessToken(userId, role);
    const refreshToken = await this.createRefreshToken(userId, randomUUID());
    return { accessToken, refreshToken };
  }

  /**
   * Verifies a refresh token, rotates it, and issues a fresh pair. Throws on
   * an invalid, expired, or already-revoked (reused) token. The access
   * token's role claim is re-read from the database rather than trusted from
   * the caller, so a role change since the original login takes effect.
   */
  async rotateTokenPair(rawRefreshToken: string): Promise<TokenPair> {
    const tokenHash = this.hashToken(rawRefreshToken);
    const existing = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
    });

    if (!existing || existing.expiresAt < new Date()) {
      throw new UnauthorizedException();
    }

    if (existing.revokedAt) {
      // Reuse of a revoked token — treat the whole family as compromised.
      await this.prisma.refreshToken.updateMany({
        where: { familyId: existing.familyId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      throw new UnauthorizedException();
    }

    const user = await this.prisma.user.findUnique({
      where: { id: existing.userId },
      select: { adminRole: true },
    });
    if (!user) throw new UnauthorizedException();

    await this.prisma.refreshToken.update({
      where: { id: existing.id },
      data: { revokedAt: new Date() },
    });

    const accessToken = await this.signAccessToken(
      existing.userId,
      user.adminRole ?? undefined,
    );
    const refreshToken = await this.createRefreshToken(
      existing.userId,
      existing.familyId,
    );
    return { accessToken, refreshToken };
  }

  /** Revokes a single refresh token (logout). Idempotent. */
  async revoke(rawRefreshToken: string): Promise<void> {
    const tokenHash = this.hashToken(rawRefreshToken);
    await this.prisma.refreshToken.updateMany({
      where: { tokenHash, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  private async createRefreshToken(
    userId: string,
    familyId: string,
  ): Promise<string> {
    const raw = randomBytes(32).toString('base64url');
    await this.prisma.refreshToken.create({
      data: {
        userId,
        familyId,
        tokenHash: this.hashToken(raw),
        expiresAt: new Date(Date.now() + REFRESH_TOKEN_TTL_MS),
      },
    });
    return raw;
  }

  private hashToken(raw: string): string {
    return createHash('sha256').update(raw).digest('hex');
  }
}
