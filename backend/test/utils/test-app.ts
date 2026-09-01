import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';

import { AppModule } from '../../src/app.module';
import { loadEnv } from '../../src/config/env.schema';

/**
 * Boots a full Nest application against the real (test) database, with the
 * same pipes as `main.ts` — an e2e test exercises the whole HTTP stack, not
 * a service in isolation.
 */
export async function createTestApp(): Promise<INestApplication> {
  loadEnv(); // fails loudly if DATABASE_URL/JWT_SECRET aren't set

  const moduleRef = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  const app = moduleRef.createNestApplication();
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  await app.init();
  return app;
}
