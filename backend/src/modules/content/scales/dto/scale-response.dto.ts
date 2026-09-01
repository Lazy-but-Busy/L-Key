import { ContentStatus, ContentTier, Scale } from '@prisma/client';

export class ScaleResponseDto {
  id!: string;
  name!: string;
  category!: string;
  formula!: unknown;
  patterns!: unknown;
  status!: ContentStatus;
  tier!: ContentTier;
}

export function toScaleResponse(scale: Scale): ScaleResponseDto {
  return {
    id: scale.id,
    name: scale.name,
    category: scale.category,
    formula: scale.formula,
    patterns: scale.patterns,
    status: scale.status,
    tier: scale.tier,
  };
}
