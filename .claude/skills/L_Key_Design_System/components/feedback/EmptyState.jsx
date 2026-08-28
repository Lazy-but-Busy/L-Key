import React from "react";

/* Empty state with personality but no decoration (DESIGN.md §37). */
export function EmptyState({ headline = "NO FAVORITES YET.", body, action, icon, align = "center", style }) {
  return (
    <div style={{
      display: "flex", flexDirection: "column", gap: 12, padding: 32, boxSizing: "border-box",
      alignItems: align === "center" ? "center" : "flex-start", textAlign: align,
      background: "var(--lk-surface)", boxShadow: "var(--lk-ring)", ...style,
    }}>
      {icon}
      <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 24, lineHeight: "28.8px", textTransform: "uppercase", color: "var(--lk-text)" }}>{headline}</span>
      {body ? (
        <span style={{ fontFamily: "var(--lk-font-body)", fontWeight: 400, fontSize: 16, lineHeight: "24px", color: "var(--lk-text-secondary)", maxWidth: 320 }}>{body}</span>
      ) : null}
      {action ? <div style={{ marginTop: 8 }}>{action}</div> : null}
    </div>
  );
}
