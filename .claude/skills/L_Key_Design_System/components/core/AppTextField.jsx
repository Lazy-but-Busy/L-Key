import React from "react";

export function AppTextField({ label, value, placeholder = "", icon, onChange, block = true, style, inputStyle, ...rest }) {
  return (
    <label style={{ display: block ? "flex" : "inline-flex", flexDirection: "column", gap: 4, width: block ? "100%" : "auto", ...style }}>
      {label ? (
        <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", textTransform: "uppercase", color: "var(--lk-text-technical)" }}>{label}</span>
      ) : null}
      <span style={{ position: "relative", display: "flex", alignItems: "stretch" }}>
        {icon ? (
          <span style={{ position: "absolute", left: 12, top: 0, bottom: 0, display: "flex", alignItems: "center", pointerEvents: "none" }}>{icon}</span>
        ) : null}
        <input
          value={value}
          placeholder={placeholder}
          onChange={onChange}
          style={{
            appearance: "none", border: "none", boxSizing: "border-box", width: "100%",
            minHeight: 45.59, padding: icon ? "12px 12px 13.59px 40px" : "12px 12px 13.59px 12px",
            background: "var(--lk-surface)", color: "var(--lk-text)",
            boxShadow: "var(--lk-ring-hairline),var(--lk-shadow)", borderRadius: "var(--lk-radius-none)",
            fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "100%",
            ...inputStyle,
          }}
          {...rest}
        />
      </span>
    </label>
  );
}
