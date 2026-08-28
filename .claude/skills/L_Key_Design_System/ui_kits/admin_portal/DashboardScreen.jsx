const { StatCard, DataTable, AppButton, AppChip, StatusBadge } = window.LKeyDesignSystem_355d7c;

const DbIcon = ({ name, w = 18, h }) => <img src={"../../assets/icons/" + name + ".svg"} width={w} height={h || w} alt="" style={{ display: "block" }} />;

const BARS = [
  { h: 66, tone: "black", label: null },
  { h: 96, tone: "black", label: null },
  { h: 120, tone: "black", label: null },
  { h: 138, tone: "black", label: null },
  { h: 150, tone: "black", label: null },
  { h: 165, tone: "accent", label: "11.2k" },
  { h: 187, tone: "black", label: null },
  { h: 210, tone: "black", label: null },
];

function GrowthChart({ range, onRange }) {
  return (
    <div style={{ background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: "24px 24px 71.56px", boxSizing: "border-box", display: "flex", flexDirection: "column", gap: 24, gridColumn: "1 / span 2" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", paddingBottom: 16, borderBottom: "2px solid var(--lk-divider)" }}>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 20, lineHeight: "30px" }}>User Growth</span>
        <div style={{ display: "flex", gap: 8 }}>
          {["7D", "30D", "ALL"].map((r) => (
            <AppButton key={r} size="sm" variant={range === r ? "primary" : "secondary"} onClick={() => onRange(r)}>{r}</AppButton>
          ))}
        </div>
      </div>
      <div style={{ position: "relative", height: 256, background: "var(--lk-canvas)", boxShadow: "var(--lk-ring)", padding: 16, boxSizing: "border-box", display: "flex", alignItems: "flex-end", justifyContent: "center", gap: 8 }}>
        <div style={{ position: "absolute", left: 10, top: 10, height: 220, display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
          {["15k", "10k", "5k", "0"].map((t) => (
            <span key={t} style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 10, lineHeight: "14.4px", color: "var(--lk-text-tertiary)" }}>{t}</span>
          ))}
        </div>
        {BARS.map((b, i) => (
          <div key={i} style={{ position: "relative", width: 64.38, height: b.h, background: b.tone === "accent" ? "var(--lk-orange)" : "var(--lk-black)", boxShadow: b.tone === "accent" ? "var(--lk-ring),2px 0px 0px 0px var(--lk-black)" : "var(--lk-ring)" }}>
            {b.label ? (
              <div style={{ position: "absolute", left: 2.18, top: -30, height: 36, background: "var(--lk-black)", boxShadow: "var(--lk-ring)", padding: 4, boxSizing: "border-box" }}>
                <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 400, fontSize: 16, lineHeight: "24px", color: "var(--lk-white)" }}>{b.label}</span>
              </div>
            ) : null}
          </div>
        ))}
      </div>
    </div>
  );
}

function PaymentsPanel() {
  return (
    <div style={{ overflow: "hidden", background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", display: "flex", flexDirection: "column" }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: 24, borderBottom: "2px solid var(--lk-divider)" }}>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 20, lineHeight: "30px" }}>Recent Payments</span>
        <DbIcon name="more-horizontal" w={16} h={4} />
      </div>
      <div style={{ padding: "0 0 0 0" }}>
        <DataTable dense gridded style={{ gap: 0 }}
          columns={[{ key: "id", label: "ID", width: 78, strong: true }, { key: "user", label: "User", width: 78, strong: true }, { key: "plan", label: "Plan", width: 62, strong: true }, { key: "bar", label: "", width: 61, align: "center" }]}
          rows={[
            { id: "#8021", user: "J. Smith", plan: "Pro", bar: <div style={{ height: 12, width: "100%", background: "var(--lk-orange)", boxShadow: "var(--lk-ring)" }} /> },
            { id: "#8020", user: "K. Aung", plan: "Pro", bar: <div style={{ height: 12, width: "100%", background: "var(--lk-orange)", boxShadow: "var(--lk-ring)" }} /> },
            { id: "#8019", user: "M. Thant", plan: "Pro", bar: <div style={{ height: 12, width: "100%", background: "var(--lk-orange)", boxShadow: "var(--lk-ring)" }} /> },
            { id: "#8018", user: "S. Win", plan: "Pro", bar: <div style={{ height: 12, width: "100%", background: "var(--lk-orange)", boxShadow: "var(--lk-ring)" }} /> },
          ]} />
      </div>
      <div style={{ padding: 24, borderTop: "2px solid var(--lk-divider)" }}>
        <a href="#payments" style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", letterSpacing: "0.7px", textTransform: "uppercase" }}>View All Transactions</a>
      </div>
    </div>
  );
}

function DashboardScreen() {
  const [range, setRange] = React.useState("7D");
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 32 }}>
      <div style={{ display: "flex", alignItems: "flex-end", justifyContent: "space-between", gap: 24 }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 24, lineHeight: "28.8px", textTransform: "uppercase" }}>Dashboard</span>
          <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", color: "var(--lk-grey-500)" }}>Platform health, content and revenue at a glance.</span>
        </div>
        <div style={{ display: "flex", gap: 16 }}>
          <AppButton size="md" variant="secondary" icon={<DbIcon name="history-clock" w={14} h={14} />}>Last 7 days</AppButton>
          <AppButton size="md" variant="primary" icon={<DbIcon name="download" w={14} h={14} />}>Export Report</AppButton>
        </div>
      </div>
      <div style={{ display: "flex", gap: 16 }}>
        <StatCard label="Total Users" value="12,542" delta="+14.2%" icon={<DbIcon name="users" w={22} h={16} />} />
        <StatCard label="Active Today" value="2,341" delta="+8.1%" ornament="square" />
        <StatCard label="Premium" value="1,203" delta="+3.4%" />
        <StatCard label="Songs" value="4,892" note="+24 this week" icon={<DbIcon name="library-music" w={18} h={18} />} ornament="none" />
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 32 }}>
        <GrowthChart range={range} onRange={setRange} />
        <PaymentsPanel />
      </div>
    </div>
  );
}

Object.assign(window, { LKAdminDashboard: DashboardScreen, LKAdminIcon: DbIcon });
