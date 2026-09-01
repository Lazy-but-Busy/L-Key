import { IsArray, IsString } from 'class-validator';

export class CreateScaleDto {
  @IsString()
  name!: string;

  @IsString()
  category!: string;

  @IsArray()
  formula!: unknown[];

  /** Fretboard box / three-notes-per-string patterns. */
  @IsArray()
  patterns!: unknown[];
}
