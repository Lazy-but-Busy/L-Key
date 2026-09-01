import { BadRequestException } from '@nestjs/common';
import { ContentStatus } from '@prisma/client';

/**
 * Valid lifecycle transitions (CLAUDE.md §29). ARCHIVED is reachable from
 * any state (soft delete — CLAUDE.md §30) but never left once reached.
 */
const TRANSITIONS: Record<ContentStatus, ContentStatus[]> = {
  DRAFT: [ContentStatus.IN_REVIEW, ContentStatus.ARCHIVED],
  IN_REVIEW: [
    ContentStatus.DRAFT,
    ContentStatus.PUBLISHED,
    ContentStatus.ARCHIVED,
  ],
  PUBLISHED: [ContentStatus.UNPUBLISHED, ContentStatus.ARCHIVED],
  UNPUBLISHED: [ContentStatus.PUBLISHED, ContentStatus.ARCHIVED],
  ARCHIVED: [],
};

export function assertValidTransition(
  from: ContentStatus,
  to: ContentStatus,
): void {
  if (from === to) return;
  if (!TRANSITIONS[from].includes(to)) {
    throw new BadRequestException(
      `Cannot move content from ${from} to ${to}`,
    );
  }
}
