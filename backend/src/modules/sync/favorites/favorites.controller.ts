import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseEnumPipe,
  Post,
  Query,
} from '@nestjs/common';
import { FavoriteTargetType } from '@prisma/client';

import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../../common/guards/jwt-auth.guard';
import { AddFavoriteDto } from './dto/add-favorite.dto';
import { FavoritesService } from './favorites.service';

@Controller('sync/favorites')
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @Get()
  list(
    @CurrentUser() user: AuthenticatedUser,
    @Query(
      'targetType',
      new ParseEnumPipe(FavoriteTargetType, { optional: true }),
    )
    targetType?: FavoriteTargetType,
  ) {
    return this.favoritesService.list(user.id, targetType);
  }

  @Post()
  add(@CurrentUser() user: AuthenticatedUser, @Body() dto: AddFavoriteDto) {
    return this.favoritesService.add(user.id, dto);
  }

  @Delete(':targetType/:targetId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @CurrentUser() user: AuthenticatedUser,
    @Param('targetType', new ParseEnumPipe(FavoriteTargetType))
    targetType: FavoriteTargetType,
    @Param('targetId') targetId: string,
  ): Promise<void> {
    await this.favoritesService.remove(user.id, targetType, targetId);
  }
}
