import { Chord, ContentStatus, ContentTier } from '@prisma/client';

export class ChordResponseDto {
  id!: string;
  name!: string;
  root!: string;
  quality!: string;
  formula!: unknown;
  voicings!: unknown;
  audioUrl!: string | null;
  status!: ContentStatus;
  tier!: ContentTier;
}

export function toChordResponse(chord: Chord): ChordResponseDto {
  return {
    id: chord.id,
    name: chord.name,
    root: chord.root,
    quality: chord.quality,
    formula: chord.formula,
    voicings: chord.voicings,
    audioUrl: chord.audioUrl,
    status: chord.status,
    tier: chord.tier,
  };
}
