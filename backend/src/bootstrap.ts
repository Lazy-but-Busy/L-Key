import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import { AppModule } from './app.module';
import { loadEnv } from './config/env.schema';

export async function bootstrap(): Promise<void> {
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

  // Not mounted in production: the schema exposes internal route/DTO shape,
  // and this API has no external consumers there yet.
  if (env.APP_ENV !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('L Key API')
      .setDescription('Authentication, content, sync and notifications')
      .setVersion('1.0')
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api', app, document);
  }

  await app.listen(env.PORT);
  new Logger('Bootstrap').log(
    `L Key backend listening on :${env.PORT} (${env.APP_ENV})`,
  );
}
