const { DataTable, StatusBadge, StatCard, FilterBar, AppButton, AppTextField, AppChip, AdminHeader, ConfirmDialog, PremiumBadge } = window.LKeyDesignSystem_355d7c;
const PIcon = window.LKAdminIcon;

/* ——— User management (DESIGN.md §Admin Portal → User Management). ——— */
const USERS = [
  { id: "#U-1042", name: "Kyaw Zin", plan: "Pro", joined: "2026-03-14", active: "Today", status: "published", word: "Active" },
  { id: "#U-1041", name: "May Thu", plan: "Free", joined: "2026-03-12", active: "Yesterday", status: "published", word: "Active" },
  { id: "#U-0977", name: "J. Smith", plan: "Pro", joined: "2026-01-30", active: "3d ago", status: "draft", word: "Inactive" },
  { id: "#U-0871", name: "Aung Ko", plan: "Free", joined: "2025-11-02", active: "41d ago", status: "failed", word: "Suspended" },
];
function UsersScreen() {
  const [filters, setFilters] = React.useState({ plan: "All", status: "All" });
  const [confirm, setConfirm] = React.useState(null);
  const rows = USERS.filter((u) => (filters.plan === "All" || u.plan === filters.plan) && (filters.status === "All" || u.word === filters.status));
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <AdminHeader size="lg" title="User Management" subtitle="Search, subscriptions, activity, suspension."
        actions={<div style={{ width: 320 }}><AppTextField placeholder="Search name or ID..." icon={<PIcon name="search" w={18} h={18} />} /></div>} />
      <FilterBar
        groups={[{ key: "plan", label: "Plan", options: ["All", "Pro", "Free"] }, { key: "status", label: "Status", options: ["All", "Active", "Inactive", "Suspended"] }]}
        activeValues={filters} onChange={(k, v) => setFilters({ ...filters, [k]: v })}
        trailing={<span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, color: "var(--lk-grey-500)" }}>{rows.length} of 12,542 users</span>} />
      <DataTable
        columns={[
          { key: "id", label: "ID", width: 110, strong: true },
          { key: "name", label: "User", font: "body", strong: true },
          { key: "plan", label: "Plan", width: 96 },
          { key: "joined", label: "Joined", width: 130 },
          { key: "active", label: "Last Active", width: 130 },
          { key: "status", label: "Status", width: 140 },
          { key: "actions", label: "Actions", width: 130, align: "center" },
        ]}
        rows={rows.map((u) => ({
          id: u.id, name: u.name,
          plan: u.plan === "Pro" ? <PremiumBadge size="sm" /> : <AppChip variant="tag">Free</AppChip>,
          joined: u.joined, active: u.active,
          status: <StatusBadge status={u.status}>{u.word}</StatusBadge>,
          actions: u.word === "Suspended"
            ? <AppButton size="sm" variant="secondary" onClick={() => setConfirm({ u, restore: true })}>Restore</AppButton>
            : <AppButton size="sm" variant="secondary" onClick={() => setConfirm({ u })}>Suspend</AppButton>,
        }))}
        footerNote="Showing 4 of 12,542 users"
        pagination={<><AppButton size="sm" variant="primary">1</AppButton><AppButton size="sm" variant="secondary">2</AppButton><AppButton size="sm" variant="secondary">Next ›</AppButton></>} />
      {confirm ? (
        <div style={{ position: "fixed", inset: 0, zIndex: 10 }}>
          <ConfirmDialog open destructive={!confirm.restore}
            title={confirm.restore ? "Restore user?" : "Suspend user?"}
            body={confirm.u.name + " (" + confirm.u.id + ") will " + (confirm.restore ? "regain access immediately." : "lose access until restored. Their data is kept.")}
            confirmLabel={confirm.restore ? "Restore" : "Suspend"}
            onConfirm={() => setConfirm(null)} onCancel={() => setConfirm(null)} style={{ height: "100%" }} />
        </div>
      ) : null}
    </div>
  );
}

/* ——— Payments (DESIGN.md §56). Status shown as word + dot, backend is truth. ——— */
const PAYMENTS = [
  { id: "ORD-8021", user: "Kyaw Zin", plan: "Yearly", amount: "25,000", provider: "MyanMyanPay", ref: "MMP-99811", status: "published", word: "Complete", time: "08:31" },
  { id: "ORD-8020", user: "May Thu", plan: "Monthly", amount: "2,500", provider: "MyanMyanPay", ref: "MMP-99807", status: "pending", word: "Pending", time: "08:22" },
  { id: "ORD-8019", user: "Aung Ko", plan: "Yearly", amount: "25,000", provider: "MyanMyanPay", ref: "MMP-99794", status: "failed", word: "Failed", time: "07:58" },
  { id: "ORD-8018", user: "S. Win", plan: "Monthly", amount: "2,500", provider: "MyanMyanPay", ref: "MMP-99790", status: "published", word: "Complete", time: "07:12" },
];
function PaymentsScreen() {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
      <AdminHeader size="lg" title="Payments" subtitle="MMQR orders, provider references and webhook state."
        actions={<AppButton size="md" variant="secondary" icon={<PIcon name="download" w={14} h={14} />}>Export CSV</AppButton>} />
      <div style={{ display: "flex", gap: 16 }}>
        <StatCard label="Revenue (30d)" value="4.2M" note="MMK" icon={<PIcon name="history-clock" w={16} h={16} />} />
        <StatCard label="Successful" value="182" delta="+11%" ornament="square" />
        <StatCard label="Failed" value="9" note="webhook mismatches: 0" ornament="none" />
      </div>
      <DataTable
        columns={[
          { key: "id", label: "Order", width: 120, strong: true },
          { key: "user", label: "User", font: "body" },
          { key: "plan", label: "Plan", width: 100 },
          { key: "amount", label: "MMK", width: 100, align: "right" },
          { key: "provider", label: "Provider", width: 140 },
          { key: "ref", label: "Ref", width: 120 },
          { key: "status", label: "Status", width: 130 },
          { key: "time", label: "Time", width: 90 },
        ]}
        rows={PAYMENTS.map((p) => ({ ...p, status: <StatusBadge status={p.status}>{p.word}</StatusBadge> }))}
        footerNote="Showing 4 of 191 orders this month" />
    </div>
  );
}

Object.assign(window, { LKAdminUsers: UsersScreen, LKAdminPayments: PaymentsScreen });
