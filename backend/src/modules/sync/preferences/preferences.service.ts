import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';
import {
  DEFAULT_PREFERENCES,
  PreferencesResponseDto,
  toPreferencesResponse,
} from './dto/preferences-response.dto';
import { UpsertPreferencesDto } from './dto/upsert-preferences.dto';

@Injectable()
export class PreferencesService {
  constructor(private readonly prisma: PrismaService) {}

  async get(userId: string): Promise<PreferencesResponseDto> {
    const prefs = await this.prisma.userPreferences.findUnique({
      where: { userId },
    });
    return prefs ? toPreferencesResponse(prefs) : DEFAULT_PREFERENCES;
  }

  /** Whole-row upsert — no per-field diff/merge (minimal sync, not a sync engine). */
  async upsert(
    userId: string,
    dto: UpsertPreferencesDto,
  ): Promise<PreferencesResponseDto> {
    const prefs = await this.prisma.userPreferences.upsert({
      where: { userId },
      create: { userId, ...dto },
      update: dto,
    });
    return toPreferencesResponse(prefs);
  }
}
