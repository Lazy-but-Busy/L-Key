import { Body, Controller, Get, Put } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../../common/guards/jwt-auth.guard';
import { UpsertPreferencesDto } from './dto/upsert-preferences.dto';
import { PreferencesService } from './preferences.service';

@ApiTags('sync')
@ApiBearerAuth()
@Controller('sync/preferences')
export class PreferencesController {
  constructor(private readonly preferencesService: PreferencesService) {}

  @Get()
  get(@CurrentUser() user: AuthenticatedUser) {
    return this.preferencesService.get(user.id);
  }

  @Put()
  upsert(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpsertPreferencesDto,
  ) {
    return this.preferencesService.upsert(user.id, dto);
  }
}
