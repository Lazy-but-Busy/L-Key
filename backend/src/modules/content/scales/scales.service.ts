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
import { CreateScaleDto } from './dto/create-scale.dto';
import { ScaleQueryDto } from './dto/scale-query.dto';
import { ScaleResponseDto, toScaleResponse } from './dto/scale-response.dto';
import { UpdateScaleDto } from './dto/update-scale.dto';

@Injectable()
export class ScalesService {
  constructor(private readonly prisma: PrismaService) {}

  async list(
    query: ScaleQueryDto,
    user: AuthenticatedUser | undefined,
  ): Promise<PaginatedResult<ScaleResponseDto>> {
    const canSeeAll = canSeeUnpublished(user);
    const where: Prisma.ScaleWhereInput = {
      status: canSeeAll ? query.status : { in: PUBLIC_STATUSES },
      tier: query.tier,
      category: query.category,
      ...(query.search
        ? { name: { contains: query.search, mode: 'insensitive' } }
        : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.scale.findMany({
        where,
        skip: (query.page - 1) * query.pageSize,
        take: query.pageSize,
        orderBy: { name: 'asc' },
      }),
      this.prisma.scale.count({ where }),
    ]);

    return {
      items: items.map(toScaleResponse),
      total,
      page: query.page,
      pageSize: query.pageSize,
    };
  }

  async detail(
    id: string,
    user: AuthenticatedUser | undefined,
  ): Promise<ScaleResponseDto> {
    const scale = await this.prisma.scale.findUnique({ where: { id } });
    if (!scale) throw new NotFoundException();
    if (!PUBLIC_STATUSES.includes(scale.status) && !canSeeUnpublished(user)) {
      throw new NotFoundException();
    }
    return toScaleResponse(scale);
  }

  async create(dto: CreateScaleDto): Promise<ScaleResponseDto> {
    const scale = await this.prisma.scale.create({
      data: {
        ...dto,
        formula: dto.formula as Prisma.InputJsonValue,
        patterns: dto.patterns as Prisma.InputJsonValue,
      },
    });
    return toScaleResponse(scale);
  }

  async update(id: string, dto: UpdateScaleDto): Promise<ScaleResponseDto> {
    await this.prisma.scale.findUniqueOrThrow({ where: { id } });
    const scale = await this.prisma.scale.update({
      where: { id },
      data: {
        ...dto,
        formula: dto.formula as Prisma.InputJsonValue | undefined,
        patterns: dto.patterns as Prisma.InputJsonValue | undefined,
      },
    });
    return toScaleResponse(scale);
  }

  async updateStatus(
    id: string,
    status: ContentStatus,
  ): Promise<ScaleResponseDto> {
    const existing = await this.prisma.scale.findUniqueOrThrow({
      where: { id },
    });
    assertValidTransition(existing.status, status);

    const scale = await this.prisma.scale.update({
      where: { id },
      data: {
        status,
        archivedAt:
          status === ContentStatus.ARCHIVED ? new Date() : existing.archivedAt,
      },
    });
    return toScaleResponse(scale);
  }
}
