import { Module } from '@nestjs/common';

import { FavoritesController } from './favorites/favorites.controller';
import { FavoritesService } from './favorites/favorites.service';
import { PreferencesController } from './preferences/preferences.controller';
import { PreferencesService } from './preferences/preferences.service';

@Module({
  controllers: [FavoritesController, PreferencesController],
  providers: [FavoritesService, PreferencesService],
})
export class SyncModule {}
