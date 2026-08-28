import React from "react";

const VARIANTS = {
  chip: { bg: "var(--lk-grey-100)", fg: "var(--lk-black)", box: "var(--lk-ring-shadow-sm)", padding: "4px 12px", weight: 500, size: 14, lh: "19.6px" },
  tag: { bg: "var(--lk-fill-tag)", fg: "var(--lk-black)", box: "none", padding: "4px 8px", weight: 500, size: 14, lh: "19.6px" },
  bento: { bg: "var(--lk-fill-chip)", fg: "var(--lk-black)", box: "var(--lk-shadow)", padding: "16px", weight: 700, size: 14, lh: "19.6px" },
  accent: { bg: "var(--lk-orange)", fg: "var(--lk-black)", box: "var(--lk-ring)", padding: "3.5px 8px", weight: 700, size: 12, lh: "14.4px" },
  dark: { bg: "var(--lk-black)", fg: "var(--lk-white)", box: "none", padding: "4px 8px", weight: 400, size: 16, lh: "24px" },
};

export function AppChip({ children, label, variant = "chip", icon, style, ...rest }) {
  const v = VARIANTS[variant] || VARIANTS.chip;
  const stacked = variant === "bento" || (label && variant !== "accent");
  return (
    <div
      style={{
        display: "inline-flex", flexDirection: stacked ? "column" : "row", alignItems: stacked && variant === "bento" ? "center" : "flex-start",
        gap: variant === "bento" ? 4 : 6, boxSizing: "border-box",
        background: v.bg, color: v.fg, boxShadow: v.box, borderRadius: "var(--lk-radius-none)", padding: v.padding,
        ...style,
      }}
      {...rest}
    >
      {label ? (
        <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", textTransform: "uppercase", color: variant === "dark" ? "var(--lk-grey-300)" : "var(--lk-text-technical)" }}>{label}</span>
      ) : null}
      <span style={{ display: "inline-flex", alignItems: "center", gap: 6, fontFamily: "var(--lk-font-mono)", fontWeight: v.weight, fontSize: v.size, lineHeight: v.lh, whiteSpace: "nowrap" }}>
        {icon}
        {children}
      </span>
    </div>
  );
}
