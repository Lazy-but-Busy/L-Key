import React from "react";

const SIZES = {
  sm: { height: 26.39, padding: "3.5px 12px", font: "var(--lk-font-mono)", weight: 500, size: 12, lh: "14.4px", ls: "normal", upper: false, gap: 6, ring: true, shadow: "none" },
  md: { height: 48, padding: "0 24px", font: "var(--lk-font-mono)", weight: 500, size: 14, lh: "19.6px", ls: "var(--lk-ls-tech-track)", upper: true, gap: 12, ring: false, shadow: "var(--lk-shadow)" },
  lg: { height: 52, padding: "12px 16px", font: "var(--lk-font-display)", weight: 600, size: 18, lh: "28px", ls: "normal", upper: true, gap: 8, ring: false, shadow: "var(--lk-shadow)" },
  xl: { height: 56, padding: "16px 32px", font: "var(--lk-font-display)", weight: 400, size: 16, lh: "24px", ls: "normal", upper: true, gap: 12, ring: false, shadow: "var(--lk-shadow)" },
  hero: { height: 60.8, padding: "15px 24px", font: "var(--lk-font-display)", weight: 700, size: 24, lh: "28.8px", ls: "normal", upper: false, gap: 12, ring: false, shadow: "var(--lk-shadow)" },
};

const VARIANTS = {
  primary: { bg: "var(--lk-btn-primary-bg)", fg: "var(--lk-btn-primary-fg)" },
  accent: { bg: "var(--lk-btn-accent-bg)", fg: "var(--lk-btn-accent-fg)" },
  secondary: { bg: "var(--lk-btn-secondary-bg)", fg: "var(--lk-btn-secondary-fg)" },
  ghost: { bg: "transparent", fg: "var(--lk-text)" },
};

export function AppButton({ children, variant = "primary", size = "lg", icon, iconPosition = "left", block = false, disabled = false, onClick, style, ...rest }) {
  const [pressed, setPressed] = React.useState(false);
  const s = SIZES[size] || SIZES.lg;
  const v = VARIANTS[variant] || VARIANTS.primary;
  const hard = s.shadow !== "none";
  const box = [s.ring || variant === "ghost" ? "var(--lk-ring)" : null, hard ? (pressed ? "var(--lk-shadow-pressed)" : "var(--lk-shadow)") : null].filter(Boolean).join(",") || "none";
  return (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      onPointerDown={() => setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      style={{
        appearance: "none", border: "none", borderRadius: "var(--lk-radius-none)", cursor: disabled ? "not-allowed" : "pointer",
        display: block ? "flex" : "inline-flex", width: block ? "100%" : "auto", flexDirection: iconPosition === "right" ? "row-reverse" : "row",
        alignItems: "center", justifyContent: "center", gap: s.gap, boxSizing: "border-box",
        minHeight: s.height, padding: s.padding, background: v.bg, color: v.fg, boxShadow: box,
        fontFamily: s.font, fontWeight: s.weight, fontSize: s.size, lineHeight: s.lh, letterSpacing: s.ls,
        textTransform: s.upper ? "uppercase" : "none", textAlign: "center", whiteSpace: "nowrap",
        opacity: disabled ? 0.4 : 1,
        transform: hard && pressed ? "translate(3px,3px)" : "none",
        transition: "transform var(--lk-duration-fast) var(--lk-ease),box-shadow var(--lk-duration-fast) var(--lk-ease)",
        ...style,
      }}
      {...rest}
    >
      {icon ? <span style={{ display: "flex", alignItems: "center", flexShrink: 0 }}>{icon}</span> : null}
      <span>{children}</span>
    </button>
  );
}
