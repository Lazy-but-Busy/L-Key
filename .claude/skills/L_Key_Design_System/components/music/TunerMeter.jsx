import React from "react";

/* Tuner meter (DESIGN.md §21-22). Detected note is huge Space Grotesk;
   every technical readout is JetBrains Mono. In-tune introduces Guitar Orange. */
export function TunerMeter({ note = "E", octave = 2, frequency = 82.41, cents = -2, tolerance = 3, tuning = "STANDARD", referencePitch = 440, width = 342, style }) {
  const inTune = Math.abs(cents) <= tolerance;
  const clamped = Math.max(-50, Math.min(50, cents));
  const pct = 50 + clamped;
  return (
    <div style={{ width, boxSizing: "border-box", background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: 24, display: "flex", flexDirection: "column", alignItems: "center", gap: 24, ...style }}>
      <div style={{ display: "flex", alignItems: "baseline", gap: 4 }}>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 96, lineHeight: "86.4px", letterSpacing: "var(--lk-ls-hero)", color: inTune ? "var(--lk-in-tune)" : "var(--lk-text)" }}>{note}</span>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 400, fontSize: 24, lineHeight: "32px", color: "var(--lk-text-tertiary)" }}>{octave}</span>
      </div>
      <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 400, fontSize: 16, lineHeight: "24px", color: "var(--lk-text-technical)" }}>{frequency.toFixed(2)} Hz</span>
      <div style={{ position: "relative", width: "100%", height: 48, background: "var(--lk-paper)", boxShadow: "var(--lk-ring)" }}>
        <div style={{ position: "absolute", left: "50%", top: 0, width: 2, height: "100%", background: "var(--lk-black)", transform: "translateX(-1px)" }} />
        <div style={{ position: "absolute", left: pct + "%", top: -6, width: 4, height: 60, background: inTune ? "var(--lk-in-tune)" : "var(--lk-black)", transform: "translateX(-2px)", transition: "left var(--lk-duration) var(--lk-ease)" }} />
      </div>
      <div style={{ display: "flex", width: "100%", justifyContent: "space-between", alignItems: "center" }}>
        <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-text-tertiary)" }}>-50</span>
        <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 14, lineHeight: "19.6px", letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase", color: inTune ? "var(--lk-in-tune)" : "var(--lk-text)" }}>
          {inTune ? "IN TUNE" : (cents > 0 ? "+" : "") + cents + " CENTS"}
        </span>
        <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-text-tertiary)" }}>+50</span>
      </div>
      <div style={{ display: "flex", width: "100%", justifyContent: "space-between", borderTop: "2px solid var(--lk-divider)", paddingTop: 12 }}>
        <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase", color: "var(--lk-text)" }}>{tuning}</span>
        <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", color: "var(--lk-text-secondary)" }}>{referencePitch} Hz</span>
      </div>
    </div>
  );
}
