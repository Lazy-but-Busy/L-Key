/**
 * Landing hero (DESIGN.md §59).
 *
 * Phase 01 ships one page to prove the token pipeline reaches the browser.
 * The remaining sections and SEO routes in PRD.md §60 are later work.
 *
 * Two corrections from the design-system review are built in from the start:
 * real heading elements rather than styled spans, and a fluid `max-width`
 * container instead of a fixed 1280px width.
 */
export default function HomePage() {
  return (
    <main
      style={{
        // Fluid, not fixed: the audience for a mobile guitar app is on a phone.
        maxWidth: 'var(--lk-content-max-width)',
        margin: '0 auto',
        padding: 'var(--lk-space-6)',
        minHeight: '100vh',
        display: 'grid',
        alignContent: 'center',
        gap: 'var(--lk-space-8)',
      }}
    >
      <p
        style={{
          margin: 0,
          fontFamily: 'var(--lk-font-mono)',
          fontSize: 'var(--lk-size-technical)',
          letterSpacing: 'var(--lk-tracking-technical)',
          textTransform: 'uppercase',
          color: 'var(--lk-text-secondary)',
        }}
      >
        [ Tune . Learn . Practice . Play ]
      </p>

      <h1
        style={{
          // clamp() keeps the hero readable from small phones to desktop
          // without hardcoding a screen size (DESIGN.md §43).
          fontSize: 'clamp(2.5rem, 9vw, var(--lk-size-display-xl))',
          lineHeight: 'var(--lk-line-height-display-xl)',
          letterSpacing: 'var(--lk-tracking-display-xl)',
          textTransform: 'uppercase',
          textWrap: 'balance',
        }}
      >
        Your guitar.
        <br />
        Your music.
        <br />
        Anywhere.
      </h1>

      <p
        style={{
          margin: 0,
          maxWidth: '38ch',
          fontSize: 'var(--lk-size-body-large)',
          lineHeight: 'var(--lk-line-height-body-large)',
          color: 'var(--lk-text-secondary)',
        }}
      >
        A Myanmar-first guitar companion. Tuner, chords, songs, fretboard and
        practice tools — most of it working with no connection at all.
      </p>

      <div>
        <a
          href="#download"
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: 'var(--lk-tap-target)',
            padding: '0 var(--lk-space-8)',
            background: 'var(--lk-accent)',
            color: 'var(--lk-accent-on)',
            // Orange is 2.92:1 on the light ground, so the boundary is the
            // border and shadow — never the fill alone (DESIGN.md §42).
            border: 'var(--lk-border-default) solid var(--lk-border)',
            boxShadow: 'var(--lk-shadow-default)',
            fontFamily: 'var(--lk-font-display)',
            fontSize: 'var(--lk-size-body-large)',
            textTransform: 'uppercase',
            textDecoration: 'none',
          }}
        >
          Download app
        </a>
      </div>
    </main>
  );
}
