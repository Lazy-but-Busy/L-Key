import { jest } from '@jest/globals';
import { NotFoundException } from '@nestjs/common';
import { ContentStatus, SongDifficulty, SongLanguage } from '@prisma/client';

import { SongsService } from '../../src/modules/content/songs/songs.service';

const baseSong = {
  id: 'song-1',
  title: 'Amazing Grace',
  artist: 'Traditional',
  language: SongLanguage.ENGLISH,
  key: 'G',
  capo: 0,
  tuning: 'standard',
  bpm: 80,
  difficulty: SongDifficulty.BEGINNER,
  genre: 'Worship',
  sections: [],
  lyrics: 'Amazing grace',
  chords: [],
  metadata: null,
  status: ContentStatus.DRAFT as ContentStatus,
  tier: 'FREE',
  publishedAt: null,
  archivedAt: null,
};

function buildPrismaMock(song = baseSong) {
  return {
    song: {
      findMany: jest.fn(async () => [song]),
      count: jest.fn(async () => 1),
      findUnique: jest.fn(async () => song),
      findUniqueOrThrow: jest.fn(async () => song),
      create: jest.fn(async ({ data }: any) => ({ ...song, ...data })),
      update: jest.fn(async ({ data }: any) => ({ ...song, ...data })),
    },
  };
}

describe('SongsService', () => {
  it('list() only returns PUBLISHED songs for an anonymous caller', async () => {
    const prisma = buildPrismaMock();
    const service = new SongsService(prisma as any);

    await service.list({ page: 1, pageSize: 20 } as any, undefined);

    expect(prisma.song.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ status: { in: [ContentStatus.PUBLISHED] } }),
      }),
    );
  });

  it('list() lets an EDITOR see any status (including an explicit filter)', async () => {
    const prisma = buildPrismaMock();
    const service = new SongsService(prisma as any);

    await service.list(
      { page: 1, pageSize: 20, status: ContentStatus.DRAFT } as any,
      { id: 'admin-1', role: 'EDITOR' as any },
    );

    expect(prisma.song.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ status: ContentStatus.DRAFT }),
      }),
    );
  });

  it('detail() 404s a draft for an anonymous caller rather than exposing it', async () => {
    const prisma = buildPrismaMock({ ...baseSong, status: ContentStatus.DRAFT });
    const service = new SongsService(prisma as any);

    await expect(service.detail('song-1', undefined)).rejects.toThrow(
      NotFoundException,
    );
  });

  it('detail() returns a draft to an EDITOR', async () => {
    const prisma = buildPrismaMock({ ...baseSong, status: ContentStatus.DRAFT });
    const service = new SongsService(prisma as any);

    await expect(
      service.detail('song-1', { id: 'admin-1', role: 'EDITOR' as any }),
    ).resolves.toMatchObject({ id: 'song-1' });
  });

  it('create() lets the database default apply DRAFT rather than setting it explicitly', async () => {
    const prisma = buildPrismaMock();
    const service = new SongsService(prisma as any);

    await service.create({
      title: 'New Song',
      artist: 'Someone',
      language: SongLanguage.ENGLISH,
      key: 'C',
      bpm: 100,
      difficulty: SongDifficulty.BEGINNER,
      genre: 'Pop',
      sections: [],
      lyrics: 'la la la',
      chords: [],
    } as any);

    const [[{ data }]] = prisma.song.create.mock.calls;
    expect(data.status).toBeUndefined();
  });

  it('updateStatus() archives via an update, never a delete', async () => {
    const prisma = buildPrismaMock({
      ...baseSong,
      status: ContentStatus.PUBLISHED,
    });
    const service = new SongsService(prisma as any);

    await service.updateStatus('song-1', ContentStatus.ARCHIVED);

    expect(prisma.song.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ status: ContentStatus.ARCHIVED }),
      }),
    );
  });
});
