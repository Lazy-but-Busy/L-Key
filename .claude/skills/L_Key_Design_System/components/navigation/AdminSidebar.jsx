import React from "react";

/* Admin desktop navigation drawer (fig: 320px, 4px black rail, orange active row). */
export function AdminSidebar({ brand = "L KEY", user, items = [], activeIndex = 0, onSelect, footer, style }) {
  return (
    <aside style={{
      boxSizing: "border-box", width: 320, minHeight: "100%", padding: 24,
      background: "var(--lk-bg)", boxShadow: "var(--lk-shadow-rail)",
      display: "flex", flexDirection: "column", justifyContent: "space-between", gap: 24, ...style,
    }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
        <span style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 48, lineHeight: "52.8px", letterSpacing: "var(--lk-ls-display-tight)", color: "var(--lk-text)" }}>{brand}</span>
        {user ? (
          <div style={{ display: "flex", alignItems: "center", gap: 16, padding: 12, boxSizing: "border-box", background: "var(--lk-surface)", boxShadow: "var(--lk-ring-shadow)" }}>
            <div style={{ width: 48, height: 48, borderRadius: "var(--lk-radius-pill)", overflow: "hidden", background: "var(--lk-grey-200)", boxShadow: "var(--lk-ring)", flexShrink: 0 }}>
              {user.avatar ? <img src={user.avatar} alt="" style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} /> : null}
            </div>
            <div style={{ display: "flex", flexDirection: "column", minWidth: 0 }}>
              <span style={{ fontFamily: "var(--lk-font-body)", fontWeight: 700, fontSize: 16, lineHeight: "24px", color: "var(--lk-text)" }}>{user.name}</span>
              <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-text-secondary)" }}>{user.role}</span>
            </div>
          </div>
        ) : null}
      </div>
      <nav style={{ display: "flex", flexDirection: "column", gap: 8, flexGrow: 1 }}>
        {items.map((item, i) => {
          const active = i === activeIndex;
          return (
            <button key={item.label} type="button" onClick={() => onSelect && onSelect(i)} style={{
              appearance: "none", border: "none", cursor: "pointer", boxSizing: "border-box", textAlign: "left",
              display: "flex", alignItems: "center", gap: 12, height: 52, padding: 12,
              background: active ? "var(--lk-orange)" : "transparent",
              boxShadow: active ? "var(--lk-ring-shadow)" : "none",
              color: "var(--lk-text)",
              fontFamily: "var(--lk-font-body)", fontWeight: 700, fontSize: 16, lineHeight: "24px",
            }}>
              {item.icon ? <span style={{ display: "flex", width: 18, height: 18, flexShrink: 0 }}>{item.icon}</span> : null}
              {item.label}
            </button>
          );
        })}
      </nav>
      {footer}
    </aside>
  );
}
