import React from "react";

/* Chord diagram — thick strings, hard fret nut, large finger markers (DESIGN.md §24).
   Geometry transcribed from the chord screen in L Key UIs.fig:
   canvas 360px tall, 32px padding, 16px black fret nut, 256px grid, 4px strings. */
export function ChordDiagram({ name = "C MAJOR", strings = 6, frets = 4, positions = [], openStrings = [], mutedStrings = [], fingers = [], width = 278, style }) {
  const gridW = width;
  const gridH = 256;
  const colGap = strings > 1 ? gridW / (strings - 1) : 0;
  const rowH = gridH / frets;
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24, alignItems: "center", ...style }}>
      {name ? (
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 36, lineHeight: "39.6px", textTransform: "uppercase", color: "var(--lk-text)" }}>{name}</span>
      ) : null}
      <div style={{ background: "var(--lk-surface)", boxShadow: "var(--lk-shadow)", padding: 32, display: "flex", flexDirection: "column", gap: 24, boxSizing: "border-box" }}>
        <div style={{ display: "flex", justifyContent: "space-between", width: gridW, height: 19.59 }}>
          {Array.from({ length: strings }).map((_, i) => {
            const open = openStrings.includes(i);
            const muted = mutedStrings.includes(i);
            return (
              <span key={i} style={{ width: 8.41, textAlign: "center", fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 14, lineHeight: "19.6px", color: muted ? "var(--lk-danger)" : "var(--lk-text)" }}>
                {muted ? "X" : open ? "O" : ""}
              </span>
            );
          })}
        </div>
        <div style={{ height: 16, background: "var(--lk-black)", width: gridW }} />
        <div style={{ position: "relative", width: gridW, height: gridH }}>
          {Array.from({ length: strings }).map((_, i) => (
            <div key={"s" + i} style={{ position: "absolute", left: i * colGap - 2, top: 0, width: 4, height: gridH, background: "var(--lk-string)" }} />
          ))}
          {Array.from({ length: frets }).map((_, r) => (
            <div key={"f" + r} style={{ position: "absolute", left: 0, top: (r + 1) * rowH - 1, width: gridW, height: 2, background: "var(--lk-black)" }} />
          ))}
          {positions.map((p, i) => (
            <div key={"p" + i} style={{
              position: "absolute", left: p.string * colGap - 18, top: (p.fret - 1) * rowH + rowH / 2 - 18,
              width: 36, height: 36, borderRadius: "var(--lk-radius-pill)",
              background: p.root ? "var(--lk-marker-root)" : "var(--lk-marker)",
              color: p.root ? "var(--lk-black)" : "var(--lk-white)",
              display: "flex", alignItems: "center", justifyContent: "center",
              fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 14, lineHeight: "19.6px",
            }}>{p.finger ?? ""}</div>
          ))}
        </div>
        {fingers.length ? (
          <div style={{ display: "flex", justifyContent: "space-between", width: gridW }}>
            {fingers.map((f, i) => (
              <span key={i} style={{ width: 8.41, textAlign: "center", fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 14, lineHeight: "19.6px", color: "var(--lk-text)" }}>{f}</span>
            ))}
          </div>
        ) : null}
      </div>
    </div>
  );
}
