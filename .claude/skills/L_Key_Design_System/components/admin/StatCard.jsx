import React from "react";

/* Admin KPI card (fig: 2px ring + 4px shadow, mono label, Space Grotesk 48 figure,
   orange delta row, faint grey ornament bleeding out of the top-right corner). */
export function StatCard({ label, value, delta, deltaDirection = "up", note, icon, ornament = "circle", style }) {
  return (
    <div style={{
      position: "relative", overflow: "hidden", boxSizing: "border-box", flexGrow: 1,
      background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: "24px 24px 36px 24px",
      display: "flex", flexDirection: "column", ...style,
    }}>
      {ornament !== "none" ? (
        <div style={{
          position: "absolute", right: -14, top: -14, width: 96, height: 96, opacity: 0.5,
          background: "var(--lk-fill-ornament)", boxShadow: "var(--lk-ring)",
          borderRadius: ornament === "circle" ? "var(--lk-radius-pill)" : "var(--lk-radius-none)",
          transform: ornament === "square" ? "rotate(12deg)" : "none",
        }} />
      ) : null}
      <div style={{ position: "relative", display: "flex", flexDirection: "column", gap: 7.5 }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 12, height: 24 }}>
          <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", textTransform: "uppercase", color: "var(--lk-text-technical)" }}>{label}</span>
          {icon}
        </div>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 48, lineHeight: "52.8px", letterSpacing: "var(--lk-ls-display)", color: "var(--lk-text)" }}>{value}</span>
        {delta || note ? (
          <div style={{ display: "flex", alignItems: "center", gap: 4, height: 15 }}>
            {delta ? (
              <>
                <svg width="11.667" height="7" viewBox="0 0 11.667 7" fill="var(--lk-orange)" style={{ transform: deltaDirection === "down" ? "scaleY(-1)" : "none" }} aria-hidden="true"><path d="M 0.817 7 L 0 6.183 L 4.317 1.837 L 6.65 4.171 L 9.683 1.167 L 8.167 1.167 L 8.167 0 L 11.667 0 L 11.667 3.5 L 10.5 3.5 L 10.5 1.983 L 6.65 5.833 L 4.317 3.5 L 0.817 7 L 0.817 7" fillRule="nonzero" /></svg>
                <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-text)" }}>{delta}</span>
              </>
            ) : null}
            {note ? <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-text-secondary)" }}>{note}</span> : null}
          </div>
        ) : null}
      </div>
    </div>
  );
}
