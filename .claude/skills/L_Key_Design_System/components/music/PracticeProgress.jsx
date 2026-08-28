import React from "react";

/* Practice progress: hatched orange fill inside a paper track (fig: Continue Practice).
   Progress, not decoration (DESIGN.md §30-31). */
export function PracticeProgress({ value = 0, max = 100, label, elapsed, total, height = 32, showStripes = true, style }) {
  const pct = Math.max(0, Math.min(100, (value / max) * 100));
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 12, ...style }}>
      {label || elapsed ? (
        <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", gap: 8 }}>
          {elapsed ? (
            <span style={{ display: "flex", alignItems: "baseline", gap: 8 }}>
              <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 36, lineHeight: "39.6px", color: "var(--lk-text)" }}>{elapsed}</span>
              {total ? <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-text-technical)" }}>/ {total}</span> : null}
            </span>
          ) : null}
          {label ? (
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 400, fontSize: 14, lineHeight: "19.6px", letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase", color: "var(--lk-text-secondary)" }}>{label}</span>
          ) : null}
        </div>
      ) : null}
      <div style={{ height, overflow: "hidden", background: "var(--lk-paper)", display: "flex", alignItems: "center" }}>
        <div style={{
          width: pct + "%", height: "100%", background: "var(--lk-orange)",
          borderTop: "1px solid var(--lk-black)", borderRight: "2px solid var(--lk-black)",
          borderBottom: "1px solid var(--lk-black)", borderLeft: "1px solid var(--lk-black)",
          boxSizing: "border-box", position: "relative", transition: "width var(--lk-duration) var(--lk-ease)",
        }}>
          {showStripes ? <div style={{ position: "absolute", inset: 0, opacity: 0.2, background: "var(--lk-hatch)" }} /> : null}
        </div>
      </div>
    </div>
  );
}
