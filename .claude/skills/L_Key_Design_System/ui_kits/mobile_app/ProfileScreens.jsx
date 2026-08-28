const { AppCard, AppChip, AppButton, PremiumBadge, StatusBadge } = window.LKeyDesignSystem_355d7c;

const H1p = ({ children }) => <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 36, lineHeight: "39.6px", letterSpacing: "-1.8px", textTransform: "uppercase" }}>{children}</span>;
const MONO = (s = {}) => ({ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", ...s });

/* ——— Profile. Identity, stats, settings, Pro entry (DESIGN.md §36, §68). ——— */
function ProfileScreen({ go, pro }) {
  const [lang, setLang] = React.useState("EN");
  const [dark, setDark] = React.useState(false);
  const Row = ({ label, control }) => (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 12, padding: "14px 0", borderBottom: "1px solid var(--lk-fill-ghost)" }}>
      <span style={{ fontFamily: "var(--lk-font-body)", fontWeight: 600, fontSize: 16, lineHeight: "24px" }}>{label}</span>
      {control}
    </div>
  );
  const Seg = ({ value, options, onChange }) => (
    <div style={{ display: "flex", boxShadow: "var(--lk-ring)" }}>
      {options.map((o) => (
        <button key={o} type="button" onClick={() => onChange(o)} style={{ appearance: "none", border: "none", cursor: "pointer", padding: "3.5px 12px", minHeight: 26.39, background: value === o ? "var(--lk-black)" : "var(--lk-white)", color: value === o ? "var(--lk-white)" : "var(--lk-grey-500)", fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", borderRight: "1px solid var(--lk-black)" }}>{o}</button>
      ))}
    </div>
  );
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, padding: "24px 24px 24px" }}>
      <H1p>Profile</H1p>
      <div style={{ display: "flex", alignItems: "center", gap: 16, padding: 12, boxSizing: "border-box", background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)" }}>
        <div style={{ width: 48, height: 48, borderRadius: "var(--lk-radius-pill)", overflow: "hidden", boxShadow: "var(--lk-ring)", flexShrink: 0 }}>
          <img src="../../assets/images/admin-avatar.jpg" alt="" style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} />
        </div>
        <div style={{ display: "flex", flexDirection: "column", flex: 1 }}>
          <span style={{ display: "flex", alignItems: "center", gap: 8, fontFamily: "var(--lk-font-body)", fontWeight: 700, fontSize: 16, lineHeight: "24px" }}>Guitarist{pro ? <PremiumBadge size="sm" /> : null}</span>
          <span style={MONO({ fontSize: 12, lineHeight: "14.4px", color: "var(--lk-grey-500)" })}>Member since 2026</span>
        </div>
      </div>
      <div style={{ display: "flex", gap: 16 }}>
        <AppChip variant="bento" label="STREAK" style={{ flex: 1 }}>6 DAYS</AppChip>
        <AppChip variant="bento" label="PRACTICE" style={{ flex: 1 }}>14.2 HRS</AppChip>
        <AppChip variant="bento" label="SONGS" style={{ flex: 1 }}>18</AppChip>
      </div>
      {!pro ? (
        <div style={{ background: "var(--lk-orange)", boxShadow: "var(--lk-shadow)", padding: 24, boxSizing: "border-box", display: "flex", flexDirection: "column", gap: 12 }}>
          <span style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 24, lineHeight: "28.8px", textTransform: "uppercase" }}>Go Pro</span>
            <PremiumBadge tone="inverse" />
          </span>
          <span style={{ fontFamily: "var(--lk-font-body)", fontWeight: 400, fontSize: 16, lineHeight: "24px" }}>Unlock your complete guitar toolkit.</span>
          <AppButton variant="primary" size="lg" block onClick={() => go("paywall")}>See Plans</AppButton>
        </div>
      ) : (
        <div style={{ background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: 24, boxSizing: "border-box", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 20, lineHeight: "30px", textTransform: "uppercase" }}>Pro is active.</span>
          <StatusBadge status="published">Yearly</StatusBadge>
        </div>
      )}
      <AppCard variant="ring" padding={20} style={{ gap: 0 }}>
        <Row label="Language" control={<Seg value={lang} options={["MM", "EN"]} onChange={setLang} />} />
        <Row label="Dark mode" control={<Seg value={dark ? "ON" : "OFF"} options={["OFF", "ON"]} onChange={(v) => setDark(v === "ON")} />} />
        <Row label="Reference pitch" control={<span style={MONO({ fontWeight: 700 })}>440 Hz</span>} />
        <div style={{ paddingTop: 16 }}><AppButton variant="secondary" size="md" block>Sign Out</AppButton></div>
      </AppCard>
    </div>
  );
}

/* ——— Paywall (DESIGN.md §33). Capability list, plan pick, explicit continue. ——— */
const FEATURES = ["Advanced tuner", "Custom tunings", "Advanced chords", "CAGED", "Scale trainer", "Practice analytics", "AI Guitar Coach"];
function PaywallScreen({ go }) {
  const [plan, setPlan] = React.useState("yearly");
  const Plan = ({ id, name, price, star }) => (
    <button type="button" onClick={() => setPlan(id)} style={{ appearance: "none", border: "none", cursor: "pointer", textAlign: "left", flex: 1, padding: 16, boxSizing: "border-box", background: plan === id ? "var(--lk-orange)" : "var(--lk-white)", boxShadow: plan === id ? "var(--lk-ring),var(--lk-shadow-sm)" : "var(--lk-ring)", display: "flex", flexDirection: "column", gap: 4 }}>
      <span style={MONO({ fontWeight: 700, fontSize: 12, lineHeight: "14.4px", letterSpacing: "0.7px", textTransform: "uppercase" })}>{name}{star ? " ⭐" : ""}</span>
      <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 24, lineHeight: "28.8px" }}>{price}</span>
      <span style={MONO({ fontSize: 12, lineHeight: "14.4px", color: "var(--lk-grey-600)" })}>MMK</span>
    </button>
  );
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, padding: "24px 24px 24px" }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
        <H1p>Go Pro</H1p>
        <span style={{ fontFamily: "var(--lk-font-body)", fontWeight: 400, fontSize: 18, lineHeight: "28.8px", color: "var(--lk-grey-600)" }}>Unlock your complete guitar toolkit.</span>
      </div>
      <div style={{ background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: 24, boxSizing: "border-box", display: "flex", flexDirection: "column", gap: 10 }}>
        {FEATURES.map((f) => (
          <span key={f} style={MONO({ display: "flex", gap: 10 })}><span aria-hidden="true" style={{ color: "var(--lk-text)", fontWeight: 700 }}>✓</span>{f}</span>
        ))}
      </div>
      <div style={{ display: "flex", gap: 16 }}>
        <Plan id="monthly" name="Monthly" price="2,500" />
        <Plan id="yearly" name="Yearly" price="25,000" star />
      </div>
      <AppButton variant="primary" size="lg" block onClick={() => go("payment")}>Continue</AppButton>
      <span style={MONO({ fontSize: 12, lineHeight: "18px", color: "var(--lk-grey-500)", textAlign: "center" })}>Pay with KBZPay, AYA Pay, WavePay or any MMQR wallet. Cancel anytime.</span>
    </div>
  );
}

/* ——— Payment (DESIGN.md §34–35). MMQR flow; status comes from the backend, never claimed early. ——— */
function DemoQr() {
  // Deterministic placeholder pattern — NOT a scannable code.
  const cells = [];
  let seed = 7;
  for (let i = 0; i < 169; i++) { seed = (seed * 137 + 11) % 251; cells.push(seed % 3 !== 0); }
  const eye = (x, y) => (x < 4 && y < 4) || (x > 8 && y < 4) || (x < 4 && y > 8);
  return (
    <div style={{ width: 156, height: 156, padding: 10, boxSizing: "border-box", background: "var(--lk-white)", boxShadow: "var(--lk-ring)", display: "grid", gridTemplateColumns: "repeat(13,1fr)" }} aria-label="Demo QR placeholder">
      {cells.map((on, i) => {
        const x = i % 13, y = Math.floor(i / 13);
        return <div key={i} style={{ background: eye(x, y) ? ((x % 3 === 1 && y % 3 === 1) || x === 0 || y === 0 || x === 3 || y === 3 || x === 9 || y === 9 || x === 12 || y === 12 ? "var(--lk-black)" : "var(--lk-white)") : on ? "var(--lk-black)" : "var(--lk-white)" }} />;
      })}
    </div>
  );
}
function PaymentScreen({ go }) {
  const [stage, setStage] = React.useState("select"); // select → waiting → done
  const [left, setLeft] = React.useState(300);
  React.useEffect(() => {
    if (stage !== "waiting") return;
    const id = setInterval(() => setLeft((s) => Math.max(0, s - 1)), 1000);
    return () => clearInterval(id);
  }, [stage]);
  const mm = String(Math.floor(left / 60)).padStart(1, "0"), ss = String(left % 60).padStart(2, "0");
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, padding: "24px 24px 24px" }}>
      <H1p>Guitar Pro</H1p>
      <div style={{ background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: 24, boxSizing: "border-box", display: "flex", flexDirection: "column", gap: 16 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
          <span style={MONO({ letterSpacing: "0.7px", textTransform: "uppercase", color: "var(--lk-grey-500)" })}>Yearly</span>
          <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 24, lineHeight: "28.8px" }}>25,000 <span style={MONO({ fontSize: 12 })}>MMK</span></span>
        </div>
        <div style={{ borderTop: "2px solid var(--lk-divider)", paddingTop: 16, display: "flex", flexDirection: "column", gap: 16, alignItems: "center" }}>
          {stage === "select" ? (
            <>
              <AppChip variant="dark">[ MMQR ]</AppChip>
              <span style={MONO({ fontSize: 12, lineHeight: "18px", color: "var(--lk-grey-500)", textAlign: "center" })}>Scan with KBZPay / AYA Pay / WavePay / CB Pay</span>
              <AppButton variant="accent" size="lg" block onClick={() => { setStage("waiting"); setLeft(300); }}>Show QR</AppButton>
            </>
          ) : stage === "waiting" ? (
            <>
              <DemoQr />
              <span style={MONO({ fontWeight: 700, letterSpacing: "0.7px", textTransform: "uppercase" })}>Waiting for payment</span>
              <span style={MONO({ fontSize: 12, lineHeight: "18px", color: "var(--lk-grey-500)", textAlign: "center" })}>Complete payment in your selected mobile wallet.</span>
              <div style={{ display: "flex", gap: 16, alignSelf: "stretch" }}>
                <AppChip variant="bento" label="AMOUNT" style={{ flex: 1 }}>25,000 MMK</AppChip>
                <AppChip variant="bento" label="EXPIRES" style={{ flex: 1 }}>{mm}:{ss}</AppChip>
              </div>
              <div style={{ display: "flex", gap: 12, alignSelf: "stretch" }}>
                <AppButton variant="secondary" size="md" style={{ flex: 1 }} onClick={() => setStage("select")}>Cancel</AppButton>
                <AppButton variant="primary" size="md" style={{ flex: 1 }} onClick={() => setStage("done")}>Simulate Webhook</AppButton>
              </div>
            </>
          ) : (
            <>
              <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 24, lineHeight: "28.8px", textTransform: "uppercase", color: "var(--lk-orange)" }}>Payment Complete</span>
              <span style={MONO({ fontWeight: 700, letterSpacing: "0.7px", textTransform: "uppercase" })}>Pro is active.</span>
              <AppButton variant="primary" size="lg" block onClick={() => go("profile", true)}>Done</AppButton>
            </>
          )}
        </div>
      </div>
      <span style={MONO({ fontSize: 12, lineHeight: "18px", color: "var(--lk-text-tertiary)", textAlign: "center" })}>Demo QR — not scannable. Status is only ever confirmed by the backend.</span>
    </div>
  );
}

Object.assign(window, { LKProfile: ProfileScreen, LKPaywall: PaywallScreen, LKPayment: PaymentScreen });
