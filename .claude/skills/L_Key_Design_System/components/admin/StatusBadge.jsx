import React from "react";

const TONES = {
  published: { bg: "var(--lk-success-bg)", dot: "var(--lk-success)", fg: "var(--lk-black)" },
  draft: { bg: "var(--lk-fill-tag)", dot: "var(--lk-grey-400)", fg: "var(--lk-black)" },
  archived: { bg: "var(--lk-grey-100)", dot: "var(--lk-grey-500)", fg: "var(--lk-grey-600)" },
  pending: { bg: "var(--lk-orange)", dot: "var(--lk-black)", fg: "var(--lk-black)" },
  failed: { bg: "var(--lk-white)", dot: "var(--lk-danger)", fg: "var(--lk-danger)" },
};

/* Status pill (fig: 2px hard shadow, 8px dot, mono 14).
   Status is carried by dot + word, never colour alone (DESIGN.md §42, §56). */
export function StatusBadge({ status = "published", children, style }) {
  const t = TONES[status] || TONES.draft;
  const text = children || status.charAt(0).toUpperCase() + status.slice(1);
  return (
    <span style={{
      display: "inline-flex", alignItems: "center", gap: 8, boxSizing: "border-box",
      padding: "3px 8px", minHeight: 27.59, background: t.bg, color: t.fg, boxShadow: "var(--lk-shadow-sm)",
      fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px", whiteSpace: "nowrap",
      ...style,
    }}>
      <span style={{ width: 8, height: 8, borderRadius: "var(--lk-radius-pill)", background: t.dot, flexShrink: 0 }} />
      {text}
    </span>
  );
}
