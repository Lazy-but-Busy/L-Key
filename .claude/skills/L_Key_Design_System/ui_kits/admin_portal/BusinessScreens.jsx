const { DataTable, StatCard, StatusBadge, AppButton, AppChip, AdminHeader, FilterBar } = window.LKeyDesignSystem_355d7c;

/* ——— Premium plans (DESIGN.md §55). Four plans; every price change is audited.
   Only 25,000 MMK / Yearly is a sourced price — the rest are placeholders. ——— */
const PLANS = [
  { name: "Monthly", price: "2,500", duration: "30 days", best: false, available: true },
  { name: "3 Months", price: "7,000", duration: "90 days", best: false, available: true },
  { name: "Yearly", price: "25,000", duration: "365 days", best: true, available: true },
  { name: "Lifetime", price: "60,000", duration: "Forever", best: false, available: false },
];
function PremiumPlansScreen() {
  const [plans, setPlans] = React.useState(PLANS);
  const toggle = (i) => setPlans(plans.map((p, j) => (j === i ? { ...p, available: !p.available } : p)));
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <AdminHeader size="lg" title="Premium Plans" subtitle="Pricing, duration and availability. All changes are audited."
        actions={<AppButton size="md">New Plan</AppButton>} />
      <div style={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", gap: 16 }}>
        {plans.map((p, i) => (
          <div key={p.name} style={{ background: p.best ? "var(--lk-orange)" : "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: 20, boxSizing: "border-box", display: "flex", flexDirection: "column", gap: 10, opacity: p.available ? 1 : 0.55 }}>
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 12, lineHeight: "14.4px", letterSpacing: "0.7px", textTransform: "uppercase" }}>{p.name}{p.best ? " ⭐" : ""}</span>
            <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 36, lineHeight: "39.6px", letterSpacing: "-1.8px" }}>{p.price}</span>
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: p.best ? "var(--lk-black)" : "var(--lk-grey-500)" }}>MMK · {p.duration}</span>
            <div style={{ display: "flex", gap: 8, marginTop: 6 }}>
              <AppButton size="sm" variant="secondary" style={{ flex: 1 }}>Edit</AppButton>
              <AppButton size="sm" variant={p.available ? "primary" : "secondary"} style={{ flex: 1 }} onClick={() => toggle(i)}>{p.available ? "Live" : "Off"}</AppButton>
            </div>
          </div>
        ))}
      </div>
      <DataTable dense
        columns={[
          { key: "when", label: "When", width: 150 },
          { key: "who", label: "Admin", width: 140, font: "body" },
          { key: "what", label: "Change" },
        ]}
        rows={[
          { when: "2026-08-12 14:02", who: "Admin User", what: "Yearly price 22,000 → 25,000 MMK" },
          { when: "2026-07-30 09:41", who: "Admin User", what: "Lifetime plan disabled" },
          { when: "2026-07-02 11:15", who: "Admin User", what: "3 Months plan created" },
        ]}
        footerNote="Audit log — every pricing change is recorded" />
    </div>
  );
}

/* ——— Analytics (DESIGN.md §57). Minimal charts, primary metrics only. ——— */
const PRACTICE_BARS = [42, 55, 61, 48, 70, 88, 76];
const DAYS = ["M", "T", "W", "T", "F", "S", "S"];
function AnalyticsScreen() {
  const [range, setRange] = React.useState("7D");
  const max = Math.max(...PRACTICE_BARS);
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <AdminHeader size="lg" title="Analytics" subtitle="DAU, retention, practice and conversion — no decorative charts." />
      <FilterBar groups={[{ key: "range", label: "Range", options: ["7D", "30D", "90D"] }]} activeValues={{ range }} onChange={(k, v) => setRange(v)} />
      <div style={{ display: "flex", gap: 16 }}>
        <StatCard label="DAU" value="2,341" delta="+8.1%" ornament="none" />
        <StatCard label="MAU" value="9,802" delta="+5.4%" ornament="square" />
        <StatCard label="D7 Retention" value="41%" note="target 45%" ornament="none" />
        <StatCard label="Pro Conversion" value="9.6%" delta="+0.8%" ornament="circle" />
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "2fr 1fr", gap: 32 }}>
        <div style={{ background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: 24, boxSizing: "border-box", display: "flex", flexDirection: "column", gap: 24 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", paddingBottom: 16, borderBottom: "2px solid var(--lk-divider)" }}>
            <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 20, lineHeight: "30px" }}>Practice Minutes</span>
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, color: "var(--lk-grey-500)" }}>avg / user / day</span>
          </div>
          <div style={{ height: 220, background: "var(--lk-canvas)", boxShadow: "var(--lk-ring)", padding: 16, boxSizing: "border-box", display: "flex", alignItems: "flex-end", justifyContent: "center", gap: 12 }}>
            {PRACTICE_BARS.map((v, i) => (
              <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
                <div style={{ width: 44, height: (v / max) * 160, background: v === max ? "var(--lk-orange)" : "var(--lk-black)", boxShadow: "var(--lk-ring)" }} />
                <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 10, color: "var(--lk-text-tertiary)" }}>{DAYS[i]}</span>
              </div>
            ))}
          </div>
        </div>
        <DataTable dense
          columns={[{ key: "tool", label: "Popular Tools", font: "body" }, { key: "n", label: "Sessions", width: 110, align: "right", strong: true }]}
          rows={[
            { tool: "Tuner", n: "18,204" },
            { tool: "Chords", n: "11,873" },
            { tool: "Metronome", n: "7,410" },
            { tool: "Songs", n: "6,982" },
            { tool: "Scales", n: "3,551" },
          ]} />
      </div>
    </div>
  );
}

Object.assign(window, { LKAdminPlans: PremiumPlansScreen, LKAdminAnalytics: AnalyticsScreen });
