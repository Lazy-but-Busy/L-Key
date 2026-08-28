import React from "react";

/* Mobile top app bar (fig: every mobile frame). Paper background, 16/24 padding,
   wordmark centred in Space Grotesk. */
export function TopAppBar({ title = "L KEY", size = "lg", leading, trailing, style }) {
  const scale = size === "lg"
    ? { font: 36, lh: "39.6px", ls: "-1.8px", weight: 700 }
    : { font: 24, lh: "28.8px", ls: "-1.2px", weight: 600 };
  return (
    <header style={{
      boxSizing: "border-box", display: "flex", alignItems: "center", justifyContent: "space-between",
      padding: "16px 24px", background: "var(--lk-bg)", minHeight: size === "lg" ? 71.59 : 68, ...style,
    }}>
      <span style={{ display: "flex", alignItems: "center", minWidth: 34 }}>{leading}</span>
      <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: scale.weight, fontSize: scale.font, lineHeight: scale.lh, letterSpacing: scale.ls, textTransform: "uppercase", color: "var(--lk-text)", whiteSpace: "nowrap" }}>{title}</span>
      <span style={{ display: "flex", alignItems: "center", justifyContent: "flex-end", minWidth: 36 }}>{trailing}</span>
    </header>
  );
}
