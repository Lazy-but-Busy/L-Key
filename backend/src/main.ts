import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';

import { AppModule } from './app.module';
import { loadEnv } from './config/env.schema';

async function bootstrap(): Promise<void> {
  // Validate before Nest starts, so a bad environment fails in one clear line.
  const env = loadEnv();

  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // strip unknown properties
      forbidNonWhitelisted: true, // reject them loudly
      transform: true,
    }),
  );

  app.enableCors({
    origin: env.CORS_ORIGINS.split(',').map((o) => o.trim()),
    credentials: true,
  });

  await app.listen(env.PORT);
  new Logger('Bootstrap').log(
    `L Key backend listening on :${env.PORT} (${env.APP_ENV})`,
  );
}

void bootstrap();
