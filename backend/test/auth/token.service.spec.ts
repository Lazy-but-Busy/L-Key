import { jest } from '@jest/globals';
import { JwtService } from '@nestjs/jwt';
import { UnauthorizedException } from '@nestjs/common';
import { AdminRole } from '@prisma/client';

import { TokenService } from '../../src/modules/auth/token.service';

function buildPrismaMock() {
  const refreshTokens = new Map<string, Record<string, unknown>>();
  return {
    refreshToken: {
      create: jest.fn(async ({ data }: { data: Record<string, unknown> }) => {
        const row: Record<string, unknown> = {
          id: `rt_${refreshTokens.size}`,
          revokedAt: null,
          ...data,
        };
        refreshTokens.set(row.tokenHash as string, row);
        return row;
      }),
      findUnique: jest.fn(async ({ where: { tokenHash } }: any) =>
        refreshTokens.get(tokenHash) ?? null,
      ),
      update: jest.fn(async ({ where: { id }, data }: any) => {
        for (const row of refreshTokens.values()) {
          if (row.id === id) Object.assign(row, data);
        }
        return {};
      }),
      updateMany: jest.fn(async ({ where, data }: any) => {
        for (const row of refreshTokens.values()) {
          if (row.familyId === where.familyId) Object.assign(row, data);
        }
        return { count: 0 };
      }),
    },
    user: {
      findUnique: jest.fn(async () => ({ adminRole: AdminRole.EDITOR })),
    },
  };
}

describe('TokenService', () => {
  const jwtService = new JwtService({ secret: 'test-secret' });
  const configService = {
    get: () => 'test-secret-at-least-32-characters-long',
  } as any;

  it('issues a token pair and rotates it, invalidating the old refresh token', async () => {
    const prisma = buildPrismaMock();
    const service = new TokenService(jwtService, configService, prisma as any);

    const first = await service.issueTokenPair('user-1', AdminRole.EDITOR);
    expect(first.accessToken).toEqual(expect.any(String));

    const rotated = await service.rotateTokenPair(first.refreshToken);
    expect(rotated.refreshToken).not.toBe(first.refreshToken);

    // The original refresh token is now revoked and cannot be used again.
    await expect(service.rotateTokenPair(first.refreshToken)).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('revokes the whole token family when a revoked token is reused', async () => {
    const prisma = buildPrismaMock();
    const service = new TokenService(jwtService, configService, prisma as any);

    const first = await service.issueTokenPair('user-1', AdminRole.EDITOR);
    const rotated = await service.rotateTokenPair(first.refreshToken);

    // Reusing the already-rotated (now revoked) token is theft-shaped.
    await expect(service.rotateTokenPair(first.refreshToken)).rejects.toThrow(
      UnauthorizedException,
    );

    // The family is fully revoked, so even the latest legitimate token
    // issued from it no longer rotates.
    await expect(service.rotateTokenPair(rotated.refreshToken)).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('rejects an unknown refresh token', async () => {
    const prisma = buildPrismaMock();
    const service = new TokenService(jwtService, configService, prisma as any);

    await expect(service.rotateTokenPair('not-a-real-token')).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('revoke() is idempotent', async () => {
    const prisma = buildPrismaMock();
    const service = new TokenService(jwtService, configService, prisma as any);

    const first = await service.issueTokenPair('user-1');
    await service.revoke(first.refreshToken);
    await expect(service.revoke(first.refreshToken)).resolves.toBeUndefined();
  });
});
