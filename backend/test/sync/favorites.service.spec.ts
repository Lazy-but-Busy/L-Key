import { jest } from '@jest/globals';
import { FavoriteTargetType } from '@prisma/client';

import { FavoritesService } from '../../src/modules/sync/favorites/favorites.service';

function buildPrismaMock() {
  const rows = new Map<string, Record<string, unknown>>();
  const key = (userId: string, targetType: string, targetId: string) =>
    `${userId}:${targetType}:${targetId}`;

  return {
    favorite: {
      upsert: jest.fn(async ({ create }: any) => {
        const k = key(create.userId, create.targetType, create.targetId);
        if (!rows.has(k)) {
          rows.set(k, { id: `fav_${rows.size}`, createdAt: new Date(), ...create });
        }
        return rows.get(k);
      }),
      deleteMany: jest.fn(async ({ where }: any) => {
        const k = key(where.userId, where.targetType, where.targetId);
        const existed = rows.delete(k);
        return { count: existed ? 1 : 0 };
      }),
      findMany: jest.fn(async () => [...rows.values()]),
    },
  };
}

describe('FavoritesService', () => {
  it('add() is idempotent — adding the same favorite twice returns one row', async () => {
    const prisma = buildPrismaMock();
    const service = new FavoritesService(prisma as any);

    const first = await service.add('user-1', {
      targetType: FavoriteTargetType.SONG,
      targetId: 'song-1',
    });
    const second = await service.add('user-1', {
      targetType: FavoriteTargetType.SONG,
      targetId: 'song-1',
    });

    expect(second.id).toBe(first.id);
    expect(await service.list('user-1')).toHaveLength(1);
  });

  it('remove() on a favorite that never existed does not throw', async () => {
    const prisma = buildPrismaMock();
    const service = new FavoritesService(prisma as any);

    await expect(
      service.remove('user-1', FavoriteTargetType.SONG, 'never-added'),
    ).resolves.toBeUndefined();
  });
});
