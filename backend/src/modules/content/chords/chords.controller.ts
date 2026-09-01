import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { AdminRole } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { OptionalAuth } from '../../../common/decorators/optional-auth.decorator';
import { Roles } from '../../../common/decorators/roles.decorator';
import { AuthenticatedUser } from '../../../common/guards/jwt-auth.guard';
import { UpdateStatusDto } from '../common/update-status.dto';
import { ChordsService } from './chords.service';
import { ChordQueryDto } from './dto/chord-query.dto';
import { CreateChordDto } from './dto/create-chord.dto';
import { UpdateChordDto } from './dto/update-chord.dto';

const EDITORS = [AdminRole.EDITOR, AdminRole.ADMIN, AdminRole.SUPER_ADMIN];

@ApiTags('chords')
@Controller('chords')
export class ChordsController {
  constructor(private readonly chordsService: ChordsService) {}

  @OptionalAuth()
  @Get()
  list(
    @Query() query: ChordQueryDto,
    @CurrentUser() user: AuthenticatedUser | undefined,
  ) {
    return this.chordsService.list(query, user);
  }

  @OptionalAuth()
  @Get(':id')
  detail(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser | undefined,
  ) {
    return this.chordsService.detail(id, user);
  }

  @ApiBearerAuth()
  @Roles(...EDITORS)
  @Post()
  create(@Body() dto: CreateChordDto) {
    return this.chordsService.create(dto);
  }

  @ApiBearerAuth()
  @Roles(...EDITORS)
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateChordDto) {
    return this.chordsService.update(id, dto);
  }

  @ApiBearerAuth()
  @Roles(...EDITORS)
  @Post(':id/status')
  updateStatus(@Param('id') id: string, @Body() dto: UpdateStatusDto) {
    return this.chordsService.updateStatus(id, dto.status);
  }
}
