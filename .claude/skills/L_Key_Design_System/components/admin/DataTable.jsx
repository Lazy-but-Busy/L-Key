import React from "react";

/* Admin data table (fig: Song Database + Recent Payments).
   #E8E8E8 header, 66px body rows, hairline black grid, hard-shadow container.

   Semantic <table> markup: column widths come from <colgroup> with
   table-layout:fixed, which reproduces the previous flex sizing exactly
   (fixed px columns hold, the rest divide the remainder) while giving
   assistive technology the header/cell association a div grid cannot.
   The cell itself stays a table-cell — the flex row that centres chips and
   buttons lives in an inner div, so the table formatting context is intact. */
export function DataTable({ columns = [], rows = [], footerNote, pagination, dense = false, gridded = false, caption, emptyLabel = "No rows to show.", style }) {
  const cellPad = dense ? "12px" : "19px 16px";
  const rowMin = dense ? 47.59 : 66;
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 16, ...style }}>
      <div style={{ overflowX: "auto", background: "var(--lk-surface)", boxShadow: "var(--lk-shadow)" }}>
        <table style={{ width: "100%", borderCollapse: "collapse", tableLayout: "fixed" }}>
          {caption ? (
            <caption style={{
              captionSide: "top", textAlign: "left", padding: "16px 16px 0",
              fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px",
              letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase", color: "var(--lk-text-secondary)",
            }}>{caption}</caption>
          ) : null}
          <colgroup>
            {columns.map((c) => <col key={c.key} style={c.width ? { width: c.width } : undefined} />)}
          </colgroup>
          <thead>
            <tr style={{ background: "var(--lk-fill-thead)" }}>
              {columns.map((c) => (
                <th key={c.key} scope="col" style={{
                  boxSizing: "border-box", padding: "16px",
                  textAlign: c.align || "left",
                  borderRight: gridded ? "2px solid var(--lk-black)" : "none",
                  borderBottom: gridded ? "2px solid var(--lk-black)" : "none",
                  fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px",
                  textTransform: "uppercase", color: "var(--lk-text)",
                }}>{c.label}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.length === 0 ? (
              <tr style={{ borderBottom: gridded ? "2px solid var(--lk-black)" : "1px solid var(--lk-fill-ghost)" }}>
                <td colSpan={columns.length || 1} style={{
                  boxSizing: "border-box", padding: cellPad, height: rowMin, textAlign: "center",
                  fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, lineHeight: "19.6px",
                  color: "var(--lk-text-secondary)",
                }}>{emptyLabel}</td>
              </tr>
            ) : rows.map((row, ri) => (
              <tr key={row.id ?? ri} style={{ borderTop: gridded ? "1px solid var(--lk-black)" : "none", borderBottom: gridded ? "2px solid var(--lk-black)" : "1px solid var(--lk-fill-ghost)" }}>
                {columns.map((c) => (
                  <td key={c.key} style={{
                    boxSizing: "border-box", padding: cellPad, height: rowMin, verticalAlign: "middle",
                    textAlign: c.align || "left",
                    borderRight: gridded ? "2px solid var(--lk-black)" : "none",
                    fontFamily: c.font === "body" ? "var(--lk-font-body)" : "var(--lk-font-mono)",
                    fontWeight: c.strong ? 700 : 500, fontSize: 14, lineHeight: "19.6px", color: "var(--lk-text)",
                  }}>
                    <span style={{ display: "flex", alignItems: "center", gap: 8, justifyContent: c.align === "right" ? "flex-end" : c.align === "center" ? "center" : "flex-start" }}>{row[c.key]}</span>
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {footerNote || pagination ? (
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 16 }}>
          <span style={{ fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 12, lineHeight: "14.4px", color: "var(--lk-text-secondary)" }}>{footerNote}</span>
          <div style={{ display: "flex", gap: 8 }}>{pagination}</div>
        </div>
      ) : null}
    </div>
  );
}
