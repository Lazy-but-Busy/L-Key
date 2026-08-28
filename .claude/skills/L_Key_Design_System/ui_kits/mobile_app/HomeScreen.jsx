const NS = window.LKeyDesignSystem_355d7c;
const { TopAppBar, AppIconButton, AppButton, AppCard, AppChip, SongCard, PracticeProgress, AppSectionHeader } = NS;

const HmIcon = ({ name, w = 20, h }) => <img src={"../../assets/icons/" + name + ".svg"} width={w} height={h || w} alt="" style={{ display: "block" }} />;

const MenuGlyph = () => <svg width="18" height="12" viewBox="0 0 18 12" fill="currentColor"><path d="M 0 12 L 0 10 L 18 10 L 18 12 L 0 12 M 0 7 L 0 5 L 18 5 L 18 7 L 0 7 M 0 2 L 0 0 L 18 0 L 18 2 L 0 2 Z" /></svg>;
const TuneGlyph = ({ s = 27, c = "#000" }) => <svg width={s} height={s} viewBox="0 0 27 27" fill={c}><path d="M 12 27 L 12 18 L 15 18 L 15 21 L 27 21 L 27 24 L 15 24 L 15 27 L 12 27 M 0 24 L 0 21 L 9 21 L 9 24 L 0 24 M 6 18 L 6 15 L 0 15 L 0 12 L 6 12 L 6 9 L 9 9 L 9 18 L 6 18 M 12 15 L 12 12 L 27 12 L 27 15 L 12 15 M 18 9 L 18 0 L 21 0 L 21 3 L 27 3 L 27 6 L 21 6 L 21 9 L 18 9 M 0 6 L 0 3 L 15 3 L 15 6 L 0 6 Z" /></svg>;
const PlayGlyph = ({ c = "#000" }) => <svg width="11" height="14" viewBox="0 0 11 14" fill={c}><path d="M 0 14 L 0 0 L 11 7 L 0 14 Z" /></svg>;
const ArrowGlyph = ({ c = "#fff" }) => <svg width="16" height="16" viewBox="0 0 16 16" fill={c}><path d="M 12.175 9 L 0 9 L 0 7 L 12.175 7 L 6.575 1.4 L 8 0 L 16 8 L 8 16 L 6.575 14.6 L 12.175 9 Z" /></svg>;
const PlusGlyph = () => <svg width="17.5" height="17.5" viewBox="0 0 17.5 17.5" fill="#000"><path d="M 7.5 10 L 0 10 L 0 7.5 L 7.5 7.5 L 7.5 0 L 10 0 L 10 7.5 L 17.5 7.5 L 17.5 10 L 10 10 L 10 17.5 L 7.5 17.5 L 7.5 10 Z" /></svg>;

function AppBar({ onMenu }) {
  return (
    <TopAppBar
      leading={<AppIconButton label="Menu" variant="plain" size={34} style={{ height: 28 }} onClick={onMenu}><MenuGlyph /></AppIconButton>}
      trailing={<AppIconButton label="Settings" variant="plain"><HmIcon name="settings" w={20.1} h={20} /></AppIconButton>} />
  );
}

function HomeScreen({ onOpenChord, onOpenSong, onTune, onPractice }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 32, padding: "0 24px 24px" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 400, fontSize: 24, lineHeight: "28.8px" }}>Good Morning,</span>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 400, fontSize: 36, lineHeight: "39.6px", textTransform: "uppercase" }}>GUITARIST!</span>
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
        <div onClick={onTune} style={{ minHeight: 200, background: "var(--lk-orange)", boxShadow: "var(--lk-shadow)", padding: 24, boxSizing: "border-box", display: "flex", flexDirection: "column", justifyContent: "space-between", cursor: "pointer" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
            <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 600, fontSize: 24, lineHeight: "28.8px" }}>Quick Tune</span>
            <TuneGlyph />
          </div>
          <div style={{ padding: "32px 0 0", display: "flex", justifyContent: "space-between", alignItems: "flex-end" }}>
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", textTransform: "uppercase" }}>STANDARD E</span>
            <AppIconButton label="Start tuner" variant="circle" size={48}><PlayGlyph /></AppIconButton>
          </div>
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
          {["Metronome", "Chords", "Scales"].map((t) => (
            <button key={t} type="button" onClick={t === "Chords" ? onOpenChord : undefined} style={{ appearance: "none", border: "none", cursor: "pointer", minHeight: 60, background: "var(--lk-white)", boxShadow: "var(--lk-shadow)", padding: 16, boxSizing: "border-box", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
              <span style={{ flex: 1, textAlign: "center", fontFamily: "var(--lk-font-display)", fontWeight: 600, fontSize: 18, lineHeight: "28px" }}>{t}</span>
              <HmIcon name="stack-pin" w={20} />
            </button>
          ))}
        </div>
      </div>
      <AppCard style={{ padding: "23px 24px 24px", gap: 0 }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
          <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 400, fontSize: 24, lineHeight: "28.8px" }}>Daily Session</span>
          <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 400, fontSize: 14, lineHeight: "19.6px", letterSpacing: "0.7px", textTransform: "uppercase", color: "var(--lk-grey-500)" }}>FOCUS: PENTATONIC SPEED</span>
          <div style={{ display: "flex", alignItems: "baseline", gap: 8, paddingTop: 9 }}>
            <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 36, lineHeight: "39.6px" }}>30:00</span>
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-grey-600)" }}>/ 60:00 MIN</span>
          </div>
        </div>
        <div style={{ padding: "16px 0", display: "flex", flexDirection: "column", gap: 12 }}>
          <PracticeProgress value={49} max={100} />
          <AppButton variant="primary" size="lg" block iconPosition="right" icon={<ArrowGlyph />} onClick={onPractice}>Resume</AppButton>
        </div>
      </AppCard>
      <div style={{ display: "flex", flexDirection: "column", gap: 23.99 }}>
        <AppSectionHeader title="Recent Riffs" actionLabel="View library" />
        <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
          <SongCard title="Master of Puppets" artist="METALLICA" tag="RHYTHM" bpm={120} cover="../../assets/images/song-cover-1.jpg" onClick={onOpenSong}
            action={<AppIconButton label="More" variant="bare" size={16} style={{ height: 35, padding: 0 }}><HmIcon name="more-vertical" w={4} h={16} /></AppIconButton>} />
          <SongCard title="Voodoo Child" artist="JIMI HENDRIX" tag="LEAD" bpm={85} bpmTone="muted" cover="../../assets/images/song-cover-2.jpg" onClick={onOpenSong}
            action={<AppIconButton label="More" variant="bare" size={16} style={{ height: 35, padding: 0 }}><HmIcon name="more-vertical-alt" w={4} h={16} /></AppIconButton>} />
          <div style={{ minHeight: 220, background: "var(--lk-grey-100)", boxShadow: "var(--lk-shadow)", padding: "55.6px 24px", boxSizing: "border-box", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
            <div style={{ paddingBottom: 16 }}>
              <div style={{ width: 64, height: 64, borderRadius: "var(--lk-radius-pill)", background: "var(--lk-white)", boxShadow: "var(--lk-ring)", display: "flex", alignItems: "center", justifyContent: "center" }}><PlusGlyph /></div>
            </div>
            <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 600, fontSize: 24, lineHeight: "28.8px" }}>Import Tab</span>
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { LKMobileHome: HomeScreen, LKMobileAppBar: AppBar, LKGlyphs: { MenuGlyph, TuneGlyph, PlayGlyph, ArrowGlyph, PlusGlyph, Icon: HmIcon } });
