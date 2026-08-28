const { AppButton } = window.LKeyDesignSystem_355d7c;

const WebIcon = ({ name, w, h }) => <img src={"../../assets/icons/" + name + ".svg"} width={w} height={h || w} alt="" style={{ display: "block" }} />;
const TuneGlyph = () => <svg width="27" height="27" viewBox="0 0 27 27" fill="#fff"><path d="M 12 27 L 12 18 L 15 18 L 15 21 L 27 21 L 27 24 L 15 24 L 15 27 L 12 27 M 0 24 L 0 21 L 9 21 L 9 24 L 0 24 M 6 18 L 6 15 L 0 15 L 0 12 L 6 12 L 6 9 L 9 9 L 9 18 L 6 18 M 12 15 L 12 12 L 27 12 L 27 15 L 12 15 M 18 9 L 18 0 L 21 0 L 21 3 L 27 3 L 27 6 L 21 6 L 21 9 L 18 9 M 0 6 L 0 3 L 15 3 L 15 6 L 0 6 Z" /></svg>;
const DownloadGlyph = () => <svg width="16" height="16" viewBox="0 0 16 16" fill="#000"><path d="M 8 12 L 3 7 L 4.4 5.55 L 7 8.15 L 7 0 L 9 0 L 9 8.15 L 11.6 5.55 L 13 7 L 8 12 M 2 16 C 1.45 16 0.979 15.804 0.587 15.413 C 0.196 15.021 0 14.55 0 14 L 0 11 L 2 11 L 2 14 L 14 14 L 14 11 L 16 11 L 16 14 C 16 14.55 15.804 15.021 15.413 15.413 C 15.021 15.804 14.55 16 14 16 L 2 16 Z" /></svg>;

const CARD_TITLE = { fontFamily: "var(--lk-font-display)", fontWeight: 400, fontSize: 16, lineHeight: "24px" };
const CARD_DESC = { fontFamily: "var(--lk-font-body)", fontWeight: 400, fontSize: 16, lineHeight: "24px", color: "var(--lk-grey-500)", whiteSpace: "pre-line" };

function Hero() {
  return (
    <section style={{ position: "relative", overflow: "hidden", minHeight: 695.39, padding: "127.39px 24px 128px", boxSizing: "border-box", display: "flex", flexDirection: "column", justifyContent: "center", alignItems: "center" }}>
      <div style={{ position: "absolute", left: 0, top: 0, width: "100%", height: 695.17, opacity: 0.1, background: "radial-gradient(905.097px 491.559px at 50% 50%, rgb(0,0,0) 9.43%, rgba(0,0,0,0) 9.43%)" }} />
      <div style={{ position: "relative", width: 557.04, maxWidth: 896, display: "flex", flexDirection: "column", gap: 32, alignItems: "center" }}>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 400, fontSize: 96, lineHeight: "86.4px", letterSpacing: "-4.8px", textAlign: "center", textTransform: "uppercase", whiteSpace: "pre-line" }}>{"YOUR GUITAR.\nYOUR MUSIC.\nANYWHERE."}</span>
        <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 20, lineHeight: "28px", letterSpacing: "2px", textTransform: "uppercase" }}>[ TUNE . LEARN . PRACTICE . PLAY ]</span>
        <div style={{ padding: "32px 0" }}>
          <AppButton variant="accent" size="xl" icon={<DownloadGlyph />}>Download App</AppButton>
        </div>
      </div>
    </section>
  );
}

function BentoGrid() {
  return (
    <section style={{ width: 1232, display: "grid", gridTemplateRows: "368px 236px", gridTemplateColumns: "repeat(12, 1fr)", gap: 24 }}>
      <div style={{ gridColumn: "1 / span 8", background: "var(--lk-paper)", boxShadow: "var(--lk-shadow)", padding: 32, boxSizing: "border-box", display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", paddingBottom: 32 }}>
          <div style={{ display: "flex", flexDirection: "column", gap: 8, width: 417.75 }}>
            <span style={CARD_TITLE}>PRECISION TUNER</span>
            <span style={CARD_DESC}>{"Studio-grade accuracy in your pocket. Features chromatic,\nalternate tunings, and polyphonic mode."}</span>
          </div>
          <div style={{ width: 64, height: 64, borderRadius: "var(--lk-radius-pill)", background: "var(--lk-black)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}><TuneGlyph /></div>
        </div>
        <div style={{ position: "relative", height: 192, background: "var(--lk-paper)" }}>
          <div style={{ position: "absolute", left: 16, top: 10, display: "flex", alignItems: "baseline" }}>
            <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 400, fontSize: 16, lineHeight: "24px" }}>E</span>
            <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 400, fontSize: 24, lineHeight: "32px", color: "var(--lk-text-tertiary)" }}>2</span>
          </div>
          <div style={{ position: "absolute", right: 16, top: 24, height: 32, background: "var(--lk-black)", padding: "4px 8px", boxSizing: "border-box" }}>
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 400, fontSize: 16, lineHeight: "24px", color: "var(--lk-white)" }}>82.4 Hz</span>
          </div>
          <div style={{ position: "absolute", left: "53%", top: 60, width: 4, height: 128, background: "var(--lk-orange)", transform: "rotate(15deg)", transformOrigin: "50% 100%" }} />
          <div style={{ position: "absolute", left: 0, bottom: 8, width: "100%", padding: "0 16px", boxSizing: "border-box", display: "flex", justifyContent: "space-between" }}>
            {["-50", "0", "+50"].map((t) => (
              <span key={t} style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-text-tertiary)" }}>{t}</span>
            ))}
          </div>
        </div>
      </div>
      <div style={{ gridColumn: "9 / span 4", height: 304, background: "var(--lk-black)", boxShadow: "var(--lk-shadow)", padding: 32, boxSizing: "border-box", display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          <span style={{ ...CARD_TITLE, color: "var(--lk-white)" }}>METRONOME</span>
          <span style={{ ...CARD_DESC, color: "var(--lk-grey-300)" }}>Complex polyrhythms made simple.</span>
        </div>
        <div style={{ padding: "32px 0", display: "flex", flexDirection: "column", alignItems: "center" }}>
          <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 400, fontSize: 72, lineHeight: "72px", color: "var(--lk-white)" }}>120</span>
          <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 400, fontSize: 16, lineHeight: "24px", letterSpacing: "1.6px", textTransform: "uppercase", color: "var(--lk-orange)" }}>BPM</span>
          <div style={{ padding: "24px 0", display: "flex", gap: 8 }}>
            {[0, 1, 2, 3].map((i) => <div key={i} style={{ width: 16, height: 16, borderRadius: "var(--lk-radius-pill)", background: "var(--lk-orange)" }} />)}
          </div>
        </div>
      </div>
      <div style={{ gridColumn: "1 / span 6", height: 225, position: "relative", overflow: "hidden", background: "var(--lk-paper)", boxShadow: "var(--lk-shadow)", padding: 32, boxSizing: "border-box" }}>
        <div style={{ position: "absolute", left: 436, top: 7, width: 200, height: 250, opacity: 0.1, display: "grid", gridTemplateColumns: "160px", gridAutoRows: "180px", overflow: "hidden" }}>
          {[0, 1].map((i) => <div key={i} style={{ width: 160, height: 180, boxShadow: "inset 0 0 0 2px var(--lk-black)" }} />)}
        </div>
        <div style={{ position: "relative", display: "flex", flexDirection: "column", gap: 24 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <span style={CARD_TITLE}>CHORD LIBRARY</span>
            <WebIcon name="library-music-lg" w={25} h={25} />
          </div>
          <span style={{ ...CARD_DESC, maxWidth: 384 }}>{"Over 10,000 voicings. Discover new shapes and\ninversions instantly."}</span>
          <div style={{ display: "flex", gap: 8, padding: "8px 0" }}>
            {["Cmaj7", "Am9", "G13"].map((c) => (
              <span key={c} style={{ height: 32, background: "var(--lk-orange)", padding: "4px 12px", boxSizing: "border-box", fontFamily: "var(--lk-font-mono)", fontWeight: 400, fontSize: 16, lineHeight: "24px" }}>{c}</span>
            ))}
          </div>
        </div>
      </div>
      <div style={{ gridColumn: "7 / span 6", height: 224, background: "var(--lk-paper)", boxShadow: "var(--lk-shadow)", padding: 32, boxSizing: "border-box", display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", paddingBottom: 24 }}>
          <span style={CARD_TITLE}>PRACTICE TOOLS</span>
          <WebIcon name="graduation-cap" w={27.5} h={22.5} />
        </div>
        <span style={{ ...CARD_DESC, paddingBottom: 32 }}>{"Track your progress, build routines, and master the fretboard with\ninteractive drills."}</span>
        <div style={{ height: 32, background: "var(--lk-paper)", display: "flex", alignItems: "center" }}>
          <div style={{ width: "65%", height: "100%", background: "var(--lk-orange)", padding: "0 8px", boxSizing: "border-box", display: "flex", alignItems: "center" }}>
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 16, lineHeight: "24px" }}>LEVEL 42</span>
          </div>
        </div>
      </div>
    </section>
  );
}

function LandingScreen() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 64, alignItems: "center", padding: "0 0 112px" }}>
      <Hero />
      <BentoGrid />
    </div>
  );
}

Object.assign(window, { LKWebLanding: LandingScreen, LKWebIcon: WebIcon });
