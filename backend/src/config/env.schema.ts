import { z } from 'zod';

/**
 * Environment contract for the L Key backend.
 *
 * Validated once at boot so a missing or malformed variable fails loudly at
 * startup rather than surfacing as a confusing 500 later. Nothing here may be
 * sent to a client: CLAUDE.md §22 and §24 keep payment and signing secrets
 * server-side, and §51 treats the mobile client as untrusted.
 */
export const envSchema = z.object({
  NODE_ENV: z
    .enum(['development', 'test', 'production'])
    .default('development'),
  APP_ENV: z
    .enum(['local', 'dev', 'staging', 'production'])
    .default('local'),
  PORT: z.coerce.number().int().positive().default(3000),

  /** PostgreSQL connection string (CLAUDE.md §26). */
  DATABASE_URL: z.string().url(),

  /** Signing key for access tokens. Server-only, never shipped to a client. */
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),

  /**
   * MyanMyanPay webhook signing secret.
   *
   * CLAUDE.md §24 is explicit that this never leaves the backend. It is
   * optional so local development can boot without payment credentials.
   */
  MYANMYANPAY_WEBHOOK_SECRET: z.string().min(16).optional(),

  /** Comma-separated list of origins permitted to call the API. */
  CORS_ORIGINS: z.string().default('http://localhost:3001'),
});

/** Validated environment shape. */
export type Env = z.infer<typeof envSchema>;

/**
 * Parses and validates `process.env`.
 *
 * Throws with every problem listed at once, rather than one at a time.
 */
export function loadEnv(source: NodeJS.ProcessEnv = process.env): Env {
  const parsed = envSchema.safeParse(source);
  if (!parsed.success) {
    const detail = parsed.error.issues
      .map((i) => `  - ${i.path.join('.') || '(root)'}: ${i.message}`)
      .join('\n');
    throw new Error(`Invalid environment configuration:\n${detail}`);
  }
  return parsed.data;
}
