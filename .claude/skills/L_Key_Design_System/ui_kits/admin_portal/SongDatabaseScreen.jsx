const { DataTable, StatusBadge, AppChip, AppButton, AppTextField, AppIconButton, AppSectionHeader } = window.LKeyDesignSystem_355d7c;
const Icon = window.LKAdminIcon;

const ROWS = [
  { id: "#8021", title: "Neon Skyline", artist: "The Midnight", key: "C#m", bpm: "118", status: "published" },
  { id: "#8022", title: "Rainy Yangon", artist: "Sai Sai", key: "A Mix", bpm: "105", status: "draft" },
  { id: "#8023", title: "Acoustic Guitar Song", artist: "L Key Originals", key: "E Maj", bpm: "85", status: "published" },
  { id: "#8024", title: "Slow Burn", artist: "Iron Cross", key: "D Min", bpm: "140", status: "archived" },
];

function SongDatabaseScreen({ onDelete, onEdit }) {
  const [query, setQuery] = React.useState("");
  const rows = ROWS.filter((r) => (r.id + r.title + r.artist).toLowerCase().includes(query.toLowerCase()));
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <div style={{ display: "flex", alignItems: "flex-end", justifyContent: "space-between", gap: 24, padding: "16px 0" }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
          <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 48, lineHeight: "52.8px", letterSpacing: "-0.96px", textTransform: "uppercase" }}>SONG DATABASE</span>
          <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", color: "var(--lk-grey-500)" }}>Manage library, metadata, and publication status.</span>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
          <div style={{ width: 320 }}>
            <AppTextField placeholder="Search ID, Title, Artist..." value={query} onChange={(e) => setQuery(e.target.value)} icon={<Icon name="search" w={18} h={18} />} />
          </div>
          <AppButton size="md" variant="primary" style={{ width: 189.22 }} icon={<svg width="14" height="14" viewBox="0 0 14 14" fill="#fff"><path d="M 6 8 L 0 8 L 0 6 L 6 6 L 6 0 L 8 0 L 8 6 L 14 6 L 14 8 L 8 8 L 8 14 L 6 14 L 6 8 Z" /></svg>}>Add New Song</AppButton>
        </div>
      </div>
      <DataTable
        columns={[
          { key: "id", label: "ID", width: 96, strong: false },
          { key: "title", label: "Title", font: "body" },
          { key: "artist", label: "Artist" },
          { key: "key", label: "Key", width: 96 },
          { key: "bpm", label: "BPM", width: 96 },
          { key: "status", label: "Status", width: 136 },
          { key: "actions", label: "Actions", width: 112, align: "center" },
        ]}
        rows={rows.map((r) => ({
          id: r.id,
          title: r.title,
          artist: r.artist,
          key: <AppChip variant="tag">{r.key}</AppChip>,
          bpm: r.bpm,
          status: <StatusBadge status={r.status} />,
          actions: (
            <span style={{ display: "flex", gap: 8 }}>
              <AppIconButton label="Edit" variant="bare" size={23} onClick={() => onEdit && onEdit(r)}><Icon name="edit" w={15} h={15} /></AppIconButton>
              <AppIconButton label="Delete" variant="bare" size={26} onClick={() => onDelete && onDelete(r)}><Icon name="trash" w={18.333} h={16.5} /></AppIconButton>
            </span>
          ),
        }))}
        footerNote={"Showing 1 to " + rows.length + " of 42 entries"}
        pagination={<>
          <AppButton size="sm" variant="secondary" style={{ opacity: 0.5 }}>&lt; Prev</AppButton>
          <AppButton size="sm" variant="primary">1</AppButton>
          <AppButton size="sm" variant="secondary">2</AppButton>
          <AppButton size="sm" variant="secondary">3</AppButton>
          <AppButton size="sm" variant="secondary">Next &gt;</AppButton>
        </>} />
    </div>
  );
}

Object.assign(window, { LKAdminSongDatabase: SongDatabaseScreen });
