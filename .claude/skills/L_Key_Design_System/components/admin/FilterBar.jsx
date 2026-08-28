import React from "react";

/* Filter row for admin list views: mono segment groups + trailing slot. */
export function FilterBar({ groups = [], activeValues = {}, onChange, trailing, style }) {
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 16, flexWrap: "wrap", ...style }}>
      <div style={{ display: "flex", alignItems: "center", gap: 24, flexWrap: "wrap" }}>
        {groups.map((g) => (
          <div key={g.key} style={{ display: "flex", alignItems: "center", gap: 8 }}>
            {g.label ? (
              <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase", color: "var(--lk-text-technical)" }}>{g.label}</span>
            ) : null}
            <div style={{ display: "flex", boxShadow: "var(--lk-ring)" }}>
              {g.options.map((o) => {
                const active = (activeValues[g.key] ?? g.options[0]) === o;
                return (
                  <button key={o} type="button" onClick={() => onChange && onChange(g.key, o)} style={{
                    appearance: "none", border: "none", cursor: "pointer", boxSizing: "border-box",
                    padding: "3.5px 12px", minHeight: 26.39,
                    background: active ? "var(--lk-black)" : "var(--lk-white)",
                    color: active ? "var(--lk-white)" : "var(--lk-grey-500)",
                    fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px",
                    borderRight: "1px solid var(--lk-black)",
                  }}>{o}</button>
                );
              })}
            </div>
          </div>
        ))}
      </div>
      {trailing ? <div style={{ display: "flex", alignItems: "center", gap: 16 }}>{trailing}</div> : null}
    </div>
  );
}
