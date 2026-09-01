import { Module } from '@nestjs/common';

import { ChordsController } from './chords/chords.controller';
import { ChordsService } from './chords/chords.service';
import { ScalesController } from './scales/scales.controller';
import { ScalesService } from './scales/scales.service';
import { SongsController } from './songs/songs.controller';
import { SongsService } from './songs/songs.service';

@Module({
  controllers: [SongsController, ChordsController, ScalesController],
  providers: [SongsService, ChordsService, ScalesService],
})
export class ContentModule {}
