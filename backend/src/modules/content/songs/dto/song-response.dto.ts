import { ContentStatus, ContentTier, Song, SongDifficulty, SongLanguage } from '@prisma/client';

/** Lightweight shape for list views — omits the heavy content fields. */
export class SongSummaryDto {
  id!: string;
  title!: string;
  artist!: string;
  language!: SongLanguage;
  key!: string;
  capo!: number;
  tuning!: string;
  bpm!: number;
  difficulty!: SongDifficulty;
  genre!: string;
  status!: ContentStatus;
  tier!: ContentTier;
}

/** Full contract: title, artist, language, key, capo, tuning, BPM,
 * difficulty, genre, sections, lyrics, chords, metadata. */
export class SongResponseDto extends SongSummaryDto {
  sections!: unknown;
  lyrics!: string;
  chords!: unknown;
  metadata!: unknown;
}

export function toSongSummary(song: Song): SongSummaryDto {
  return {
    id: song.id,
    title: song.title,
    artist: song.artist,
    language: song.language,
    key: song.key,
    capo: song.capo,
    tuning: song.tuning,
    bpm: song.bpm,
    difficulty: song.difficulty,
    genre: song.genre,
    status: song.status,
    tier: song.tier,
  };
}

export function toSongResponse(song: Song): SongResponseDto {
  return {
    ...toSongSummary(song),
    sections: song.sections,
    lyrics: song.lyrics,
    chords: song.chords,
    metadata: song.metadata,
  };
}
