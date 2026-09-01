import { IsArray, IsOptional, IsString, IsUrl } from 'class-validator';

export class CreateChordDto {
  @IsString()
  name!: string;

  @IsString()
  root!: string;

  @IsString()
  quality!: string;

  /** Interval formula, e.g. ["1","3","5","7"]. */
  @IsArray()
  formula!: unknown[];

  /** [{ tuning, frets[], fingers[], barre? }, ...] */
  @IsArray()
  voicings!: unknown[];

  @IsOptional()
  @IsUrl()
  audioUrl?: string;
}
