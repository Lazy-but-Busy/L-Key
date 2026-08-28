import React from "react";

/* Song card (fig: Home "Recent Riffs"). 128px artwork with a 10% black scrim,
   orange BPM badge bottom-right, then title + "ARTIST • TAG" meta row. */
export function SongCard({ title = "Master of Puppets", artist = "METALLICA", tag = "RHYTHM", bpm, bpmTone = "accent", cover, action, onClick, style }) {
  return (
    <div onClick={onClick} style={{ overflow: "hidden", background: "var(--lk-surface)", boxShadow: "var(--lk-shadow)", display: "flex", flexDirection: "column", cursor: onClick ? "pointer" : "default", ...style }}>
      <div style={{ position: "relative", height: 128, background: cover ? `url(${cover}) 50% 50% / cover no-repeat` : "var(--lk-grey-200)" }}>
        <div style={{ position: "absolute", inset: 0, background: "var(--lk-overlay-image)" }} />
        {bpm ? (
          <div style={{ position: "absolute", right: 8, bottom: 8, background: bpmTone === "muted" ? "var(--lk-grey-200)" : "var(--lk-orange)", boxShadow: "var(--lk-ring)", padding: "3.5px 8px", boxSizing: "border-box" }}>
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-black)" }}>{bpm} BPM</span>
          </div>
        ) : null}
      </div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", padding: 16, gap: 8 }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 4, minWidth: 0 }}>
          <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 600, fontSize: 18, lineHeight: "28px", color: "var(--lk-text)", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{title}</span>
          <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", textTransform: "uppercase", color: "var(--lk-text-secondary)" }}>
            {artist}{tag ? " • " + tag : ""}
          </span>
        </div>
        {action}
      </div>
    </div>
  );
}
