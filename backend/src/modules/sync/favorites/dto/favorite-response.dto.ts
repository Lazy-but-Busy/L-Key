import { Favorite, FavoriteTargetType } from '@prisma/client';

export class FavoriteResponseDto {
  id!: string;
  targetType!: FavoriteTargetType;
  targetId!: string;
  createdAt!: Date;
}

export function toFavoriteResponse(favorite: Favorite): FavoriteResponseDto {
  return {
    id: favorite.id,
    targetType: favorite.targetType,
    targetId: favorite.targetId,
    createdAt: favorite.createdAt,
  };
}
