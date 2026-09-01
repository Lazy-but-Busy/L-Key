import { BadRequestException } from '@nestjs/common';
import { ContentStatus } from '@prisma/client';

import { assertValidTransition } from '../../src/modules/content/common/content-status.util';

describe('assertValidTransition', () => {
  it.each([
    [ContentStatus.DRAFT, ContentStatus.IN_REVIEW],
    [ContentStatus.IN_REVIEW, ContentStatus.PUBLISHED],
    [ContentStatus.PUBLISHED, ContentStatus.UNPUBLISHED],
    [ContentStatus.UNPUBLISHED, ContentStatus.PUBLISHED],
    [ContentStatus.DRAFT, ContentStatus.ARCHIVED],
    [ContentStatus.PUBLISHED, ContentStatus.ARCHIVED],
  ])('allows %s -> %s', (from, to) => {
    expect(() => assertValidTransition(from, to)).not.toThrow();
  });

  it('allows a no-op transition to the same status', () => {
    expect(() =>
      assertValidTransition(ContentStatus.PUBLISHED, ContentStatus.PUBLISHED),
    ).not.toThrow();
  });

  it.each([
    [ContentStatus.ARCHIVED, ContentStatus.PUBLISHED],
    [ContentStatus.PUBLISHED, ContentStatus.DRAFT],
    [ContentStatus.DRAFT, ContentStatus.PUBLISHED],
  ])('rejects %s -> %s', (from, to) => {
    expect(() => assertValidTransition(from, to)).toThrow(BadRequestException);
  });
});
