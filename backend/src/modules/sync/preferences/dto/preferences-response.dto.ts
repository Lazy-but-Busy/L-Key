import { ThemeModePreference, UserPreferences } from '@prisma/client';

export class PreferencesResponseDto {
  locale!: string | null;
  themeMode!: ThemeModePreference;
  referencePitchHz!: number;
}

export function toPreferencesResponse(
  prefs: UserPreferences,
): PreferencesResponseDto {
  return {
    locale: prefs.locale,
    themeMode: prefs.themeMode,
    referencePitchHz: prefs.referencePitchHz,
  };
}

export const DEFAULT_PREFERENCES: PreferencesResponseDto = {
  locale: null,
  themeMode: ThemeModePreference.SYSTEM,
  referencePitchHz: 440,
};
