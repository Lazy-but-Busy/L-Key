const { AppTextField, SongCard, AppCard, AppChip, AppButton, AppIconButton, AppSectionHeader, PracticeProgress, EmptyState, PremiumBadge } = window.LKeyDesignSystem_355d7c;
const { Icon: SIcon } = window.LKGlyphs;

const H1s = ({ children }) => <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 36, lineHeight: "39.6px", letterSpacing: "-1.8px", textTransform: "uppercase" }}>{children}</span>;
const SUBs = ({ children }) => <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", letterSpacing: "0.7px", textTransform: "uppercase", color: "var(--lk-grey-500)" }}>{children}</span>;

/* ——— Song library (README.md → Songs: search, categories, favorites). ——— */
const LIB = [
  { title: "Master of Puppets", artist: "METALLICA", tag: "RHYTHM", bpm: 120, cover: "../../assets/images/song-cover-1.jpg" },
  { title: "Voodoo Child", artist: "JIMI HENDRIX", tag: "LEAD", bpm: 85, bpmTone: "muted", cover: "../../assets/images/song-cover-2.jpg" },
  { title: "Acoustic Guitar Song", artist: "L KEY ORIGINALS", tag: "FINGERSTYLE", bpm: 92, bpmTone: "muted" },
];
function SongLibraryScreen({ onOpenSong }) {
  const [q, setQ] = React.useState("");
  const [cat, setCat] = React.useState("All");
  const rows = LIB.filter((s) => (s.title + s.artist).toLowerCase().includes(q.toLowerCase()));
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, padding: "24px 24px 24px" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 6 }}><H1s>Songs</H1s><SUBs>42 songs · Myanmar + English</SUBs></div>
      <AppTextField placeholder="SEARCH SONGS..." value={q} onChange={(e) => setQ(e.target.value)} icon={<SIcon name="search" w={18} h={18} />} />
      <div style={{ display: "flex", boxShadow: "var(--lk-ring)", alignSelf: "flex-start" }}>
        {["All", "Myanmar", "English", "Favorites"].map((x) => (
          <button key={x} type="button" onClick={() => setCat(x)} style={{ appearance: "none", border: "none", cursor: "pointer", padding: "3.5px 12px", minHeight: 26.39, background: cat === x ? "var(--lk-black)" : "var(--lk-white)", color: cat === x ? "var(--lk-white)" : "var(--lk-grey-500)", fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", borderRight: "1px solid var(--lk-black)" }}>{x}</button>
        ))}
      </div>
      {cat === "Favorites" ? (
        <EmptyState align="left" headline="No favorites yet." body="Save something for later." />
      ) : (
        <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
          {rows.map((s) => (
            <SongCard key={s.title} {...s} onClick={onOpenSong}
              action={<AppIconButton label="More" variant="bare" size={16} style={{ height: 35, padding: 0 }}><SIcon name="more-vertical" w={4} h={16} /></AppIconButton>} />
          ))}
        </div>
      )}
    </div>
  );
}

/* ——— Learn (README.md → Learning: Course → Module → Lesson → Exercise). ——— */
const COURSES = [
  { label: "COURSE · 12 LESSONS", title: "Guitar Fundamentals", done: 7, total: 12 },
  { label: "COURSE · 9 LESSONS", title: "Open & Barre Chords", done: 2, total: 9 },
  { label: "COURSE · 8 LESSONS", title: "Rhythm & Strumming", done: 0, total: 8 },
  { label: "COURSE · 10 LESSONS", title: "CAGED System", done: 0, total: 10, pro: true },
];
function LearnScreen({ onPractice }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, padding: "24px 24px 24px" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 6 }}><H1s>Learn</H1s><SUBs>Course → module → lesson</SUBs></div>
      <AppCard tone="accent" label="CONTINUE · LESSON 8 OF 12" title="Barre Chord Basics" style={{ gap: 12 }}>
        <span style={{ fontFamily: "var(--lk-font-body)", fontWeight: 400, fontSize: 16, lineHeight: "24px" }}>Build the F major shape one finger at a time.</span>
        <AppButton variant="primary" size="lg" block onClick={onPractice}>Resume Lesson</AppButton>
      </AppCard>
      <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
        {COURSES.map((c) => (
          <AppCard key={c.title} variant="ring" padding={20} style={{ gap: 12 }}>
            <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
              <span style={{ display: "flex", alignItems: "center", gap: 8, fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", letterSpacing: "0.7px", textTransform: "uppercase", color: "var(--lk-grey-500)" }}>{c.label}{c.pro ? <PremiumBadge size="sm" /> : null}</span>
              <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 600, fontSize: 20, lineHeight: "30px" }}>{c.title}</span>
            </div>
            <PracticeProgress value={c.done} max={c.total} height={16} />
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-grey-600)" }}>{c.done} / {c.total} LESSONS</span>
          </AppCard>
        ))}
      </div>
    </div>
  );
}

/* ——— Practice (DESIGN.md §30–31). Session plan + streak, progress not decoration. ——— */
const PLAN = [
  { t: "CHORD SWITCHING", min: 10, done: true },
  { t: "PENTATONIC", min: 10, done: true },
  { t: "STRUMMING", min: 10, done: false },
];
function PracticeScreen() {
  const [started, setStarted] = React.useState(false);
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, padding: "24px 24px 24px" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 6 }}><H1s>Today's Practice</H1s><SUBs>Streak · 6 days</SUBs></div>
      <AppCard variant="ring" style={{ gap: 16 }}>
        <PracticeProgress value={20} max={30} elapsed="20:00" total="30:00 MIN" label="Session" />
        <div style={{ display: "flex", flexDirection: "column" }}>
          {PLAN.map((x) => (
            <div key={x.t} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 12, padding: "12px 0", borderBottom: "1px solid var(--lk-fill-ghost)" }}>
              <span style={{ display: "flex", alignItems: "center", gap: 10 }}>
                <span style={{ width: 16, height: 16, boxSizing: "border-box", boxShadow: "var(--lk-ring)", background: x.done ? "var(--lk-orange)" : "var(--lk-white)", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 10 }}>{x.done ? "✓" : ""}</span>
                <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 14, lineHeight: "19.6px" }}>{x.t}</span>
              </span>
              <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-grey-500)" }}>{x.min} MIN</span>
            </div>
          ))}
        </div>
        <AppButton variant={started ? "primary" : "accent"} size="lg" block onClick={() => setStarted(!started)}>{started ? "Pause" : "Start"}</AppButton>
      </AppCard>
      <div style={{ display: "flex", gap: 16 }}>
        <AppChip variant="bento" label="STREAK" style={{ flex: 1 }}>6 DAYS</AppChip>
        <AppChip variant="bento" label="THIS WEEK" style={{ flex: 1 }}>142 MIN</AppChip>
        <AppChip variant="bento" label="BEST BPM" style={{ flex: 1 }}>96</AppChip>
      </div>
      <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", textTransform: "uppercase", color: "var(--lk-text-tertiary)", textAlign: "center" }}>Weekly analytics · weak areas — <span style={{ background: "var(--lk-accent)", color: "var(--lk-accent-on)", fontWeight: 700, padding: "1px 5px" }}>PRO</span></span>
    </div>
  );
}

Object.assign(window, { LKSongLibrary: SongLibraryScreen, LKLearn: LearnScreen, LKPractice: PracticeScreen });
