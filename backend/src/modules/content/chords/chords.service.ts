import { Injectable, NotFoundException } from '@nestjs/common';
import { ContentStatus, Prisma } from '@prisma/client';

import { PrismaService } from '../../../common/prisma/prisma.service';
import { AuthenticatedUser } from '../../../common/guards/jwt-auth.guard';
import { assertValidTransition } from '../common/content-status.util';
import {
  PUBLIC_STATUSES,
  canSeeUnpublished,
} from '../common/content-visibility.util';
import { PaginatedResult } from '../common/paginated-result';
import { ChordQueryDto } from './dto/chord-query.dto';
import { ChordResponseDto, toChordResponse } from './dto/chord-response.dto';
import { CreateChordDto } from './dto/create-chord.dto';
import { UpdateChordDto } from './dto/update-chord.dto';

@Injectable()
export class ChordsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(
    query: ChordQueryDto,
    user: AuthenticatedUser | undefined,
  ): Promise<PaginatedResult<ChordResponseDto>> {
    const canSeeAll = canSeeUnpublished(user);
    const where: Prisma.ChordWhereInput = {
      status: canSeeAll ? query.status : { in: PUBLIC_STATUSES },
      tier: query.tier,
      ...(query.search
        ? { name: { contains: query.search, mode: 'insensitive' } }
        : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.chord.findMany({
        where,
        skip: (query.page - 1) * query.pageSize,
        take: query.pageSize,
        orderBy: { name: 'asc' },
      }),
      this.prisma.chord.count({ where }),
    ]);

    return {
      items: items.map(toChordResponse),
      total,
      page: query.page,
      pageSize: query.pageSize,
    };
  }

  async detail(
    id: string,
    user: AuthenticatedUser | undefined,
  ): Promise<ChordResponseDto> {
    const chord = await this.prisma.chord.findUnique({ where: { id } });
    if (!chord) throw new NotFoundException();
    if (!PUBLIC_STATUSES.includes(chord.status) && !canSeeUnpublished(user)) {
      throw new NotFoundException();
    }
    return toChordResponse(chord);
  }

  async create(dto: CreateChordDto): Promise<ChordResponseDto> {
    const chord = await this.prisma.chord.create({
      data: {
        ...dto,
        formula: dto.formula as Prisma.InputJsonValue,
        voicings: dto.voicings as Prisma.InputJsonValue,
      },
    });
    return toChordResponse(chord);
  }

  async update(id: string, dto: UpdateChordDto): Promise<ChordResponseDto> {
    await this.prisma.chord.findUniqueOrThrow({ where: { id } });
    const chord = await this.prisma.chord.update({
      where: { id },
      data: {
        ...dto,
        formula: dto.formula as Prisma.InputJsonValue | undefined,
        voicings: dto.voicings as Prisma.InputJsonValue | undefined,
      },
    });
    return toChordResponse(chord);
  }

  async updateStatus(
    id: string,
    status: ContentStatus,
  ): Promise<ChordResponseDto> {
    const existing = await this.prisma.chord.findUniqueOrThrow({
      where: { id },
    });
    assertValidTransition(existing.status, status);

    const chord = await this.prisma.chord.update({
      where: { id },
      data: {
        status,
        archivedAt:
          status === ContentStatus.ARCHIVED ? new Date() : existing.archivedAt,
      },
    });
    return toChordResponse(chord);
  }
}
