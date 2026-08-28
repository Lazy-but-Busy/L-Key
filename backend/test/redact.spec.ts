import { redact } from '../src/common/interceptors/redact';

describe('redact', () => {
  it('removes credentials and tokens from log payloads', () => {
    // CLAUDE.md §38 — logs must never contain these values.
    const out = redact({
      email: 'player@example.com',
      password: 'hunter2',
      accessToken: 'eyJhbGciOi...',
      authorization: 'Bearer abc',
    }) as Record<string, unknown>;

    expect(out.email).toBe('player@example.com');
    expect(out.password).toBe('[redacted]');
    expect(out.accessToken).toBe('[redacted]');
    expect(out.authorization).toBe('[redacted]');
  });

  it('redacts payment secrets nested inside objects and arrays', () => {
    const out = redact({
      orders: [{ id: '1', signature: 'deadbeef', webhookSecret: 's3cret' }],
    }) as { orders: Array<Record<string, unknown>> };

    expect(out.orders[0].id).toBe('1');
    expect(out.orders[0].signature).toBe('[redacted]');
    expect(out.orders[0].webhookSecret).toBe('[redacted]');
  });

  it('stops recursing on deeply nested input', () => {
    let deep: Record<string, unknown> = { password: 'x' };
    for (let i = 0; i < 20; i++) deep = { nested: deep };
    expect(() => redact(deep)).not.toThrow();
  });
});
