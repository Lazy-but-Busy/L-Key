const { AppChip } = window.LKeyDesignSystem_355d7c;
const { PlayGlyph, Icon: SvIcon } = window.LKGlyphs;

const SECTIONS = [
  { label: "[INTRO]", lines: [{ chords: [{ n: "G", x: 0 }, { n: "C", x: 84 }, { n: "Em", x: 168 }, { n: "D", x: 252 }], lyric: "" }] },
  { label: "[VERSE 1]", lines: [
    { chords: [{ n: "G", x: 0 }, { n: "C", x: 136.73 }], lyric: "Waking up to the sound of the rain\nfalling down" },
    { chords: [{ n: "Em", x: 0 }, { n: "D", x: 140.45 }], lyric: "Grab my old six-string, playing it loud" },
    { chords: [{ n: "G", x: 0 }, { n: "C", x: 132.2 }], lyric: "Coffee on the table, cold in the cup" },
    { chords: [{ n: "Em", x: 0 }, { n: "D", x: 146.9 }], lyric: "Trying to find the words to sum it all up" },
  ] },
  { label: "[CHORUS]", lines: [
    { chords: [{ n: "C", x: 0 }, { n: "G", x: 120.5 }], lyric: "Oh, this acoustic guitar song" },
    { chords: [{ n: "Em", x: 0 }, { n: "D", x: 128.9 }], lyric: "Carries me right back where I belong" },
    { chords: [{ n: "C", x: 0 }, { n: "G", x: 132.4 }], lyric: "Through the highs and the lows, we sing along" },
    { chords: [{ n: "D", x: 0 }], lyric: "Just me and this acoustic guitar song" },
  ] },
];

function ChordChip({ children }) {
  return (
    <span style={{ display: "inline-flex", height: 35, padding: "0 6px", boxSizing: "border-box", background: "var(--lk-overlay-chord)", boxShadow: "var(--lk-shadow-sm)", fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 14, lineHeight: "35px" }}>{children}</span>
  );
}

function SongViewerScreen({ transpose = 0, onTranspose, autoScroll, onAutoScroll }) {
  return (
    <div style={{ position: "relative" }}>
      <div style={{ padding: "32px 16px 32px", display: "flex", flexDirection: "column", gap: 32 }}>
        <div style={{ background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: "23px 24px 24px", boxSizing: "border-box", display: "flex", flexDirection: "column", gap: 16 }}>
          <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 24, lineHeight: "28.8px", textTransform: "uppercase" }}>ACOUSTIC GUITAR SONG</span>
          <div style={{ display: "flex", gap: 16, justifyContent: "center", padding: "16px 0 0", borderTop: "2px solid var(--lk-divider)" }}>
            <AppChip label="KEY">G Major</AppChip>
            <AppChip label="CAPO">2nd Fret</AppChip>
            <AppChip label="BPM" icon={<SvIcon name="heart" w={13.333} h={12.233} />}>92</AppChip>
          </div>
        </div>
        <div style={{ background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: "24px 24px 48px", boxSizing: "border-box", display: "flex", flexDirection: "column", gap: 24 }}>
          {SECTIONS.map((s) => (
            <div key={s.label} style={{ display: "flex", flexDirection: "column" }}>
              <div style={{ borderBottom: "2px solid var(--lk-divider)", paddingBottom: 4, marginBottom: 8 }}>
                <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", textTransform: "uppercase", color: "var(--lk-grey-500)" }}>{s.label}</span>
              </div>
              {s.lines.map((line, i) => (
                <div key={i} style={{ marginBottom: line.lyric ? 4 : 0 }}>
                  <div style={{ position: "relative", height: 44 }}>
                    {line.chords.map((c) => (
                      <span key={c.n + c.x} style={{ position: "absolute", left: c.x, top: 6 }}><ChordChip>{c.n}</ChordChip></span>
                    ))}
                  </div>
                  {line.lyric ? (
                    <div style={{ fontFamily: "var(--lk-font-body)", fontWeight: 400, fontSize: 18, lineHeight: "28.8px", whiteSpace: "pre-line" }}>{line.lyric}</div>
                  ) : null}
                </div>
              ))}
            </div>
          ))}
        </div>
      </div>
      <div style={{ position: "sticky", bottom: 0, background: "var(--lk-fill-chip)", borderTop: "2px solid var(--lk-divider)", padding: 16, boxSizing: "border-box" }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 8 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8, height: 44, padding: 4, boxSizing: "border-box", background: "var(--lk-white)", boxShadow: "var(--lk-ring-shadow-sm)" }}>
            <span style={{ paddingRight: 8, borderRight: "2px solid var(--lk-black)", fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", textTransform: "uppercase", paddingLeft: 8 }}>TRANSPOSE</span>
            <button type="button" onClick={() => onTranspose && onTranspose(-1)} aria-label="Transpose down" style={{ appearance: "none", border: "none", cursor: "pointer", width: 32, height: 32, background: "var(--lk-black)", boxShadow: "var(--lk-ring)", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <svg width="14" height="2" viewBox="0 0 14 2" fill="#fff"><path d="M 0 2 L 0 0 L 14 0 L 14 2 L 0 2 Z" /></svg>
            </button>
            <span style={{ width: 32, textAlign: "center", fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 14, lineHeight: "19.6px" }}>{transpose > 0 ? "+" + transpose : transpose}</span>
            <button type="button" onClick={() => onTranspose && onTranspose(1)} aria-label="Transpose up" style={{ appearance: "none", border: "none", cursor: "pointer", width: 32, height: 32, background: "var(--lk-black)", boxShadow: "var(--lk-ring)", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <svg width="14" height="14" viewBox="0 0 14 14" fill="#fff"><path d="M 6 8 L 0 8 L 0 6 L 6 6 L 6 0 L 8 0 L 8 6 L 14 6 L 14 8 L 8 8 L 8 14 L 6 14 L 6 8 Z" /></svg>
            </button>
          </div>
          <button type="button" onClick={onAutoScroll} style={{ appearance: "none", border: "none", cursor: "pointer", width: 118.42, height: 59.19, boxSizing: "border-box", background: autoScroll ? "var(--lk-black)" : "var(--lk-orange)", color: autoScroll ? "var(--lk-white)" : "var(--lk-black)", boxShadow: "var(--lk-ring-shadow)", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
            <PlayGlyph c={autoScroll ? "#fff" : "#000"} />
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 14, lineHeight: "19.6px", textAlign: "center", whiteSpace: "pre-line" }}>{"AUTO-\nSCROLL"}</span>
          </button>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { LKMobileSongViewer: SongViewerScreen });
