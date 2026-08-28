import React from "react";

export function AppSectionHeader({ title, actionLabel, onAction, size = "md", style, ...rest }) {
  const big = size === "lg";
  return (
    <div style={{ display: "flex", alignItems: "flex-end", justifyContent: "space-between", gap: 16, paddingBottom: 8, ...style }} {...rest}>
      <span style={{
        fontFamily: "var(--lk-font-display)", fontWeight: big ? 700 : 600,
        fontSize: big ? 48 : 24, lineHeight: big ? "52.8px" : "28.8px",
        letterSpacing: big ? "var(--lk-ls-display)" : "normal",
        textTransform: "uppercase", color: "var(--lk-text)",
      }}>{title}</span>
      {actionLabel ? (
        <button type="button" onClick={onAction} style={{
          appearance: "none", background: "none", border: "none", padding: 0, cursor: "pointer",
          display: "inline-flex", alignItems: "center", gap: 4,
          fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px",
          textTransform: "uppercase", color: "var(--lk-text)",
        }}>
          {actionLabel}
          <svg width="9.333" height="9.333" viewBox="0 0 9.333 9.333" fill="currentColor" aria-hidden="true"><path d="M 7.102 5.25 L 0 5.25 L 0 4.083 L 7.102 4.083 L 3.835 0.817 L 4.667 0 L 9.333 4.667 L 4.667 9.333 L 3.835 8.517 L 7.102 5.25 L 7.102 5.25" fillRule="nonzero" /></svg>
        </button>
      ) : null}
    </div>
  );
}
