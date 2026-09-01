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

import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { OptionalAuth } from '../../../common/decorators/optional-auth.decorator';
import { Roles } from '../../../common/decorators/roles.decorator';
import { AuthenticatedUser } from '../../../common/guards/jwt-auth.guard';
import { UpdateStatusDto } from '../common/update-status.dto';
import { CreateSongDto } from './dto/create-song.dto';
import { SongQueryDto } from './dto/song-query.dto';
import { UpdateSongDto } from './dto/update-song.dto';
import { SongsService } from './songs.service';

const EDITORS = [AdminRole.EDITOR, AdminRole.ADMIN, AdminRole.SUPER_ADMIN];

@Controller('songs')
export class SongsController {
  constructor(private readonly songsService: SongsService) {}

  @OptionalAuth()
  @Get()
  list(
    @Query() query: SongQueryDto,
    @CurrentUser() user: AuthenticatedUser | undefined,
  ) {
    return this.songsService.list(query, user);
  }

  @OptionalAuth()
  @Get(':id')
  detail(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser | undefined,
  ) {
    return this.songsService.detail(id, user);
  }

  @Roles(...EDITORS)
  @Post()
  create(@Body() dto: CreateSongDto) {
    return this.songsService.create(dto);
  }

  @Roles(...EDITORS)
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateSongDto) {
    return this.songsService.update(id, dto);
  }

  @Roles(...EDITORS)
  @Post(':id/status')
  updateStatus(@Param('id') id: string, @Body() dto: UpdateStatusDto) {
    return this.songsService.updateStatus(id, dto.status);
  }
}
