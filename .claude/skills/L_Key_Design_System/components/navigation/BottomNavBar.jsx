import React from "react";

/* Compact bottom tab bar (fig: 71px tall, active tab = orange block with 2px shadow). */
export function BottomNavBar({ items = [], activeIndex = 0, onSelect, style }) {
  return (
    <nav style={{
      boxSizing: "border-box", display: "flex", alignItems: "center", justifyContent: "space-between",
      gap: 10.8, height: 71, padding: "12px 13.4px", background: "var(--lk-bg)", ...style,
    }}>
      {items.map((item, i) => {
        const active = i === activeIndex;
        return (
          <button key={item.label} type="button" aria-current={active ? "page" : undefined} onClick={() => onSelect && onSelect(i)} style={{
            appearance: "none", border: "none", cursor: "pointer", boxSizing: "border-box",
            display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
            gap: 4, minWidth: active ? 64 : "var(--lk-tap-target)", minHeight: "var(--lk-tap-target)", height: 45, padding: active ? "4px 17.6px" : "4px",
            background: active ? "var(--lk-nav-active-bg)" : "transparent",
            boxShadow: active ? "var(--lk-shadow-sm)" : "none",
            color: active ? "var(--lk-nav-active-fg)" : "var(--lk-nav-idle-fg)",
          }}>
            <span style={{ display: "flex", alignItems: "center", height: 18 }}>{item.icon}</span>
            <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", whiteSpace: "nowrap" }}>{item.label}</span>
          </button>
        );
      })}
    </nav>
  );
}
