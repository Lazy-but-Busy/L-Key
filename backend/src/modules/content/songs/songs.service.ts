import { Injectable, NotFoundException } from '@nestjs/common';
import { ContentStatus, Prisma } from '@prisma/client';

import { PrismaService } from '../../../common/prisma/prisma.service';
import { AuthenticatedUser } from '../../../common/guards/jwt-auth.guard';
import {
  PUBLIC_STATUSES,
  canSeeUnpublished,
} from '../common/content-visibility.util';
import { assertValidTransition } from '../common/content-status.util';
import { normalizeText } from '../common/normalize-text';
import { PaginatedResult } from '../common/paginated-result';
import { CreateSongDto } from './dto/create-song.dto';
import {
  SongResponseDto,
  SongSummaryDto,
  toSongResponse,
  toSongSummary,
} from './dto/song-response.dto';
import { SongQueryDto } from './dto/song-query.dto';
import { UpdateSongDto } from './dto/update-song.dto';

@Injectable()
export class SongsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(
    query: SongQueryDto,
    user: AuthenticatedUser | undefined,
  ): Promise<PaginatedResult<SongSummaryDto>> {
    const canSeeAll = canSeeUnpublished(user);
    const where: Prisma.SongWhereInput = {
      status: canSeeAll ? query.status : { in: PUBLIC_STATUSES },
      language: query.language,
      difficulty: query.difficulty,
      genre: query.genre,
      tier: query.tier,
      ...(query.search
        ? {
            OR: [
              { title: { contains: query.search, mode: 'insensitive' } },
              { artist: { contains: query.search, mode: 'insensitive' } },
            ],
          }
        : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.song.findMany({
        where,
        skip: (query.page - 1) * query.pageSize,
        take: query.pageSize,
        orderBy: { title: 'asc' },
      }),
      this.prisma.song.count({ where }),
    ]);

    return {
      items: items.map(toSongSummary),
      total,
      page: query.page,
      pageSize: query.pageSize,
    };
  }

  async detail(
    id: string,
    user: AuthenticatedUser | undefined,
  ): Promise<SongResponseDto> {
    const song = await this.prisma.song.findUnique({ where: { id } });
    if (!song) throw new NotFoundException();

    // A non-published song 404s for a non-editor caller, same as a
    // nonexistent id — a draft's existence never leaks.
    if (
      !PUBLIC_STATUSES.includes(song.status) &&
      !canSeeUnpublished(user)
    ) {
      throw new NotFoundException();
    }

    return toSongResponse(song);
  }

  async create(dto: CreateSongDto): Promise<SongResponseDto> {
    const song = await this.prisma.song.create({
      data: {
        ...dto,
        title: normalizeText(dto.title),
        artist: normalizeText(dto.artist),
        lyrics: normalizeText(dto.lyrics),
        sections: dto.sections as Prisma.InputJsonValue,
        chords: dto.chords as Prisma.InputJsonValue,
        metadata: dto.metadata as Prisma.InputJsonValue,
      },
    });
    return toSongResponse(song);
  }

  async update(id: string, dto: UpdateSongDto): Promise<SongResponseDto> {
    await this.prisma.song.findUniqueOrThrow({ where: { id } });
    const song = await this.prisma.song.update({
      where: { id },
      data: {
        ...dto,
        title: dto.title !== undefined ? normalizeText(dto.title) : undefined,
        artist:
          dto.artist !== undefined ? normalizeText(dto.artist) : undefined,
        lyrics:
          dto.lyrics !== undefined ? normalizeText(dto.lyrics) : undefined,
        sections: dto.sections as Prisma.InputJsonValue | undefined,
        chords: dto.chords as Prisma.InputJsonValue | undefined,
        metadata: dto.metadata as Prisma.InputJsonValue | undefined,
      },
    });
    return toSongResponse(song);
  }

  async updateStatus(
    id: string,
    status: ContentStatus,
  ): Promise<SongResponseDto> {
    const existing = await this.prisma.song.findUniqueOrThrow({
      where: { id },
    });
    assertValidTransition(existing.status, status);

    const song = await this.prisma.song.update({
      where: { id },
      data: {
        status,
        publishedAt:
          status === ContentStatus.PUBLISHED ? new Date() : existing.publishedAt,
        archivedAt:
          status === ContentStatus.ARCHIVED ? new Date() : existing.archivedAt,
      },
    });
    return toSongResponse(song);
  }
}
