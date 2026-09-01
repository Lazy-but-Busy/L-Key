import { IsEnum } from 'class-validator';
import { ContentStatus } from '@prisma/client';

export class UpdateStatusDto {
  @IsEnum(ContentStatus)
  status!: ContentStatus;
}
