import { z } from 'zod';

/**
 * Browser-visible configuration.
 *
 * Only `NEXT_PUBLIC_*` values may live here — anything in this schema ends up
 * in the client bundle. Secrets belong in the backend (CLAUDE.md §22, §51).
 */
const schema = z.object({
  NEXT_PUBLIC_APP_ENV: z
    .enum(['local', 'dev', 'staging', 'production'])
    .default('local'),
  NEXT_PUBLIC_API_BASE_URL: z.string().url().default('http://localhost:3000'),
});

const parsed = schema.safeParse({
  NEXT_PUBLIC_APP_ENV: process.env.NEXT_PUBLIC_APP_ENV,
  NEXT_PUBLIC_API_BASE_URL: process.env.NEXT_PUBLIC_API_BASE_URL,
});

if (!parsed.success) {
  const detail = parsed.error.issues
    .map((i) => `  - ${i.path.join('.')}: ${i.message}`)
    .join('\n');
  throw new Error(`Invalid public environment configuration:\n${detail}`);
}

/** Validated public configuration. */
export const env = parsed.data;
