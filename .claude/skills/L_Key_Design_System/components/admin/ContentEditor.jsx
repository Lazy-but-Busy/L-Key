import React from "react";

/* Structured admin editor panel (DESIGN.md §49-51): titled sections, explicit
   publish actions, status shown as text not colour. */
export function ContentEditor({ title = "Song Information", sections = [], status, actions, style }) {
  return (
    <div style={{ boxSizing: "border-box", background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)", display: "flex", flexDirection: "column", ...style }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 16, padding: 24, borderBottom: "2px solid var(--lk-divider)" }}>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 20, lineHeight: "30px", color: "var(--lk-text)" }}>{title}</span>
        {status}
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 32, padding: 24 }}>
        {sections.map((s) => (
          <div key={s.title} style={{ display: "flex", flexDirection: "column", gap: 16 }}>
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase", color: "var(--lk-text-technical)" }}>{s.title}</span>
            <div style={{ display: "grid", gridTemplateColumns: `repeat(${s.columns || 2}, 1fr)`, gap: 16 }}>{s.children}</div>
          </div>
        ))}
      </div>
      {actions ? (
        <div style={{ display: "flex", alignItems: "center", justifyContent: "flex-end", gap: 12, padding: 24, borderTop: "2px solid var(--lk-divider)" }}>{actions}</div>
      ) : null}
    </div>
  );
}
