import { env } from '@/lib/env';

/**
 * Placeholder entry point.
 *
 * Phase 01 proves the token pipeline reaches the browser and that public
 * configuration validates. Authentication and the operations surfaces are
 * Phase 10 work; nothing here queries the API.
 */
export default function AdminHomePage() {
  return (
    <main
      style={{
        minHeight: '100vh',
        display: 'grid',
        placeItems: 'center',
        padding: 'var(--lk-space-6)',
      }}
    >
      <section
        style={{
          maxWidth: '32rem',
          width: '100%',
          background: 'var(--lk-surface)',
          border: 'var(--lk-border-default) solid var(--lk-border)',
          boxShadow: 'var(--lk-shadow-default)',
          padding: 'var(--lk-space-8)',
          display: 'grid',
          gap: 'var(--lk-space-4)',
        }}
      >
        <p
          style={{
            margin: 0,
            fontFamily: 'var(--lk-font-mono)',
            fontSize: 'var(--lk-size-technical-sm)',
            letterSpacing: 'var(--lk-tracking-technical-sm)',
            textTransform: 'uppercase',
            color: 'var(--lk-text-tertiary)',
          }}
        >
          L Key · Admin
        </p>

        <h1
          style={{
            fontSize: 'var(--lk-size-h1)',
            lineHeight: 'var(--lk-line-height-h1)',
            letterSpacing: 'var(--lk-tracking-h1)',
            textTransform: 'uppercase',
          }}
        >
          Sign in required
        </h1>

        <p style={{ margin: 0, color: 'var(--lk-text-secondary)' }}>
          Administrative access is authorised on the server. Authentication
          arrives with the Admin Portal in a later phase.
        </p>

        <p
          style={{
            margin: 0,
            fontFamily: 'var(--lk-font-mono)',
            fontSize: 'var(--lk-size-technical-sm)',
            color: 'var(--lk-text-tertiary)',
          }}
        >
          {env.NEXT_PUBLIC_APP_ENV} · {env.NEXT_PUBLIC_API_BASE_URL}
        </p>
      </section>
    </main>
  );
}
