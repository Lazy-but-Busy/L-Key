import { IsEnum, IsOptional, IsString } from 'class-validator';
import { ContentStatus, ContentTier } from '@prisma/client';

import { PaginationQueryDto } from '../../common/pagination-query.dto';

export class ScaleQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsEnum(ContentStatus)
  status?: ContentStatus;

  @IsOptional()
  @IsEnum(ContentTier)
  tier?: ContentTier;

  @IsOptional()
  @IsString()
  category?: string;
}
