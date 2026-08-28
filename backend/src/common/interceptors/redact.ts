/** Keys whose values must never appear in a log line (CLAUDE.md §38). */
const SENSITIVE = [
  'password',
  'token',
  'accessToken',
  'refreshToken',
  'authorization',
  'secret',
  'apiKey',
  'signature',
  'webhookSecret',
  'cardNumber',
];

const REDACTED = '[redacted]';

/**
 * Deep-copies a value with sensitive fields replaced.
 *
 * CLAUDE.md §38 forbids logging passwords, tokens, keys and payment secrets.
 * Structured logging makes accidental capture easy, so redaction happens on
 * the way into the logger rather than being left to each call site.
 */
export function redact(value: unknown, depth = 0): unknown {
  if (depth > 6 || value === null || typeof value !== 'object') return value;

  if (Array.isArray(value)) return value.map((v) => redact(v, depth + 1));

  const out: Record<string, unknown> = {};
  for (const [key, v] of Object.entries(value as Record<string, unknown>)) {
    const sensitive = SENSITIVE.some((s) =>
      key.toLowerCase().includes(s.toLowerCase()),
    );
    out[key] = sensitive ? REDACTED : redact(v, depth + 1);
  }
  return out;
}
