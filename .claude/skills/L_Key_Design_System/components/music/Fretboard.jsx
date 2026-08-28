import React from "react";

const STRING_NAMES = ["E", "B", "G", "D", "A", "E"];

/* Horizontal technical fretboard (DESIGN.md §25). Root notes in Guitar Orange. */
export function Fretboard({ strings = STRING_NAMES, frets = 12, markers = [], fretWidth = 52, rowHeight = 40, showFretNumbers = true, style }) {
  const width = frets * fretWidth;
  return (
    <div style={{ display: "inline-flex", flexDirection: "column", gap: 8, background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", padding: 16, boxSizing: "border-box", ...style }}>
      <div style={{ display: "flex" }}>
        <div style={{ display: "flex", flexDirection: "column", width: 20 }}>
          {strings.map((n, i) => (
            <span key={i} style={{ height: rowHeight, display: "flex", alignItems: "center", fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-text)" }}>{n}</span>
          ))}
        </div>
        <div style={{ position: "relative", width, height: strings.length * rowHeight, background: "var(--lk-paper)", boxShadow: "var(--lk-ring)" }}>
          {strings.map((_, r) => (
            <div key={"s" + r} style={{ position: "absolute", left: 0, top: r * rowHeight + rowHeight / 2 - 1, width, height: 2, background: "var(--lk-string)" }} />
          ))}
          {Array.from({ length: frets }).map((_, c) => (
            <div key={"f" + c} style={{ position: "absolute", left: (c + 1) * fretWidth - 1, top: 0, width: c === 0 ? 4 : 2, height: strings.length * rowHeight, background: "var(--lk-black)" }} />
          ))}
          {markers.map((m, i) => (
            <div key={"m" + i} style={{
              position: "absolute", left: m.fret * fretWidth - fretWidth / 2 - 13, top: m.string * rowHeight + rowHeight / 2 - 13,
              width: 26, height: 26, borderRadius: "var(--lk-radius-pill)",
              background: m.root ? "var(--lk-marker-root)" : "var(--lk-marker)",
              color: m.root ? "var(--lk-black)" : "var(--lk-white)",
              boxShadow: "var(--lk-ring)",
              display: "flex", alignItems: "center", justifyContent: "center",
              fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 12, lineHeight: "14.4px",
            }}>{m.label ?? ""}</div>
          ))}
        </div>
      </div>
      {showFretNumbers ? (
        <div style={{ display: "flex", paddingLeft: 20 }}>
          {Array.from({ length: frets }).map((_, c) => (
            <span key={c} style={{ width: fretWidth, textAlign: "center", fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 10, lineHeight: "14.4px", color: "var(--lk-text-tertiary)" }}>{c + 1}</span>
          ))}
        </div>
      ) : null}
    </div>
  );
}
