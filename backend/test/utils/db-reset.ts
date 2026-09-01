import { INestApplication } from '@nestjs/common';

import { PrismaService } from '../../src/common/prisma/prisma.service';

/**
 * Empties every table between tests. `CASCADE` also empties tables that
 * reference the ones listed (e.g. payment tables reference `users`) — out
 * of scope for these tests, but harmless to clear alongside them.
 */
export async function resetDatabase(app: INestApplication): Promise<void> {
  const prisma = app.get(PrismaService);
  await prisma.$executeRawUnsafe(
    'TRUNCATE TABLE "users", "songs", "chords", "scales" RESTART IDENTITY CASCADE',
  );
}
