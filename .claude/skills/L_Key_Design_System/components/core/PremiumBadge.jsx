import React from "react";

export function PremiumBadge({ children = "PRO", tone = "accent", size = "md", style, ...rest }) {
  const small = size === "sm";
  const accent = tone === "accent";
  return (
    <span
      style={{
        display: "inline-flex", alignItems: "center", boxSizing: "border-box",
        padding: small ? "2px 6px" : "3.5px 8px",
        background: accent ? "var(--lk-orange)" : "var(--lk-black)",
        color: accent ? "var(--lk-black)" : "var(--lk-white)",
        boxShadow: "var(--lk-ring)", borderRadius: "var(--lk-radius-none)",
        fontFamily: "var(--lk-font-mono)", fontWeight: 700, fontSize: small ? 10 : 12,
        lineHeight: "14.4px", letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase",
        ...style,
      }}
      {...rest}
    >{children}</span>
  );
}
