import React from "react";

/* Admin page header (fig: title + mono subtitle, actions right-aligned at baseline). */
export function AdminHeader({ title, subtitle, actions, size = "md", style }) {
  const big = size === "lg";
  return (
    <div style={{ display: "flex", alignItems: "flex-end", justifyContent: "space-between", gap: 24, ...style }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: big ? 48 : 24, lineHeight: big ? "52.8px" : "28.8px", letterSpacing: big ? "var(--lk-ls-display)" : "normal", textTransform: "uppercase", color: "var(--lk-text)" }}>{title}</span>
        {subtitle ? (
          <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", color: "var(--lk-text-secondary)" }}>{subtitle}</span>
        ) : null}
      </div>
      {actions ? <div style={{ display: "flex", alignItems: "center", gap: 16, flexShrink: 0 }}>{actions}</div> : null}
    </div>
  );
}
