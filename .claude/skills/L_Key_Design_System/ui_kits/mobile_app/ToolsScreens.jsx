const { TunerMeter, BpmDisplay, Fretboard, AppButton, AppChip, PremiumBadge, AppSectionHeader } = window.LKeyDesignSystem_355d7c;
const { Icon: TIcon } = window.LKGlyphs;

const H1 = ({ children }) => <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 36, lineHeight: "39.6px", letterSpacing: "-1.8px", textTransform: "uppercase" }}>{children}</span>;
const SUB = ({ children }) => <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", letterSpacing: "0.7px", textTransform: "uppercase", color: "var(--lk-grey-500)" }}>{children}</span>;

/* ——— Tools hub. Tool list per README.md feature set; PRO gating per DESIGN.md §32. ——— */
function ToolsHubScreen({ go }) {
  const TOOLS = [
    { t: "Tuner", view: "tuner" },
    { t: "Metronome", view: "metronome" },
    { t: "Chords", view: "chord" },
    { t: "Scales", view: "scales" },
    { t: "Transposer", view: "song" },
    { t: "Capo Assistant", view: "song" },
    { t: "Ear Training", pro: true },
    { t: "Recording", pro: true },
  ];
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, padding: "24px 24px 24px" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 6 }}><H1>Tools</H1><SUB>Precision utilities · offline</SUB></div>
      <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
        {TOOLS.map((x) => (
          <button key={x.t} type="button" onClick={() => !x.pro && x.view && go(x.view)} style={{ appearance: "none", border: "none", cursor: "pointer", minHeight: 60, background: "var(--lk-white)", boxShadow: "var(--lk-shadow)", padding: 16, boxSizing: "border-box", display: "flex", alignItems: "center", justifyContent: "space-between", gap: 12 }}>
            <span style={{ display: "flex", alignItems: "center", gap: 12 }}>
              <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 600, fontSize: 18, lineHeight: "28px" }}>{x.t}</span>
              {x.pro ? <PremiumBadge size="sm" /> : null}
            </span>
            <TIcon name="stack-pin" w={20} />
          </button>
        ))}
      </div>
    </div>
  );
}

/* ——— Tuner (DESIGN.md §21–22). Pick a string; the needle settles to lock. ——— */
const STRINGS = [
  { n: "E", o: 2, hz: 82.41 }, { n: "A", o: 2, hz: 110.0 }, { n: "D", o: 3, hz: 146.83 },
  { n: "G", o: 3, hz: 196.0 }, { n: "B", o: 3, hz: 246.94 }, { n: "E", o: 4, hz: 329.63 },
];
function TunerScreen() {
  const [sel, setSel] = React.useState(0);
  const [cents, setCents] = React.useState(-18);
  React.useEffect(() => {
    const id = setInterval(() => setCents((c) => (Math.abs(c) < 1 ? 0 : c * 0.72)), 160);
    return () => clearInterval(id);
  }, [sel]);
  const s = STRINGS[sel];
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, padding: "24px 24px 24px", alignItems: "center" }}>
      <div style={{ alignSelf: "stretch", display: "flex", flexDirection: "column", gap: 6 }}><H1>Tuner</H1><SUB>Microphone · standard tuning</SUB></div>
      <TunerMeter width={342} note={s.n} octave={s.o} frequency={s.hz * (1 + cents / 1731)} cents={Math.round(cents)} tuning="STANDARD" referencePitch={440} />
      <div style={{ display: "flex", gap: 8, alignSelf: "stretch", justifyContent: "center" }}>
        {STRINGS.map((x, i) => (
          <button key={i} type="button" onClick={() => { setSel(i); setCents(i % 2 ? 22 : -24); }} style={{
            appearance: "none", border: "none", cursor: "pointer", width: 48, height: 48, boxSizing: "border-box",
            background: i === sel ? "var(--lk-orange)" : "var(--lk-white)", boxShadow: i === sel ? "var(--lk-ring),var(--lk-shadow-sm)" : "var(--lk-ring)",
            fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 14, lineHeight: "19.6px",
          }}>{x.n}{x.o}</button>
        ))}
      </div>
      <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", textTransform: "uppercase", color: "var(--lk-text-tertiary)" }}>Chromatic · drop & open tunings — <span style={{ background: "var(--lk-accent)", color: "var(--lk-accent-on)", fontWeight: 700, padding: "1px 5px" }}>PRO</span></span>
    </div>
  );
}

/* ——— Metronome (DESIGN.md §27). Running state pulses the beat indicator. ——— */
function MetronomeScreen() {
  const [bpm, setBpm] = React.useState(120);
  const [sig, setSig] = React.useState("4/4");
  const [running, setRunning] = React.useState(false);
  const [beat, setBeat] = React.useState(0);
  const beats = Number(sig[0]);
  React.useEffect(() => {
    if (!running) return;
    const id = setInterval(() => setBeat((b) => (b + 1) % beats), 60000 / bpm);
    return () => clearInterval(id);
  }, [running, bpm, beats]);
  const taps = React.useRef([]);
  const tap = () => {
    const now = Date.now();
    taps.current = taps.current.filter((t) => now - t < 3000).concat(now);
    if (taps.current.length > 1) {
      const iv = (taps.current[taps.current.length - 1] - taps.current[0]) / (taps.current.length - 1);
      setBpm(Math.max(30, Math.min(240, Math.round(60000 / iv))));
    }
  };
  const Step = ({ d, label }) => (
    <button type="button" aria-label={label} onClick={() => setBpm((b) => Math.max(30, Math.min(240, b + d)))} style={{ appearance: "none", border: "none", cursor: "pointer", width: 48, height: 48, background: "var(--lk-black)", color: "var(--lk-white)", boxShadow: "var(--lk-ring)", fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 18 }}>{d > 0 ? "+" : "–"}</button>
  );
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, padding: "24px 24px 24px" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 6 }}><H1>Metronome</H1><SUB>Tap tempo · subdivisions</SUB></div>
      <div style={{ background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: 24, boxSizing: "border-box", display: "flex", flexDirection: "column", alignItems: "center", gap: 24 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
          <Step d={-4} label="Slower" />
          <div style={{ width: 170, textAlign: "center" }}>
            <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 64, lineHeight: "64px", letterSpacing: "-1.28px" }}>{bpm}</span>
            <div style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", letterSpacing: "0.7px", textTransform: "uppercase", color: "var(--lk-grey-500)" }}>BPM</div>
          </div>
          <Step d={4} label="Faster" />
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          {Array.from({ length: beats }).map((_, i) => (
            <div key={i} style={{ width: i === 0 ? 16 : 12, height: i === 0 ? 16 : 12, borderRadius: "var(--lk-radius-pill)", boxShadow: "var(--lk-ring)", background: running && i === beat ? (i === 0 ? "var(--lk-orange)" : "var(--lk-black)") : "transparent" }} />
          ))}
        </div>
        <div style={{ display: "flex", boxShadow: "var(--lk-ring)" }}>
          {["4/4", "3/4", "6/8"].map((x) => (
            <button key={x} type="button" onClick={() => { setSig(x); setBeat(0); }} style={{ appearance: "none", border: "none", cursor: "pointer", padding: "3.5px 12px", minHeight: 26.39, background: sig === x ? "var(--lk-black)" : "var(--lk-white)", color: sig === x ? "var(--lk-white)" : "var(--lk-grey-500)", fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", borderRight: "1px solid var(--lk-black)" }}>{x}</button>
          ))}
        </div>
        <div style={{ display: "flex", gap: 12, alignSelf: "stretch" }}>
          <AppButton variant="secondary" size="lg" style={{ flex: 1 }} onClick={tap}>Tap</AppButton>
          <AppButton variant={running ? "primary" : "accent"} size="lg" style={{ flex: 1 }} onClick={() => { setRunning(!running); setBeat(0); }}>{running ? "Stop" : "Start"}</AppButton>
        </div>
      </div>
      <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", textTransform: "uppercase", color: "var(--lk-text-tertiary)", textAlign: "center" }}>Progressive BPM · accents · sounds — <span style={{ background: "var(--lk-accent)", color: "var(--lk-accent-on)", fontWeight: 700, padding: "1px 5px" }}>PRO</span></span>
    </div>
  );
}

/* ——— Scales (DESIGN.md §25–26). A minor pentatonic, box 1; roots in orange. ——— */
const PENTA = [
  { string: 0, fret: 5, label: "A", root: true }, { string: 0, fret: 8, label: "C" },
  { string: 1, fret: 5, label: "E" }, { string: 1, fret: 8, label: "G" },
  { string: 2, fret: 5, label: "C" }, { string: 2, fret: 7, label: "E" },
  { string: 3, fret: 5, label: "G" }, { string: 3, fret: 7, label: "A", root: true },
  { string: 4, fret: 5, label: "D" }, { string: 4, fret: 7, label: "E" },
  { string: 5, fret: 5, label: "A", root: true }, { string: 5, fret: 8, label: "C" },
];
function ScalesScreen() {
  const [scale, setScale] = React.useState("Pentatonic");
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, padding: "24px 24px 24px" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 6 }}><H1>A Minor Pentatonic</H1><SUB>Box 1 · frets 5–8</SUB></div>
      <div style={{ display: "flex", boxShadow: "var(--lk-ring)", alignSelf: "flex-start" }}>
        {["Pentatonic", "Minor", "Blues"].map((x) => (
          <button key={x} type="button" onClick={() => setScale(x)} style={{ appearance: "none", border: "none", cursor: "pointer", padding: "3.5px 12px", minHeight: 26.39, background: scale === x ? "var(--lk-black)" : "var(--lk-white)", color: scale === x ? "var(--lk-white)" : "var(--lk-grey-500)", fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", borderRight: "1px solid var(--lk-black)" }}>{x}</button>
        ))}
      </div>
      <div style={{ display: "flex", gap: 16 }}>
        <AppChip variant="bento" label="FORMULA" style={{ flex: 1 }}>1 b3 4 5 b7</AppChip>
        <AppChip variant="bento" label="ROOT" style={{ flex: 1 }}>A</AppChip>
      </div>
      <div style={{ overflowX: "auto", margin: "0 -24px", padding: "0 24px 6px" }}>
        <Fretboard frets={10} fretWidth={40} rowHeight={34} markers={PENTA} />
      </div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 12 }}>
        <BpmDisplay size="md" bpm={80} beats={4} activeBeat={-1} timeSignature="4/4" />
        <AppButton variant="accent" size="lg">Practice</AppButton>
      </div>
    </div>
  );
}

Object.assign(window, { LKToolsHub: ToolsHubScreen, LKTuner: TunerScreen, LKMetronome: MetronomeScreen, LKScales: ScalesScreen });
