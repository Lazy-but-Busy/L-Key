import React from "react";

const VARIANTS = {
  plain: { bg: "var(--lk-white)", fg: "var(--lk-black)", box: "var(--lk-shadow)", radius: "var(--lk-radius-none)" },
  ring: { bg: "var(--lk-white)", fg: "var(--lk-black)", box: "var(--lk-ring)", radius: "var(--lk-radius-none)" },
  solid: { bg: "var(--lk-black)", fg: "var(--lk-white)", box: "var(--lk-ring)", radius: "var(--lk-radius-none)" },
  accent: { bg: "var(--lk-orange)", fg: "var(--lk-black)", box: "var(--lk-ring)", radius: "var(--lk-radius-none)" },
  circle: { bg: "var(--lk-white)", fg: "var(--lk-black)", box: "var(--lk-ring)", radius: "var(--lk-radius-pill)" },
  bare: { bg: "transparent", fg: "var(--lk-black)", box: "none", radius: "var(--lk-radius-sm)" },
};

/* Icon-only control. The button is the touch target and is never smaller than
   --lk-tap-target (44px); the painted box stays at `size`, and a negative
   margin absorbs the difference so the surrounding layout is unchanged.
   `style` therefore applies to the visual box, not the hit area. */
export function AppIconButton({ children, variant = "plain", size = 36, label, onClick, style, ...rest }) {
  const [pressed, setPressed] = React.useState(false);
  const v = VARIANTS[variant] || VARIANTS.plain;
  const hard = v.box === "var(--lk-shadow)";
  const TAP = 44;
  const bleed = Math.max(0, (TAP - size) / 2);
  return (
    <button
      type="button"
      aria-label={label}
      onClick={onClick}
      onPointerDown={() => setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      style={{
        appearance: "none", border: "none", background: "none", padding: 0,
        cursor: "pointer", boxSizing: "border-box", flexShrink: 0,
        minWidth: TAP, minHeight: TAP, margin: bleed ? `-${bleed}px` : 0,
        display: "flex", alignItems: "center", justifyContent: "center",
        color: v.fg,
      }}
      {...rest}
    >
      <span
        style={{
          boxSizing: "border-box", width: size, height: size, padding: 8,
          display: "flex", alignItems: "center", justifyContent: "center",
          background: v.bg, color: v.fg, borderRadius: v.radius,
          boxShadow: hard && pressed ? "var(--lk-shadow-pressed)" : v.box,
          transform: hard && pressed ? "translate(var(--lk-press-translate),var(--lk-press-translate))" : "none",
          transition: "transform var(--lk-duration-fast) var(--lk-ease),box-shadow var(--lk-duration-fast) var(--lk-ease)",
          ...style,
        }}
      >
        {children}
      </span>
    </button>
  );
}
