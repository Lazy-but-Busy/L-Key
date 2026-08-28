const { ContentEditor, DataTable, StatusBadge, AppButton, AppTextField, AppChip, AdminHeader, PremiumBadge } = window.LKeyDesignSystem_355d7c;
const CIcon = window.LKAdminIcon;

const Select = ({ label, value, options, onChange }) => (
  <label style={{ display: "flex", flexDirection: "column", gap: 4 }}>
    <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", textTransform: "uppercase", color: "var(--lk-text-technical)" }}>{label}</span>
    <select value={value} onChange={(e) => onChange && onChange(e.target.value)} style={{ appearance: "none", border: "none", boxSizing: "border-box", minHeight: 45.59, padding: "12px", background: "var(--lk-surface)", boxShadow: "var(--lk-ring-hairline),var(--lk-shadow)", borderRadius: 0, fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14 }}>
      {options.map((o) => <option key={o}>{o}</option>)}
    </select>
  </label>
);

/* ——— Song editor (DESIGN.md §49–51). Sections incl. Rights; publish is explicit. ——— */
function SongEditorScreen({ song, onBack }) {
  const s = song || { id: "#8022", title: "Rainy Yangon", artist: "Sai Sai", status: "draft" };
  const [form, setForm] = React.useState({
    title: s.title, artist: s.artist, language: "Myanmar", genre: "Pop",
    key: "G", capo: "2", bpm: "92", difficulty: "Beginner",
    chords: "[VERSE 1]\nG          C\nWaking up to the sound of the rain...",
    rightsHolder: "", source: "", permission: "Permission Required",
  });
  const [status, setStatus] = React.useState(s.status);
  const [saved, setSaved] = React.useState(null);
  const set = (k) => (v) => { setForm((f) => ({ ...f, [k]: v })); setSaved(null); };
  const setText = (k) => (e) => set(k)(e.target.value);

  // Re-seed when a different song is opened from the database.
  React.useEffect(() => {
    setForm((f) => ({ ...f, title: s.title, artist: s.artist }));
    setStatus(s.status);
    setSaved(null);
  }, [s.id, s.title, s.artist, s.status]);

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <AdminHeader size="lg" title="Song Editor" subtitle={"Editing " + s.id + " — drafts are never visible to players."}
        actions={<AppButton size="md" variant="secondary" onClick={onBack}>Back to Database</AppButton>} />
      <ContentEditor title="Song Information" status={<StatusBadge status={status} />}
        sections={[
          { title: "Basic Information", children: <>
            <AppTextField label="Title" value={form.title} onChange={setText("title")} />
            <AppTextField label="Artist" value={form.artist} onChange={setText("artist")} />
            <Select label="Language" value={form.language} onChange={set("language")} options={["Myanmar", "English"]} />
            <Select label="Genre" value={form.genre} onChange={set("genre")} options={["Pop", "Rock", "Acoustic", "Worship"]} />
          </> },
          { title: "Music Information", columns: 4, children: <>
            <Select label="Key" value={form.key} onChange={set("key")} options={["C", "D", "E", "G", "A", "Am", "Em"]} />
            <AppTextField label="Capo" value={form.capo} onChange={setText("capo")} />
            <AppTextField label="BPM" value={form.bpm} onChange={setText("bpm")} />
            <Select label="Difficulty" value={form.difficulty} onChange={set("difficulty")} options={["Beginner", "Intermediate", "Advanced"]} />
          </> },
          { title: "Chord Content", columns: 1, children:
            <textarea value={form.chords} onChange={setText("chords")} rows={5} aria-label="Chord content" style={{ resize: "vertical", border: "none", boxSizing: "border-box", padding: 12, background: "var(--lk-surface)", boxShadow: "var(--lk-ring-hairline),var(--lk-shadow)", fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "22px" }} />
          },
          { title: "Rights", children: <>
            <AppTextField label="Content Rights" placeholder="Rights holder" value={form.rightsHolder} onChange={setText("rightsHolder")} />
            <AppTextField label="Source" placeholder="Where this content came from" value={form.source} onChange={setText("source")} />
            <Select label="Permission Status" value={form.permission} onChange={set("permission")} options={["Licensed", "Owned", "Permission Required"]} />
          </> },
        ]}
        actions={<>
          {saved ? <span style={{ alignSelf: "center", marginRight: "auto", fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase", color: "var(--lk-text-secondary)" }}>{saved}</span> : null}
          <AppButton size="md" variant="ghost">Preview</AppButton>
          <AppButton size="md" variant="secondary" onClick={() => { setStatus("draft"); setSaved("Draft saved"); }}>Save Draft</AppButton>
          <AppButton size="md" variant="primary" onClick={() => { setStatus("published"); setSaved("Published"); }}>Publish</AppButton>
        </>} />
    </div>
  );
}

/* ——— Chords (DESIGN.md §52). Library table; live preview belongs to the editor. ——— */
const CHORDS = [
  { name: "C Major", formula: "1 3 5", notes: "C E G", voicings: 4, pro: false },
  { name: "A Minor", formula: "1 b3 5", notes: "A C E", voicings: 3, pro: false },
  { name: "G7", formula: "1 3 5 b7", notes: "G B D F", voicings: 5, pro: false },
  { name: "Cmaj9", formula: "1 3 5 7 9", notes: "C E G B D", voicings: 2, pro: true },
  { name: "F#m7b5", formula: "1 b3 b5 b7", notes: "F# A C E", voicings: 2, pro: true },
];
function ChordsScreen() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <AdminHeader size="lg" title="Chord Library" subtitle="Formulas, voicings and premium gating."
        actions={<AppButton size="md">Add Chord</AppButton>} />
      <DataTable
        columns={[
          { key: "name", label: "Chord", font: "body", strong: true },
          { key: "formula", label: "Formula", width: 160 },
          { key: "notes", label: "Notes", width: 160 },
          { key: "voicings", label: "Voicings", width: 110, align: "center" },
          { key: "tier", label: "Tier", width: 110 },
          { key: "actions", label: "Actions", width: 100, align: "center" },
        ]}
        rows={CHORDS.map((c) => ({
          name: c.name,
          formula: <span style={{ letterSpacing: "1.4px", fontWeight: 700 }}>{c.formula}</span>,
          notes: c.notes,
          voicings: c.voicings,
          tier: c.pro ? <PremiumBadge size="sm" /> : <AppChip variant="tag">Free</AppChip>,
          actions: <CIcon name="edit" w={15} h={15} />,
        }))}
        footerNote="Showing 5 of 214 chords" />
    </div>
  );
}

Object.assign(window, { LKAdminSongEditor: SongEditorScreen, LKAdminChords: ChordsScreen });
