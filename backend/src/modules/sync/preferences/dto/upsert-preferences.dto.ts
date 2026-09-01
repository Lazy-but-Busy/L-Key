import { IsEnum, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';
import { ThemeModePreference } from '@prisma/client';

/** Whole-row replace — mirrors mobile's `Settings.copyWith` semantics but
 * as a single PUT, matching the "no partial-field sync engine" scope. */
export class UpsertPreferencesDto {
  @IsOptional()
  @IsString()
  locale?: string;

  @IsEnum(ThemeModePreference)
  themeMode!: ThemeModePreference;

  /** Hz. Mobile clamps to 415–445 (Settings.minimumReferencePitchHz /
   * maximumReferencePitchHz) — the same range is enforced here. */
  @IsNumber()
  @Min(415)
  @Max(445)
  referencePitchHz!: number;
}
