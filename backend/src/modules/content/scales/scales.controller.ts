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
import { CreateScaleDto } from './dto/create-scale.dto';
import { ScaleQueryDto } from './dto/scale-query.dto';
import { UpdateScaleDto } from './dto/update-scale.dto';
import { ScalesService } from './scales.service';

const EDITORS = [AdminRole.EDITOR, AdminRole.ADMIN, AdminRole.SUPER_ADMIN];

@ApiTags('scales')
@Controller('scales')
export class ScalesController {
  constructor(private readonly scalesService: ScalesService) {}

  @OptionalAuth()
  @Get()
  list(
    @Query() query: ScaleQueryDto,
    @CurrentUser() user: AuthenticatedUser | undefined,
  ) {
    return this.scalesService.list(query, user);
  }

  @OptionalAuth()
  @Get(':id')
  detail(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser | undefined,
  ) {
    return this.scalesService.detail(id, user);
  }

  @ApiBearerAuth()
  @Roles(...EDITORS)
  @Post()
  create(@Body() dto: CreateScaleDto) {
    return this.scalesService.create(dto);
  }

  @ApiBearerAuth()
  @Roles(...EDITORS)
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateScaleDto) {
    return this.scalesService.update(id, dto);
  }

  @ApiBearerAuth()
  @Roles(...EDITORS)
  @Post(':id/status')
  updateStatus(@Param('id') id: string, @Body() dto: UpdateStatusDto) {
    return this.scalesService.updateStatus(id, dto.status);
  }
}
