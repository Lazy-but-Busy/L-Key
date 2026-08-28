import React from "react";

export function AppCard({ children, label, title, action, variant = "shadow", padding = 24, tone = "surface", style, ...rest }) {
  const box = variant === "ring" ? "var(--lk-ring-shadow)" : variant === "flat" ? "none" : "var(--lk-shadow)";
  const bg = tone === "accent" ? "var(--lk-orange)" : tone === "inverse" ? "var(--lk-black)" : tone === "sunken" ? "var(--lk-paper)" : "var(--lk-surface)";
  const fg = tone === "inverse" ? "var(--lk-white)" : "var(--lk-text)";
  return (
    <div
      style={{
        boxSizing: "border-box", background: bg, color: fg, boxShadow: box, borderRadius: "var(--lk-radius-none)",
        padding, display: "flex", flexDirection: "column", gap: 16, ...style,
      }}
      {...rest}
    >
      {label || title || action ? (
        <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
          {label ? (
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase", color: tone === "inverse" ? "var(--lk-grey-300)" : "var(--lk-text-technical)" }}>{label}</span>
          ) : null}
          {title || action ? (
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 12 }}>
              {title ? (
                <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 600, fontSize: 24, lineHeight: "28.8px", color: "inherit" }}>{title}</span>
              ) : <span />}
              {action}
            </div>
          ) : null}
        </div>
      ) : null}
      {children}
    </div>
  );
}
