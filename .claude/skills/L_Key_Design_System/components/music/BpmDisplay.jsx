import React from "react";

/* Large BPM readout + beat indicator (DESIGN.md §27). */
export function BpmDisplay({ bpm = 120, beats = 4, activeBeat = 0, timeSignature = "4/4", subdivision, size = "lg", style }) {
  const big = size === "lg";
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 12, ...style }}>
      <div style={{ display: "flex", alignItems: "baseline", gap: 8 }}>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: big ? 48 : 36, lineHeight: big ? "52.8px" : "39.6px", letterSpacing: big ? "var(--lk-ls-display)" : "var(--lk-ls-h1)", color: "var(--lk-text)" }}>{bpm}</span>
        <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase", color: "var(--lk-text-technical)" }}>BPM</span>
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
        {Array.from({ length: beats }).map((_, i) => {
          const on = i === activeBeat;
          const accent = i === 0;
          return (
            <div key={i} style={{
              width: accent ? 16 : 12, height: accent ? 16 : 12,
              borderRadius: "var(--lk-radius-pill)",
              background: on ? (accent ? "var(--lk-orange)" : "var(--lk-black)") : "transparent",
              boxShadow: "var(--lk-ring)",
            }} />
          );
        })}
        <span style={{ marginLeft: 8, fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-text-secondary)" }}>
          {timeSignature}{subdivision ? " · " + subdivision : ""}
        </span>
      </div>
    </div>
  );
}
