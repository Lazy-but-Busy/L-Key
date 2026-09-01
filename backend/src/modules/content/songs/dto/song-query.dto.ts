import { IsEnum, IsOptional, IsString } from 'class-validator';
import {
  ContentStatus,
  ContentTier,
  SongDifficulty,
  SongLanguage,
} from '@prisma/client';

import { PaginationQueryDto } from '../../common/pagination-query.dto';

export class SongQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsEnum(ContentStatus)
  status?: ContentStatus;

  @IsOptional()
  @IsEnum(SongLanguage)
  language?: SongLanguage;

  @IsOptional()
  @IsEnum(SongDifficulty)
  difficulty?: SongDifficulty;

  @IsOptional()
  @IsString()
  genre?: string;

  @IsOptional()
  @IsEnum(ContentTier)
  tier?: ContentTier;
}
