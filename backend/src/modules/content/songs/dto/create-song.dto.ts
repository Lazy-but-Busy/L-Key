import { Type } from 'class-transformer';
import {
  IsArray,
  IsEnum,
  IsInt,
  IsObject,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { SongDifficulty, SongLanguage } from '@prisma/client';

export class CreateSongDto {
  @IsString()
  title!: string;

  @IsString()
  artist!: string;

  @IsEnum(SongLanguage)
  language!: SongLanguage;

  @IsString()
  key!: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  capo? = 0;

  @IsOptional()
  @IsString()
  tuning? = 'standard';

  @Type(() => Number)
  @IsInt()
  @Min(1)
  bpm!: number;

  @IsEnum(SongDifficulty)
  difficulty!: SongDifficulty;

  @IsString()
  genre!: string;

  /** Ordered structural document — see Song model doc comment. */
  @IsArray()
  sections!: unknown[];

  @IsString()
  lyrics!: string;

  /** Distinct chord names/voicings used in the song. */
  @IsArray()
  chords!: unknown[];

  @IsOptional()
  @IsObject()
  metadata?: Record<string, unknown>;
}
