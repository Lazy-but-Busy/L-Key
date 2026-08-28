import { envSchema, loadEnv } from '../src/config/env.schema';

const valid = {
  DATABASE_URL: 'postgresql://user:pass@localhost:5432/lkey',
  JWT_SECRET: 'a'.repeat(32),
};

describe('environment configuration', () => {
  it('accepts a minimal valid environment', () => {
    const env = loadEnv(valid as NodeJS.ProcessEnv);
    expect(env.APP_ENV).toBe('local');
    expect(env.PORT).toBe(3000);
  });

  it('fails loudly when a required variable is missing', () => {
    // A misconfigured deploy must not boot into a confusing runtime error.
    expect(() => loadEnv({ JWT_SECRET: 'a'.repeat(32) } as NodeJS.ProcessEnv))
      .toThrow(/DATABASE_URL/);
  });

  it('rejects a weak signing secret', () => {
    const result = envSchema.safeParse({ ...valid, JWT_SECRET: 'short' });
    expect(result.success).toBe(false);
  });

  it('treats the payment webhook secret as optional', () => {
    // Local development must boot without payment credentials, but the
    // secret is still validated when present (CLAUDE.md §24).
    expect(() => loadEnv(valid as NodeJS.ProcessEnv)).not.toThrow();
    const weak = envSchema.safeParse({
      ...valid,
      MYANMYANPAY_WEBHOOK_SECRET: 'tooshort',
    });
    expect(weak.success).toBe(false);
  });
});
