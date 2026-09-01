import { Injectable } from '@nestjs/common';
import { FavoriteTargetType } from '@prisma/client';

import { PrismaService } from '../../../common/prisma/prisma.service';
import { AddFavoriteDto } from './dto/add-favorite.dto';
import { FavoriteResponseDto, toFavoriteResponse } from './dto/favorite-response.dto';

@Injectable()
export class FavoritesService {
  constructor(private readonly prisma: PrismaService) {}

  async list(
    userId: string,
    targetType?: FavoriteTargetType,
  ): Promise<FavoriteResponseDto[]> {
    const favorites = await this.prisma.favorite.findMany({
      where: { userId, targetType },
      orderBy: { createdAt: 'desc' },
    });
    return favorites.map(toFavoriteResponse);
  }

  /** Idempotent: adding the same favorite twice returns the existing row. */
  async add(
    userId: string,
    dto: AddFavoriteDto,
  ): Promise<FavoriteResponseDto> {
    const favorite = await this.prisma.favorite.upsert({
      where: {
        userId_targetType_targetId: {
          userId,
          targetType: dto.targetType,
          targetId: dto.targetId,
        },
      },
      create: { userId, targetType: dto.targetType, targetId: dto.targetId },
      update: {},
    });
    return toFavoriteResponse(favorite);
  }

  /** Idempotent: removing a favorite that doesn't exist is a no-op. */
  async remove(
    userId: string,
    targetType: FavoriteTargetType,
    targetId: string,
  ): Promise<void> {
    await this.prisma.favorite.deleteMany({
      where: { userId, targetType, targetId },
    });
  }
}
