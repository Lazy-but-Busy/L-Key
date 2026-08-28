import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER, APP_INTERCEPTOR } from '@nestjs/core';

import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';
import { loadEnv } from './config/env.schema';

/**
 * Application root.
 *
 * Phase 01 wires only cross-cutting concerns: configuration validation, the
 * exception filter and request logging. Feature modules under `src/modules`
 * are registered as they are implemented.
 */
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      // Fails the boot on a missing or malformed variable.
      validate: loadEnv,
    }),
  ],
  providers: [
    { provide: APP_FILTER, useClass: AllExceptionsFilter },
    { provide: APP_INTERCEPTOR, useClass: LoggingInterceptor },
  ],
})
export class AppModule {}
