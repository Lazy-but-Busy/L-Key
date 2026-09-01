import { IsEnum, IsString } from 'class-validator';
import { FavoriteTargetType } from '@prisma/client';

export class AddFavoriteDto {
  @IsEnum(FavoriteTargetType)
  targetType!: FavoriteTargetType;

  @IsString()
  targetId!: string;
}
