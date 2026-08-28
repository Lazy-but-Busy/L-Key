/* @ds-bundle: {"format":4,"namespace":"LKeyDesignSystem_355d7c","components":[{"name":"ContentEditor","sourcePath":"components/admin/ContentEditor.jsx"},{"name":"DataTable","sourcePath":"components/admin/DataTable.jsx"},{"name":"FilterBar","sourcePath":"components/admin/FilterBar.jsx"},{"name":"StatCard","sourcePath":"components/admin/StatCard.jsx"},{"name":"StatusBadge","sourcePath":"components/admin/StatusBadge.jsx"},{"name":"AppButton","sourcePath":"components/core/AppButton.jsx"},{"name":"AppCard","sourcePath":"components/core/AppCard.jsx"},{"name":"AppChip","sourcePath":"components/core/AppChip.jsx"},{"name":"AppIconButton","sourcePath":"components/core/AppIconButton.jsx"},{"name":"AppSectionHeader","sourcePath":"components/core/AppSectionHeader.jsx"},{"name":"AppTextField","sourcePath":"components/core/AppTextField.jsx"},{"name":"PremiumBadge","sourcePath":"components/core/PremiumBadge.jsx"},{"name":"ConfirmDialog","sourcePath":"components/feedback/ConfirmDialog.jsx"},{"name":"EmptyState","sourcePath":"components/feedback/EmptyState.jsx"},{"name":"BpmDisplay","sourcePath":"components/music/BpmDisplay.jsx"},{"name":"ChordDiagram","sourcePath":"components/music/ChordDiagram.jsx"},{"name":"Fretboard","sourcePath":"components/music/Fretboard.jsx"},{"name":"PracticeProgress","sourcePath":"components/music/PracticeProgress.jsx"},{"name":"SongCard","sourcePath":"components/music/SongCard.jsx"},{"name":"TunerMeter","sourcePath":"components/music/TunerMeter.jsx"},{"name":"AdminHeader","sourcePath":"components/navigation/AdminHeader.jsx"},{"name":"AdminSidebar","sourcePath":"components/navigation/AdminSidebar.jsx"},{"name":"BottomNavBar","sourcePath":"components/navigation/BottomNavBar.jsx"},{"name":"TopAppBar","sourcePath":"components/navigation/TopAppBar.jsx"}],"sourceHashes":{"components/admin/ContentEditor.jsx":"612c7f4dae99","components/admin/DataTable.jsx":"4806a6d20ef5","components/admin/FilterBar.jsx":"97ee3c51c177","components/admin/StatCard.jsx":"17ea6836c960","components/admin/StatusBadge.jsx":"bf9b2a0aa18f","components/core/AppButton.jsx":"ded10e1aeca8","components/core/AppCard.jsx":"5dc0e5e8df05","components/core/AppChip.jsx":"98a0e75a7636","components/core/AppIconButton.jsx":"8d34b0a805dd","components/core/AppSectionHeader.jsx":"e340dfbfe264","components/core/AppTextField.jsx":"1b301de2abd4","components/core/PremiumBadge.jsx":"8f0ccb97c7b6","components/feedback/ConfirmDialog.jsx":"ebd5e4064afa","components/feedback/EmptyState.jsx":"76694475224b","components/music/BpmDisplay.jsx":"e6b1d14e655e","components/music/ChordDiagram.jsx":"9ceaeeca9bce","components/music/Fretboard.jsx":"4e2a0065df49","components/music/PracticeProgress.jsx":"2e4b5636320d","components/music/SongCard.jsx":"ba563e2dbe8f","components/music/TunerMeter.jsx":"c8567f0f953a","components/navigation/AdminHeader.jsx":"eaf254a0de17","components/navigation/AdminSidebar.jsx":"aa35ee71f74e","components/navigation/BottomNavBar.jsx":"102698f9758c","components/navigation/TopAppBar.jsx":"4865cc7e545c","ui_kits/admin_portal/BusinessScreens.jsx":"2120238e3807","ui_kits/admin_portal/ContentScreens.jsx":"4aca9c7ba772","ui_kits/admin_portal/DashboardScreen.jsx":"c1cd6f567501","ui_kits/admin_portal/PeopleScreens.jsx":"76834ccf6f9c","ui_kits/admin_portal/SongDatabaseScreen.jsx":"afc6a6389527","ui_kits/mobile_app/ChordScreen.jsx":"8026f3c81774","ui_kits/mobile_app/HomeScreen.jsx":"e8fc47e48956","ui_kits/mobile_app/LibraryScreens.jsx":"86592c71c674","ui_kits/mobile_app/ProfileScreens.jsx":"cc0c748ad5e1","ui_kits/mobile_app/SongViewerScreen.jsx":"a5ed124adc14","ui_kits/mobile_app/ToolsScreens.jsx":"97e80a6cb5ad","ui_kits/website/LandingScreen.jsx":"dc50774413a9"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.LKeyDesignSystem_355d7c = window.LKeyDesignSystem_355d7c || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/admin/ContentEditor.jsx
try { (() => {
/* Structured admin editor panel (DESIGN.md §49-51): titled sections, explicit
   publish actions, status shown as text not colour. */
function ContentEditor({
  title = "Song Information",
  sections = [],
  status,
  actions,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      boxSizing: "border-box",
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      display: "flex",
      flexDirection: "column",
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 16,
      padding: 24,
      borderBottom: "2px solid var(--lk-divider)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 20,
      lineHeight: "30px",
      color: "var(--lk-text)"
    }
  }, title), status), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 32,
      padding: 24
    }
  }, sections.map(s => /*#__PURE__*/React.createElement("div", {
    key: s.title,
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase",
      color: "var(--lk-text-technical)"
    }
  }, s.title), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: `repeat(${s.columns || 2}, 1fr)`,
      gap: 16
    }
  }, s.children)))), actions ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "flex-end",
      gap: 12,
      padding: 24,
      borderTop: "2px solid var(--lk-divider)"
    }
  }, actions) : null);
}
Object.assign(__ds_scope, { ContentEditor });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/admin/ContentEditor.jsx", error: String((e && e.message) || e) }); }

// components/admin/DataTable.jsx
try { (() => {
/* Admin data table (fig: Song Database + Recent Payments).
   #E8E8E8 header, 66px body rows, hairline black grid, hard-shadow container.

   Semantic <table> markup: column widths come from <colgroup> with
   table-layout:fixed, which reproduces the previous flex sizing exactly
   (fixed px columns hold, the rest divide the remainder) while giving
   assistive technology the header/cell association a div grid cannot.
   The cell itself stays a table-cell — the flex row that centres chips and
   buttons lives in an inner div, so the table formatting context is intact. */
function DataTable({
  columns = [],
  rows = [],
  footerNote,
  pagination,
  dense = false,
  gridded = false,
  caption,
  emptyLabel = "No rows to show.",
  style
}) {
  const cellPad = dense ? "12px" : "19px 16px";
  const rowMin = dense ? 47.59 : 66;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16,
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      overflowX: "auto",
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-shadow)"
    }
  }, /*#__PURE__*/React.createElement("table", {
    style: {
      width: "100%",
      borderCollapse: "collapse",
      tableLayout: "fixed"
    }
  }, caption ? /*#__PURE__*/React.createElement("caption", {
    style: {
      captionSide: "top",
      textAlign: "left",
      padding: "16px 16px 0",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase",
      color: "var(--lk-text-secondary)"
    }
  }, caption) : null, /*#__PURE__*/React.createElement("colgroup", null, columns.map(c => /*#__PURE__*/React.createElement("col", {
    key: c.key,
    style: c.width ? {
      width: c.width
    } : undefined
  }))), /*#__PURE__*/React.createElement("thead", null, /*#__PURE__*/React.createElement("tr", {
    style: {
      background: "var(--lk-fill-thead)"
    }
  }, columns.map(c => /*#__PURE__*/React.createElement("th", {
    key: c.key,
    scope: "col",
    style: {
      boxSizing: "border-box",
      padding: "16px",
      textAlign: c.align || "left",
      borderRight: gridded ? "2px solid var(--lk-black)" : "none",
      borderBottom: gridded ? "2px solid var(--lk-black)" : "none",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      textTransform: "uppercase",
      color: "var(--lk-text)"
    }
  }, c.label)))), /*#__PURE__*/React.createElement("tbody", null, rows.length === 0 ? /*#__PURE__*/React.createElement("tr", {
    style: {
      borderBottom: gridded ? "2px solid var(--lk-black)" : "1px solid var(--lk-fill-ghost)"
    }
  }, /*#__PURE__*/React.createElement("td", {
    colSpan: columns.length || 1,
    style: {
      boxSizing: "border-box",
      padding: cellPad,
      height: rowMin,
      textAlign: "center",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      color: "var(--lk-text-secondary)"
    }
  }, emptyLabel)) : rows.map((row, ri) => /*#__PURE__*/React.createElement("tr", {
    key: row.id ?? ri,
    style: {
      borderTop: gridded ? "1px solid var(--lk-black)" : "none",
      borderBottom: gridded ? "2px solid var(--lk-black)" : "1px solid var(--lk-fill-ghost)"
    }
  }, columns.map(c => /*#__PURE__*/React.createElement("td", {
    key: c.key,
    style: {
      boxSizing: "border-box",
      padding: cellPad,
      height: rowMin,
      verticalAlign: "middle",
      textAlign: c.align || "left",
      borderRight: gridded ? "2px solid var(--lk-black)" : "none",
      fontFamily: c.font === "body" ? "var(--lk-font-body)" : "var(--lk-font-mono)",
      fontWeight: c.strong ? 700 : 500,
      fontSize: 14,
      lineHeight: "19.6px",
      color: "var(--lk-text)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      justifyContent: c.align === "right" ? "flex-end" : c.align === "center" ? "center" : "flex-start"
    }
  }, row[c.key])))))))), footerNote || pagination ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-text-secondary)"
    }
  }, footerNote), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8
    }
  }, pagination)) : null);
}
Object.assign(__ds_scope, { DataTable });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/admin/DataTable.jsx", error: String((e && e.message) || e) }); }

// components/admin/FilterBar.jsx
try { (() => {
/* Filter row for admin list views: mono segment groups + trailing slot. */
function FilterBar({
  groups = [],
  activeValues = {},
  onChange,
  trailing,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 16,
      flexWrap: "wrap",
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 24,
      flexWrap: "wrap"
    }
  }, groups.map(g => /*#__PURE__*/React.createElement("div", {
    key: g.key,
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8
    }
  }, g.label ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase",
      color: "var(--lk-text-technical)"
    }
  }, g.label) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      boxShadow: "var(--lk-ring)"
    }
  }, g.options.map(o => {
    const active = (activeValues[g.key] ?? g.options[0]) === o;
    return /*#__PURE__*/React.createElement("button", {
      key: o,
      type: "button",
      onClick: () => onChange && onChange(g.key, o),
      style: {
        appearance: "none",
        border: "none",
        cursor: "pointer",
        boxSizing: "border-box",
        padding: "3.5px 12px",
        minHeight: 26.39,
        background: active ? "var(--lk-black)" : "var(--lk-white)",
        color: active ? "var(--lk-white)" : "var(--lk-grey-500)",
        fontFamily: "var(--lk-font-mono)",
        fontWeight: 500,
        fontSize: 12,
        lineHeight: "14.4px",
        borderRight: "1px solid var(--lk-black)"
      }
    }, o);
  }))))), trailing ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 16
    }
  }, trailing) : null);
}
Object.assign(__ds_scope, { FilterBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/admin/FilterBar.jsx", error: String((e && e.message) || e) }); }

// components/admin/StatCard.jsx
try { (() => {
/* Admin KPI card (fig: 2px ring + 4px shadow, mono label, Space Grotesk 48 figure,
   orange delta row, faint grey ornament bleeding out of the top-right corner). */
function StatCard({
  label,
  value,
  delta,
  deltaDirection = "up",
  note,
  icon,
  ornament = "circle",
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      overflow: "hidden",
      boxSizing: "border-box",
      flexGrow: 1,
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: "24px 24px 36px 24px",
      display: "flex",
      flexDirection: "column",
      ...style
    }
  }, ornament !== "none" ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      right: -14,
      top: -14,
      width: 96,
      height: 96,
      opacity: 0.5,
      background: "var(--lk-fill-ornament)",
      boxShadow: "var(--lk-ring)",
      borderRadius: ornament === "circle" ? "var(--lk-radius-pill)" : "var(--lk-radius-none)",
      transform: ornament === "square" ? "rotate(12deg)" : "none"
    }
  }) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      display: "flex",
      flexDirection: "column",
      gap: 7.5
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 12,
      height: 24
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      textTransform: "uppercase",
      color: "var(--lk-text-technical)"
    }
  }, label), icon), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 48,
      lineHeight: "52.8px",
      letterSpacing: "var(--lk-ls-display)",
      color: "var(--lk-text)"
    }
  }, value), delta || note ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 4,
      height: 15
    }
  }, delta ? /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("svg", {
    width: "11.667",
    height: "7",
    viewBox: "0 0 11.667 7",
    fill: "var(--lk-orange)",
    style: {
      transform: deltaDirection === "down" ? "scaleY(-1)" : "none"
    },
    "aria-hidden": "true"
  }, /*#__PURE__*/React.createElement("path", {
    d: "M 0.817 7 L 0 6.183 L 4.317 1.837 L 6.65 4.171 L 9.683 1.167 L 8.167 1.167 L 8.167 0 L 11.667 0 L 11.667 3.5 L 10.5 3.5 L 10.5 1.983 L 6.65 5.833 L 4.317 3.5 L 0.817 7 L 0.817 7",
    fillRule: "nonzero"
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-text)"
    }
  }, delta)) : null, note ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-text-secondary)"
    }
  }, note) : null) : null));
}
Object.assign(__ds_scope, { StatCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/admin/StatCard.jsx", error: String((e && e.message) || e) }); }

// components/admin/StatusBadge.jsx
try { (() => {
const TONES = {
  published: {
    bg: "var(--lk-success-bg)",
    dot: "var(--lk-success)",
    fg: "var(--lk-black)"
  },
  draft: {
    bg: "var(--lk-fill-tag)",
    dot: "var(--lk-grey-400)",
    fg: "var(--lk-black)"
  },
  archived: {
    bg: "var(--lk-grey-100)",
    dot: "var(--lk-grey-500)",
    fg: "var(--lk-grey-600)"
  },
  pending: {
    bg: "var(--lk-orange)",
    dot: "var(--lk-black)",
    fg: "var(--lk-black)"
  },
  failed: {
    bg: "var(--lk-white)",
    dot: "var(--lk-danger)",
    fg: "var(--lk-danger)"
  }
};

/* Status pill (fig: 2px hard shadow, 8px dot, mono 14).
   Status is carried by dot + word, never colour alone (DESIGN.md §42, §56). */
function StatusBadge({
  status = "published",
  children,
  style
}) {
  const t = TONES[status] || TONES.draft;
  const text = children || status.charAt(0).toUpperCase() + status.slice(1);
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 8,
      boxSizing: "border-box",
      padding: "3px 8px",
      minHeight: 27.59,
      background: t.bg,
      color: t.fg,
      boxShadow: "var(--lk-shadow-sm)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      whiteSpace: "nowrap",
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 8,
      height: 8,
      borderRadius: "var(--lk-radius-pill)",
      background: t.dot,
      flexShrink: 0
    }
  }), text);
}
Object.assign(__ds_scope, { StatusBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/admin/StatusBadge.jsx", error: String((e && e.message) || e) }); }

// components/core/AppButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const SIZES = {
  sm: {
    height: 26.39,
    padding: "3.5px 12px",
    font: "var(--lk-font-mono)",
    weight: 500,
    size: 12,
    lh: "14.4px",
    ls: "normal",
    upper: false,
    gap: 6,
    ring: true,
    shadow: "none"
  },
  md: {
    height: 48,
    padding: "0 24px",
    font: "var(--lk-font-mono)",
    weight: 500,
    size: 14,
    lh: "19.6px",
    ls: "var(--lk-ls-tech-track)",
    upper: true,
    gap: 12,
    ring: false,
    shadow: "var(--lk-shadow)"
  },
  lg: {
    height: 52,
    padding: "12px 16px",
    font: "var(--lk-font-display)",
    weight: 600,
    size: 18,
    lh: "28px",
    ls: "normal",
    upper: true,
    gap: 8,
    ring: false,
    shadow: "var(--lk-shadow)"
  },
  xl: {
    height: 56,
    padding: "16px 32px",
    font: "var(--lk-font-display)",
    weight: 400,
    size: 16,
    lh: "24px",
    ls: "normal",
    upper: true,
    gap: 12,
    ring: false,
    shadow: "var(--lk-shadow)"
  },
  hero: {
    height: 60.8,
    padding: "15px 24px",
    font: "var(--lk-font-display)",
    weight: 700,
    size: 24,
    lh: "28.8px",
    ls: "normal",
    upper: false,
    gap: 12,
    ring: false,
    shadow: "var(--lk-shadow)"
  }
};
const VARIANTS = {
  primary: {
    bg: "var(--lk-btn-primary-bg)",
    fg: "var(--lk-btn-primary-fg)"
  },
  accent: {
    bg: "var(--lk-btn-accent-bg)",
    fg: "var(--lk-btn-accent-fg)"
  },
  secondary: {
    bg: "var(--lk-btn-secondary-bg)",
    fg: "var(--lk-btn-secondary-fg)"
  },
  ghost: {
    bg: "transparent",
    fg: "var(--lk-text)"
  }
};
function AppButton({
  children,
  variant = "primary",
  size = "lg",
  icon,
  iconPosition = "left",
  block = false,
  disabled = false,
  onClick,
  style,
  ...rest
}) {
  const [pressed, setPressed] = React.useState(false);
  const s = SIZES[size] || SIZES.lg;
  const v = VARIANTS[variant] || VARIANTS.primary;
  const hard = s.shadow !== "none";
  const box = [s.ring || variant === "ghost" ? "var(--lk-ring)" : null, hard ? pressed ? "var(--lk-shadow-pressed)" : "var(--lk-shadow)" : null].filter(Boolean).join(",") || "none";
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    disabled: disabled,
    onClick: onClick,
    onPointerDown: () => setPressed(true),
    onPointerUp: () => setPressed(false),
    onPointerLeave: () => setPressed(false),
    style: {
      appearance: "none",
      border: "none",
      borderRadius: "var(--lk-radius-none)",
      cursor: disabled ? "not-allowed" : "pointer",
      display: block ? "flex" : "inline-flex",
      width: block ? "100%" : "auto",
      flexDirection: iconPosition === "right" ? "row-reverse" : "row",
      alignItems: "center",
      justifyContent: "center",
      gap: s.gap,
      boxSizing: "border-box",
      minHeight: s.height,
      padding: s.padding,
      background: v.bg,
      color: v.fg,
      boxShadow: box,
      fontFamily: s.font,
      fontWeight: s.weight,
      fontSize: s.size,
      lineHeight: s.lh,
      letterSpacing: s.ls,
      textTransform: s.upper ? "uppercase" : "none",
      textAlign: "center",
      whiteSpace: "nowrap",
      opacity: disabled ? 0.4 : 1,
      transform: hard && pressed ? "translate(3px,3px)" : "none",
      transition: "transform var(--lk-duration-fast) var(--lk-ease),box-shadow var(--lk-duration-fast) var(--lk-ease)",
      ...style
    }
  }, rest), icon ? /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      flexShrink: 0
    }
  }, icon) : null, /*#__PURE__*/React.createElement("span", null, children));
}
Object.assign(__ds_scope, { AppButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/AppButton.jsx", error: String((e && e.message) || e) }); }

// components/core/AppCard.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function AppCard({
  children,
  label,
  title,
  action,
  variant = "shadow",
  padding = 24,
  tone = "surface",
  style,
  ...rest
}) {
  const box = variant === "ring" ? "var(--lk-ring-shadow)" : variant === "flat" ? "none" : "var(--lk-shadow)";
  const bg = tone === "accent" ? "var(--lk-orange)" : tone === "inverse" ? "var(--lk-black)" : tone === "sunken" ? "var(--lk-paper)" : "var(--lk-surface)";
  const fg = tone === "inverse" ? "var(--lk-white)" : "var(--lk-text)";
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      boxSizing: "border-box",
      background: bg,
      color: fg,
      boxShadow: box,
      borderRadius: "var(--lk-radius-none)",
      padding,
      display: "flex",
      flexDirection: "column",
      gap: 16,
      ...style
    }
  }, rest), label || title || action ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 7
    }
  }, label ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase",
      color: tone === "inverse" ? "var(--lk-grey-300)" : "var(--lk-text-technical)"
    }
  }, label) : null, title || action ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 12
    }
  }, title ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 600,
      fontSize: 24,
      lineHeight: "28.8px",
      color: "inherit"
    }
  }, title) : /*#__PURE__*/React.createElement("span", null), action) : null) : null, children);
}
Object.assign(__ds_scope, { AppCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/AppCard.jsx", error: String((e && e.message) || e) }); }

// components/core/AppChip.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const VARIANTS = {
  chip: {
    bg: "var(--lk-grey-100)",
    fg: "var(--lk-black)",
    box: "var(--lk-ring-shadow-sm)",
    padding: "4px 12px",
    weight: 500,
    size: 14,
    lh: "19.6px"
  },
  tag: {
    bg: "var(--lk-fill-tag)",
    fg: "var(--lk-black)",
    box: "none",
    padding: "4px 8px",
    weight: 500,
    size: 14,
    lh: "19.6px"
  },
  bento: {
    bg: "var(--lk-fill-chip)",
    fg: "var(--lk-black)",
    box: "var(--lk-shadow)",
    padding: "16px",
    weight: 700,
    size: 14,
    lh: "19.6px"
  },
  accent: {
    bg: "var(--lk-orange)",
    fg: "var(--lk-black)",
    box: "var(--lk-ring)",
    padding: "3.5px 8px",
    weight: 700,
    size: 12,
    lh: "14.4px"
  },
  dark: {
    bg: "var(--lk-black)",
    fg: "var(--lk-white)",
    box: "none",
    padding: "4px 8px",
    weight: 400,
    size: 16,
    lh: "24px"
  }
};
function AppChip({
  children,
  label,
  variant = "chip",
  icon,
  style,
  ...rest
}) {
  const v = VARIANTS[variant] || VARIANTS.chip;
  const stacked = variant === "bento" || label && variant !== "accent";
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: "inline-flex",
      flexDirection: stacked ? "column" : "row",
      alignItems: stacked && variant === "bento" ? "center" : "flex-start",
      gap: variant === "bento" ? 4 : 6,
      boxSizing: "border-box",
      background: v.bg,
      color: v.fg,
      boxShadow: v.box,
      borderRadius: "var(--lk-radius-none)",
      padding: v.padding,
      ...style
    }
  }, rest), label ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      textTransform: "uppercase",
      color: variant === "dark" ? "var(--lk-grey-300)" : "var(--lk-text-technical)"
    }
  }, label) : null, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 6,
      fontFamily: "var(--lk-font-mono)",
      fontWeight: v.weight,
      fontSize: v.size,
      lineHeight: v.lh,
      whiteSpace: "nowrap"
    }
  }, icon, children));
}
Object.assign(__ds_scope, { AppChip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/AppChip.jsx", error: String((e && e.message) || e) }); }

// components/core/AppIconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const VARIANTS = {
  plain: {
    bg: "var(--lk-white)",
    fg: "var(--lk-black)",
    box: "var(--lk-shadow)",
    radius: "var(--lk-radius-none)"
  },
  ring: {
    bg: "var(--lk-white)",
    fg: "var(--lk-black)",
    box: "var(--lk-ring)",
    radius: "var(--lk-radius-none)"
  },
  solid: {
    bg: "var(--lk-black)",
    fg: "var(--lk-white)",
    box: "var(--lk-ring)",
    radius: "var(--lk-radius-none)"
  },
  accent: {
    bg: "var(--lk-orange)",
    fg: "var(--lk-black)",
    box: "var(--lk-ring)",
    radius: "var(--lk-radius-none)"
  },
  circle: {
    bg: "var(--lk-white)",
    fg: "var(--lk-black)",
    box: "var(--lk-ring)",
    radius: "var(--lk-radius-pill)"
  },
  bare: {
    bg: "transparent",
    fg: "var(--lk-black)",
    box: "none",
    radius: "var(--lk-radius-sm)"
  }
};

/* Icon-only control. The button is the touch target and is never smaller than
   --lk-tap-target (44px); the painted box stays at `size`, and a negative
   margin absorbs the difference so the surrounding layout is unchanged.
   `style` therefore applies to the visual box, not the hit area. */
function AppIconButton({
  children,
  variant = "plain",
  size = 36,
  label,
  onClick,
  style,
  ...rest
}) {
  const [pressed, setPressed] = React.useState(false);
  const v = VARIANTS[variant] || VARIANTS.plain;
  const hard = v.box === "var(--lk-shadow)";
  const TAP = 44;
  const bleed = Math.max(0, (TAP - size) / 2);
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    "aria-label": label,
    onClick: onClick,
    onPointerDown: () => setPressed(true),
    onPointerUp: () => setPressed(false),
    onPointerLeave: () => setPressed(false),
    style: {
      appearance: "none",
      border: "none",
      background: "none",
      padding: 0,
      cursor: "pointer",
      boxSizing: "border-box",
      flexShrink: 0,
      minWidth: TAP,
      minHeight: TAP,
      margin: bleed ? `-${bleed}px` : 0,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      color: v.fg
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      boxSizing: "border-box",
      width: size,
      height: size,
      padding: 8,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      background: v.bg,
      color: v.fg,
      borderRadius: v.radius,
      boxShadow: hard && pressed ? "var(--lk-shadow-pressed)" : v.box,
      transform: hard && pressed ? "translate(var(--lk-press-translate),var(--lk-press-translate))" : "none",
      transition: "transform var(--lk-duration-fast) var(--lk-ease),box-shadow var(--lk-duration-fast) var(--lk-ease)",
      ...style
    }
  }, children));
}
Object.assign(__ds_scope, { AppIconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/AppIconButton.jsx", error: String((e && e.message) || e) }); }

// components/core/AppSectionHeader.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function AppSectionHeader({
  title,
  actionLabel,
  onAction,
  size = "md",
  style,
  ...rest
}) {
  const big = size === "lg";
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: "flex",
      alignItems: "flex-end",
      justifyContent: "space-between",
      gap: 16,
      paddingBottom: 8,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: big ? 700 : 600,
      fontSize: big ? 48 : 24,
      lineHeight: big ? "52.8px" : "28.8px",
      letterSpacing: big ? "var(--lk-ls-display)" : "normal",
      textTransform: "uppercase",
      color: "var(--lk-text)"
    }
  }, title), actionLabel ? /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onAction,
    style: {
      appearance: "none",
      background: "none",
      border: "none",
      padding: 0,
      cursor: "pointer",
      display: "inline-flex",
      alignItems: "center",
      gap: 4,
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      textTransform: "uppercase",
      color: "var(--lk-text)"
    }
  }, actionLabel, /*#__PURE__*/React.createElement("svg", {
    width: "9.333",
    height: "9.333",
    viewBox: "0 0 9.333 9.333",
    fill: "currentColor",
    "aria-hidden": "true"
  }, /*#__PURE__*/React.createElement("path", {
    d: "M 7.102 5.25 L 0 5.25 L 0 4.083 L 7.102 4.083 L 3.835 0.817 L 4.667 0 L 9.333 4.667 L 4.667 9.333 L 3.835 8.517 L 7.102 5.25 L 7.102 5.25",
    fillRule: "nonzero"
  }))) : null);
}
Object.assign(__ds_scope, { AppSectionHeader });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/AppSectionHeader.jsx", error: String((e && e.message) || e) }); }

// components/core/AppTextField.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function AppTextField({
  label,
  value,
  placeholder = "",
  icon,
  onChange,
  block = true,
  style,
  inputStyle,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: block ? "flex" : "inline-flex",
      flexDirection: "column",
      gap: 4,
      width: block ? "100%" : "auto",
      ...style
    }
  }, label ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      textTransform: "uppercase",
      color: "var(--lk-text-technical)"
    }
  }, label) : null, /*#__PURE__*/React.createElement("span", {
    style: {
      position: "relative",
      display: "flex",
      alignItems: "stretch"
    }
  }, icon ? /*#__PURE__*/React.createElement("span", {
    style: {
      position: "absolute",
      left: 12,
      top: 0,
      bottom: 0,
      display: "flex",
      alignItems: "center",
      pointerEvents: "none"
    }
  }, icon) : null, /*#__PURE__*/React.createElement("input", _extends({
    value: value,
    placeholder: placeholder,
    onChange: onChange,
    style: {
      appearance: "none",
      border: "none",
      boxSizing: "border-box",
      width: "100%",
      minHeight: 45.59,
      padding: icon ? "12px 12px 13.59px 40px" : "12px 12px 13.59px 12px",
      background: "var(--lk-surface)",
      color: "var(--lk-text)",
      boxShadow: "var(--lk-ring-hairline),var(--lk-shadow)",
      borderRadius: "var(--lk-radius-none)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "100%",
      ...inputStyle
    }
  }, rest))));
}
Object.assign(__ds_scope, { AppTextField });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/AppTextField.jsx", error: String((e && e.message) || e) }); }

// components/core/PremiumBadge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function PremiumBadge({
  children = "PRO",
  tone = "accent",
  size = "md",
  style,
  ...rest
}) {
  const small = size === "sm";
  const accent = tone === "accent";
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      display: "inline-flex",
      alignItems: "center",
      boxSizing: "border-box",
      padding: small ? "2px 6px" : "3.5px 8px",
      background: accent ? "var(--lk-orange)" : "var(--lk-black)",
      color: accent ? "var(--lk-black)" : "var(--lk-white)",
      boxShadow: "var(--lk-ring)",
      borderRadius: "var(--lk-radius-none)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: small ? 10 : 12,
      lineHeight: "14.4px",
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase",
      ...style
    }
  }, rest), children);
}
Object.assign(__ds_scope, { PremiumBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/PremiumBadge.jsx", error: String((e && e.message) || e) }); }

// components/feedback/ConfirmDialog.jsx
try { (() => {
const FOCUSABLE = 'button,[href],input,select,textarea,[tabindex]:not([tabindex="-1"])';

/* Confirm dialog. Rectangular, hard 6px shadow, destructive action stated in words.
   Named via aria-labelledby, focus moves in on open and is restored on close,
   Tab is trapped inside the panel, and Escape or a scrim click cancels. */
function ConfirmDialog({
  open = true,
  title = "DELETE SONG?",
  body,
  confirmLabel = "Delete",
  cancelLabel = "Cancel",
  destructive = true,
  onConfirm,
  onCancel,
  style
}) {
  const panelRef = React.useRef(null);
  const cancelRef = React.useRef(null);
  const titleId = React.useId();
  const bodyId = React.useId();
  React.useEffect(() => {
    if (!open) return undefined;
    const previous = document.activeElement;
    if (cancelRef.current) cancelRef.current.focus();
    const onKeyDown = e => {
      if (e.key === "Escape") {
        e.stopPropagation();
        if (onCancel) onCancel();
        return;
      }
      if (e.key !== "Tab" || !panelRef.current) return;
      const nodes = panelRef.current.querySelectorAll(FOCUSABLE);
      if (!nodes.length) return;
      const first = nodes[0];
      const last = nodes[nodes.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    };
    document.addEventListener("keydown", onKeyDown, true);
    return () => {
      document.removeEventListener("keydown", onKeyDown, true);
      if (previous && typeof previous.focus === "function") previous.focus();
    };
  }, [open, onCancel]);
  if (!open) return null;
  return /*#__PURE__*/React.createElement("div", {
    onClick: e => {
      if (e.target === e.currentTarget && onCancel) onCancel();
    },
    style: {
      position: "relative",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      padding: 24,
      background: "rgba(0,0,0,0.4)",
      boxSizing: "border-box",
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    ref: panelRef,
    role: "dialog",
    "aria-modal": "true",
    "aria-labelledby": titleId,
    "aria-describedby": body ? bodyId : undefined,
    style: {
      width: 380,
      maxWidth: "100%",
      boxSizing: "border-box",
      background: "var(--lk-surface)",
      boxShadow: "inset 0 0 0 2px var(--lk-black),var(--lk-shadow-lg)",
      display: "flex",
      flexDirection: "column"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: 24,
      display: "flex",
      flexDirection: "column",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    id: titleId,
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 24,
      lineHeight: "28.8px",
      textTransform: "uppercase",
      color: destructive ? "var(--lk-danger)" : "var(--lk-text)"
    }
  }, title), body ? /*#__PURE__*/React.createElement("span", {
    id: bodyId,
    style: {
      fontFamily: "var(--lk-font-body)",
      fontWeight: 400,
      fontSize: 16,
      lineHeight: "24px",
      color: "var(--lk-text-secondary)"
    }
  }, body) : null), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 12,
      justifyContent: "flex-end",
      padding: 24,
      borderTop: "2px solid var(--lk-divider)"
    }
  }, /*#__PURE__*/React.createElement("button", {
    ref: cancelRef,
    type: "button",
    onClick: onCancel,
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      background: "var(--lk-white)",
      color: "var(--lk-black)",
      boxShadow: "var(--lk-ring)",
      padding: "0 24px",
      minHeight: 48,
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase"
    }
  }, cancelLabel), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onConfirm,
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      background: destructive ? "var(--lk-danger)" : "var(--lk-black)",
      color: "var(--lk-white)",
      boxShadow: "var(--lk-shadow)",
      padding: "0 24px",
      minHeight: 48,
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase"
    }
  }, confirmLabel))));
}
Object.assign(__ds_scope, { ConfirmDialog });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/ConfirmDialog.jsx", error: String((e && e.message) || e) }); }

// components/feedback/EmptyState.jsx
try { (() => {
/* Empty state with personality but no decoration (DESIGN.md §37). */
function EmptyState({
  headline = "NO FAVORITES YET.",
  body,
  action,
  icon,
  align = "center",
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 12,
      padding: 32,
      boxSizing: "border-box",
      alignItems: align === "center" ? "center" : "flex-start",
      textAlign: align,
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring)",
      ...style
    }
  }, icon, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 24,
      lineHeight: "28.8px",
      textTransform: "uppercase",
      color: "var(--lk-text)"
    }
  }, headline), body ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-body)",
      fontWeight: 400,
      fontSize: 16,
      lineHeight: "24px",
      color: "var(--lk-text-secondary)",
      maxWidth: 320
    }
  }, body) : null, action ? /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 8
    }
  }, action) : null);
}
Object.assign(__ds_scope, { EmptyState });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/EmptyState.jsx", error: String((e && e.message) || e) }); }

// components/music/BpmDisplay.jsx
try { (() => {
/* Large BPM readout + beat indicator (DESIGN.md §27). */
function BpmDisplay({
  bpm = 120,
  beats = 4,
  activeBeat = 0,
  timeSignature = "4/4",
  subdivision,
  size = "lg",
  style
}) {
  const big = size === "lg";
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 12,
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "baseline",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: big ? 48 : 36,
      lineHeight: big ? "52.8px" : "39.6px",
      letterSpacing: big ? "var(--lk-ls-display)" : "var(--lk-ls-h1)",
      color: "var(--lk-text)"
    }
  }, bpm), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase",
      color: "var(--lk-text-technical)"
    }
  }, "BPM")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8
    }
  }, Array.from({
    length: beats
  }).map((_, i) => {
    const on = i === activeBeat;
    const accent = i === 0;
    return /*#__PURE__*/React.createElement("div", {
      key: i,
      style: {
        width: accent ? 16 : 12,
        height: accent ? 16 : 12,
        borderRadius: "var(--lk-radius-pill)",
        background: on ? accent ? "var(--lk-orange)" : "var(--lk-black)" : "transparent",
        boxShadow: "var(--lk-ring)"
      }
    });
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      marginLeft: 8,
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-text-secondary)"
    }
  }, timeSignature, subdivision ? " · " + subdivision : "")));
}
Object.assign(__ds_scope, { BpmDisplay });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/music/BpmDisplay.jsx", error: String((e && e.message) || e) }); }

// components/music/ChordDiagram.jsx
try { (() => {
/* Chord diagram — thick strings, hard fret nut, large finger markers (DESIGN.md §24).
   Geometry transcribed from the chord screen in L Key UIs.fig:
   canvas 360px tall, 32px padding, 16px black fret nut, 256px grid, 4px strings. */
function ChordDiagram({
  name = "C MAJOR",
  strings = 6,
  frets = 4,
  positions = [],
  openStrings = [],
  mutedStrings = [],
  fingers = [],
  width = 278,
  style
}) {
  const gridW = width;
  const gridH = 256;
  const colGap = strings > 1 ? gridW / (strings - 1) : 0;
  const rowH = gridH / frets;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      alignItems: "center",
      ...style
    }
  }, name ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 36,
      lineHeight: "39.6px",
      textTransform: "uppercase",
      color: "var(--lk-text)"
    }
  }, name) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-shadow)",
      padding: 32,
      display: "flex",
      flexDirection: "column",
      gap: 24,
      boxSizing: "border-box"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      width: gridW,
      height: 19.59
    }
  }, Array.from({
    length: strings
  }).map((_, i) => {
    const open = openStrings.includes(i);
    const muted = mutedStrings.includes(i);
    return /*#__PURE__*/React.createElement("span", {
      key: i,
      style: {
        width: 8.41,
        textAlign: "center",
        fontFamily: "var(--lk-font-mono)",
        fontWeight: 700,
        fontSize: 14,
        lineHeight: "19.6px",
        color: muted ? "var(--lk-danger)" : "var(--lk-text)"
      }
    }, muted ? "X" : open ? "O" : "");
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 16,
      background: "var(--lk-black)",
      width: gridW
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      width: gridW,
      height: gridH
    }
  }, Array.from({
    length: strings
  }).map((_, i) => /*#__PURE__*/React.createElement("div", {
    key: "s" + i,
    style: {
      position: "absolute",
      left: i * colGap - 2,
      top: 0,
      width: 4,
      height: gridH,
      background: "var(--lk-string)"
    }
  })), Array.from({
    length: frets
  }).map((_, r) => /*#__PURE__*/React.createElement("div", {
    key: "f" + r,
    style: {
      position: "absolute",
      left: 0,
      top: (r + 1) * rowH - 1,
      width: gridW,
      height: 2,
      background: "var(--lk-black)"
    }
  })), positions.map((p, i) => /*#__PURE__*/React.createElement("div", {
    key: "p" + i,
    style: {
      position: "absolute",
      left: p.string * colGap - 18,
      top: (p.fret - 1) * rowH + rowH / 2 - 18,
      width: 36,
      height: 36,
      borderRadius: "var(--lk-radius-pill)",
      background: p.root ? "var(--lk-marker-root)" : "var(--lk-marker)",
      color: p.root ? "var(--lk-black)" : "var(--lk-white)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 14,
      lineHeight: "19.6px"
    }
  }, p.finger ?? ""))), fingers.length ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      width: gridW
    }
  }, fingers.map((f, i) => /*#__PURE__*/React.createElement("span", {
    key: i,
    style: {
      width: 8.41,
      textAlign: "center",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 14,
      lineHeight: "19.6px",
      color: "var(--lk-text)"
    }
  }, f))) : null));
}
Object.assign(__ds_scope, { ChordDiagram });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/music/ChordDiagram.jsx", error: String((e && e.message) || e) }); }

// components/music/Fretboard.jsx
try { (() => {
const STRING_NAMES = ["E", "B", "G", "D", "A", "E"];

/* Horizontal technical fretboard (DESIGN.md §25). Root notes in Guitar Orange. */
function Fretboard({
  strings = STRING_NAMES,
  frets = 12,
  markers = [],
  fretWidth = 52,
  rowHeight = 40,
  showFretNumbers = true,
  style
}) {
  const width = frets * fretWidth;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "inline-flex",
      flexDirection: "column",
      gap: 8,
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: 16,
      boxSizing: "border-box",
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      width: 20
    }
  }, strings.map((n, i) => /*#__PURE__*/React.createElement("span", {
    key: i,
    style: {
      height: rowHeight,
      display: "flex",
      alignItems: "center",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-text)"
    }
  }, n))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      width,
      height: strings.length * rowHeight,
      background: "var(--lk-paper)",
      boxShadow: "var(--lk-ring)"
    }
  }, strings.map((_, r) => /*#__PURE__*/React.createElement("div", {
    key: "s" + r,
    style: {
      position: "absolute",
      left: 0,
      top: r * rowHeight + rowHeight / 2 - 1,
      width,
      height: 2,
      background: "var(--lk-string)"
    }
  })), Array.from({
    length: frets
  }).map((_, c) => /*#__PURE__*/React.createElement("div", {
    key: "f" + c,
    style: {
      position: "absolute",
      left: (c + 1) * fretWidth - 1,
      top: 0,
      width: c === 0 ? 4 : 2,
      height: strings.length * rowHeight,
      background: "var(--lk-black)"
    }
  })), markers.map((m, i) => /*#__PURE__*/React.createElement("div", {
    key: "m" + i,
    style: {
      position: "absolute",
      left: m.fret * fretWidth - fretWidth / 2 - 13,
      top: m.string * rowHeight + rowHeight / 2 - 13,
      width: 26,
      height: 26,
      borderRadius: "var(--lk-radius-pill)",
      background: m.root ? "var(--lk-marker-root)" : "var(--lk-marker)",
      color: m.root ? "var(--lk-black)" : "var(--lk-white)",
      boxShadow: "var(--lk-ring)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 12,
      lineHeight: "14.4px"
    }
  }, m.label ?? "")))), showFretNumbers ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      paddingLeft: 20
    }
  }, Array.from({
    length: frets
  }).map((_, c) => /*#__PURE__*/React.createElement("span", {
    key: c,
    style: {
      width: fretWidth,
      textAlign: "center",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 10,
      lineHeight: "14.4px",
      color: "var(--lk-text-tertiary)"
    }
  }, c + 1))) : null);
}
Object.assign(__ds_scope, { Fretboard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/music/Fretboard.jsx", error: String((e && e.message) || e) }); }

// components/music/PracticeProgress.jsx
try { (() => {
/* Practice progress: hatched orange fill inside a paper track (fig: Continue Practice).
   Progress, not decoration (DESIGN.md §30-31). */
function PracticeProgress({
  value = 0,
  max = 100,
  label,
  elapsed,
  total,
  height = 32,
  showStripes = true,
  style
}) {
  const pct = Math.max(0, Math.min(100, value / max * 100));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 12,
      ...style
    }
  }, label || elapsed ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "baseline",
      justifyContent: "space-between",
      gap: 8
    }
  }, elapsed ? /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "baseline",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 36,
      lineHeight: "39.6px",
      color: "var(--lk-text)"
    }
  }, elapsed), total ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-text-technical)"
    }
  }, "/ ", total) : null) : null, label ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 400,
      fontSize: 14,
      lineHeight: "19.6px",
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase",
      color: "var(--lk-text-secondary)"
    }
  }, label) : null) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      height,
      overflow: "hidden",
      background: "var(--lk-paper)",
      display: "flex",
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: pct + "%",
      height: "100%",
      background: "var(--lk-orange)",
      borderTop: "1px solid var(--lk-black)",
      borderRight: "2px solid var(--lk-black)",
      borderBottom: "1px solid var(--lk-black)",
      borderLeft: "1px solid var(--lk-black)",
      boxSizing: "border-box",
      position: "relative",
      transition: "width var(--lk-duration) var(--lk-ease)"
    }
  }, showStripes ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      inset: 0,
      opacity: 0.2,
      background: "var(--lk-hatch)"
    }
  }) : null)));
}
Object.assign(__ds_scope, { PracticeProgress });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/music/PracticeProgress.jsx", error: String((e && e.message) || e) }); }

// components/music/SongCard.jsx
try { (() => {
/* Song card (fig: Home "Recent Riffs"). 128px artwork with a 10% black scrim,
   orange BPM badge bottom-right, then title + "ARTIST • TAG" meta row. */
function SongCard({
  title = "Master of Puppets",
  artist = "METALLICA",
  tag = "RHYTHM",
  bpm,
  bpmTone = "accent",
  cover,
  action,
  onClick,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    onClick: onClick,
    style: {
      overflow: "hidden",
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-shadow)",
      display: "flex",
      flexDirection: "column",
      cursor: onClick ? "pointer" : "default",
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      height: 128,
      background: cover ? `url(${cover}) 50% 50% / cover no-repeat` : "var(--lk-grey-200)"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      inset: 0,
      background: "var(--lk-overlay-image)"
    }
  }), bpm ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      right: 8,
      bottom: 8,
      background: bpmTone === "muted" ? "var(--lk-grey-200)" : "var(--lk-orange)",
      boxShadow: "var(--lk-ring)",
      padding: "3.5px 8px",
      boxSizing: "border-box"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-black)"
    }
  }, bpm, " BPM")) : null), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "flex-start",
      padding: 16,
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 4,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 600,
      fontSize: 18,
      lineHeight: "28px",
      color: "var(--lk-text)",
      whiteSpace: "nowrap",
      overflow: "hidden",
      textOverflow: "ellipsis"
    }
  }, title), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      textTransform: "uppercase",
      color: "var(--lk-text-secondary)"
    }
  }, artist, tag ? " • " + tag : "")), action));
}
Object.assign(__ds_scope, { SongCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/music/SongCard.jsx", error: String((e && e.message) || e) }); }

// components/music/TunerMeter.jsx
try { (() => {
/* Tuner meter (DESIGN.md §21-22). Detected note is huge Space Grotesk;
   every technical readout is JetBrains Mono. In-tune introduces Guitar Orange. */
function TunerMeter({
  note = "E",
  octave = 2,
  frequency = 82.41,
  cents = -2,
  tolerance = 3,
  tuning = "STANDARD",
  referencePitch = 440,
  width = 342,
  style
}) {
  const inTune = Math.abs(cents) <= tolerance;
  const clamped = Math.max(-50, Math.min(50, cents));
  const pct = 50 + clamped;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width,
      boxSizing: "border-box",
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: 24,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      gap: 24,
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "baseline",
      gap: 4
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 96,
      lineHeight: "86.4px",
      letterSpacing: "var(--lk-ls-hero)",
      color: inTune ? "var(--lk-in-tune)" : "var(--lk-text)"
    }
  }, note), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 400,
      fontSize: 24,
      lineHeight: "32px",
      color: "var(--lk-text-tertiary)"
    }
  }, octave)), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 400,
      fontSize: 16,
      lineHeight: "24px",
      color: "var(--lk-text-technical)"
    }
  }, frequency.toFixed(2), " Hz"), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      width: "100%",
      height: 48,
      background: "var(--lk-paper)",
      boxShadow: "var(--lk-ring)"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: "50%",
      top: 0,
      width: 2,
      height: "100%",
      background: "var(--lk-black)",
      transform: "translateX(-1px)"
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: pct + "%",
      top: -6,
      width: 4,
      height: 60,
      background: inTune ? "var(--lk-in-tune)" : "var(--lk-black)",
      transform: "translateX(-2px)",
      transition: "left var(--lk-duration) var(--lk-ease)"
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      width: "100%",
      justifyContent: "space-between",
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-text-tertiary)"
    }
  }, "-50"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 14,
      lineHeight: "19.6px",
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase",
      color: inTune ? "var(--lk-in-tune)" : "var(--lk-text)"
    }
  }, inTune ? "IN TUNE" : (cents > 0 ? "+" : "") + cents + " CENTS"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-text-tertiary)"
    }
  }, "+50")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      width: "100%",
      justifyContent: "space-between",
      borderTop: "2px solid var(--lk-divider)",
      paddingTop: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      letterSpacing: "var(--lk-ls-tech-track)",
      textTransform: "uppercase",
      color: "var(--lk-text)"
    }
  }, tuning), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      color: "var(--lk-text-secondary)"
    }
  }, referencePitch, " Hz")));
}
Object.assign(__ds_scope, { TunerMeter });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/music/TunerMeter.jsx", error: String((e && e.message) || e) }); }

// components/navigation/AdminHeader.jsx
try { (() => {
/* Admin page header (fig: title + mono subtitle, actions right-aligned at baseline). */
function AdminHeader({
  title,
  subtitle,
  actions,
  size = "md",
  style
}) {
  const big = size === "lg";
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "flex-end",
      justifyContent: "space-between",
      gap: 24,
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: big ? 48 : 24,
      lineHeight: big ? "52.8px" : "28.8px",
      letterSpacing: big ? "var(--lk-ls-display)" : "normal",
      textTransform: "uppercase",
      color: "var(--lk-text)"
    }
  }, title), subtitle ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      color: "var(--lk-text-secondary)"
    }
  }, subtitle) : null), actions ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 16,
      flexShrink: 0
    }
  }, actions) : null);
}
Object.assign(__ds_scope, { AdminHeader });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/AdminHeader.jsx", error: String((e && e.message) || e) }); }

// components/navigation/AdminSidebar.jsx
try { (() => {
/* Admin desktop navigation drawer (fig: 320px, 4px black rail, orange active row). */
function AdminSidebar({
  brand = "L KEY",
  user,
  items = [],
  activeIndex = 0,
  onSelect,
  footer,
  style
}) {
  return /*#__PURE__*/React.createElement("aside", {
    style: {
      boxSizing: "border-box",
      width: 320,
      minHeight: "100%",
      padding: 24,
      background: "var(--lk-bg)",
      boxShadow: "var(--lk-shadow-rail)",
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between",
      gap: 24,
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 48,
      lineHeight: "52.8px",
      letterSpacing: "var(--lk-ls-display-tight)",
      color: "var(--lk-text)"
    }
  }, brand), user ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 16,
      padding: 12,
      boxSizing: "border-box",
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 48,
      height: 48,
      borderRadius: "var(--lk-radius-pill)",
      overflow: "hidden",
      background: "var(--lk-grey-200)",
      boxShadow: "var(--lk-ring)",
      flexShrink: 0
    }
  }, user.avatar ? /*#__PURE__*/React.createElement("img", {
    src: user.avatar,
    alt: "",
    style: {
      width: "100%",
      height: "100%",
      objectFit: "cover",
      display: "block"
    }
  }) : null), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-body)",
      fontWeight: 700,
      fontSize: 16,
      lineHeight: "24px",
      color: "var(--lk-text)"
    }
  }, user.name), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-text-secondary)"
    }
  }, user.role))) : null), /*#__PURE__*/React.createElement("nav", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 8,
      flexGrow: 1
    }
  }, items.map((item, i) => {
    const active = i === activeIndex;
    return /*#__PURE__*/React.createElement("button", {
      key: item.label,
      type: "button",
      onClick: () => onSelect && onSelect(i),
      style: {
        appearance: "none",
        border: "none",
        cursor: "pointer",
        boxSizing: "border-box",
        textAlign: "left",
        display: "flex",
        alignItems: "center",
        gap: 12,
        height: 52,
        padding: 12,
        background: active ? "var(--lk-orange)" : "transparent",
        boxShadow: active ? "var(--lk-ring-shadow)" : "none",
        color: "var(--lk-text)",
        fontFamily: "var(--lk-font-body)",
        fontWeight: 700,
        fontSize: 16,
        lineHeight: "24px"
      }
    }, item.icon ? /*#__PURE__*/React.createElement("span", {
      style: {
        display: "flex",
        width: 18,
        height: 18,
        flexShrink: 0
      }
    }, item.icon) : null, item.label);
  })), footer);
}
Object.assign(__ds_scope, { AdminSidebar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/AdminSidebar.jsx", error: String((e && e.message) || e) }); }

// components/navigation/BottomNavBar.jsx
try { (() => {
/* Compact bottom tab bar (fig: 71px tall, active tab = orange block with 2px shadow). */
function BottomNavBar({
  items = [],
  activeIndex = 0,
  onSelect,
  style
}) {
  return /*#__PURE__*/React.createElement("nav", {
    style: {
      boxSizing: "border-box",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 10.8,
      height: 71,
      padding: "12px 13.4px",
      background: "var(--lk-bg)",
      ...style
    }
  }, items.map((item, i) => {
    const active = i === activeIndex;
    return /*#__PURE__*/React.createElement("button", {
      key: item.label,
      type: "button",
      "aria-current": active ? "page" : undefined,
      onClick: () => onSelect && onSelect(i),
      style: {
        appearance: "none",
        border: "none",
        cursor: "pointer",
        boxSizing: "border-box",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: 4,
        minWidth: active ? 64 : "var(--lk-tap-target)",
        minHeight: "var(--lk-tap-target)",
        height: 45,
        padding: active ? "4px 17.6px" : "4px",
        background: active ? "var(--lk-nav-active-bg)" : "transparent",
        boxShadow: active ? "var(--lk-shadow-sm)" : "none",
        color: active ? "var(--lk-nav-active-fg)" : "var(--lk-nav-idle-fg)"
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        display: "flex",
        alignItems: "center",
        height: 18
      }
    }, item.icon), /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: "var(--lk-font-mono)",
        fontWeight: 500,
        fontSize: 12,
        lineHeight: "14.4px",
        whiteSpace: "nowrap"
      }
    }, item.label));
  }));
}
Object.assign(__ds_scope, { BottomNavBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/BottomNavBar.jsx", error: String((e && e.message) || e) }); }

// components/navigation/TopAppBar.jsx
try { (() => {
/* Mobile top app bar (fig: every mobile frame). Paper background, 16/24 padding,
   wordmark centred in Space Grotesk. */
function TopAppBar({
  title = "L KEY",
  size = "lg",
  leading,
  trailing,
  style
}) {
  const scale = size === "lg" ? {
    font: 36,
    lh: "39.6px",
    ls: "-1.8px",
    weight: 700
  } : {
    font: 24,
    lh: "28.8px",
    ls: "-1.2px",
    weight: 600
  };
  return /*#__PURE__*/React.createElement("header", {
    style: {
      boxSizing: "border-box",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      padding: "16px 24px",
      background: "var(--lk-bg)",
      minHeight: size === "lg" ? 71.59 : 68,
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      minWidth: 34
    }
  }, leading), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: scale.weight,
      fontSize: scale.font,
      lineHeight: scale.lh,
      letterSpacing: scale.ls,
      textTransform: "uppercase",
      color: "var(--lk-text)",
      whiteSpace: "nowrap"
    }
  }, title), /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "flex-end",
      minWidth: 36
    }
  }, trailing));
}
Object.assign(__ds_scope, { TopAppBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/TopAppBar.jsx", error: String((e && e.message) || e) }); }

// ui_kits/admin_portal/BusinessScreens.jsx
try { (() => {
const {
  DataTable,
  StatCard,
  StatusBadge,
  AppButton,
  AppChip,
  AdminHeader,
  FilterBar
} = window.LKeyDesignSystem_355d7c;

/* ——— Premium plans (DESIGN.md §55). Four plans; every price change is audited.
   Only 25,000 MMK / Yearly is a sourced price — the rest are placeholders. ——— */
const PLANS = [{
  name: "Monthly",
  price: "2,500",
  duration: "30 days",
  best: false,
  available: true
}, {
  name: "3 Months",
  price: "7,000",
  duration: "90 days",
  best: false,
  available: true
}, {
  name: "Yearly",
  price: "25,000",
  duration: "365 days",
  best: true,
  available: true
}, {
  name: "Lifetime",
  price: "60,000",
  duration: "Forever",
  best: false,
  available: false
}];
function PremiumPlansScreen() {
  const [plans, setPlans] = React.useState(PLANS);
  const toggle = i => setPlans(plans.map((p, j) => j === i ? {
    ...p,
    available: !p.available
  } : p));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement(AdminHeader, {
    size: "lg",
    title: "Premium Plans",
    subtitle: "Pricing, duration and availability. All changes are audited.",
    actions: /*#__PURE__*/React.createElement(AppButton, {
      size: "md"
    }, "New Plan")
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "repeat(4,1fr)",
      gap: 16
    }
  }, plans.map((p, i) => /*#__PURE__*/React.createElement("div", {
    key: p.name,
    style: {
      background: p.best ? "var(--lk-orange)" : "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: 20,
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      gap: 10,
      opacity: p.available ? 1 : 0.55
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 12,
      lineHeight: "14.4px",
      letterSpacing: "0.7px",
      textTransform: "uppercase"
    }
  }, p.name, p.best ? " ⭐" : ""), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 36,
      lineHeight: "39.6px",
      letterSpacing: "-1.8px"
    }
  }, p.price), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: p.best ? "var(--lk-black)" : "var(--lk-grey-500)"
    }
  }, "MMK \xB7 ", p.duration), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8,
      marginTop: 6
    }
  }, /*#__PURE__*/React.createElement(AppButton, {
    size: "sm",
    variant: "secondary",
    style: {
      flex: 1
    }
  }, "Edit"), /*#__PURE__*/React.createElement(AppButton, {
    size: "sm",
    variant: p.available ? "primary" : "secondary",
    style: {
      flex: 1
    },
    onClick: () => toggle(i)
  }, p.available ? "Live" : "Off"))))), /*#__PURE__*/React.createElement(DataTable, {
    dense: true,
    columns: [{
      key: "when",
      label: "When",
      width: 150
    }, {
      key: "who",
      label: "Admin",
      width: 140,
      font: "body"
    }, {
      key: "what",
      label: "Change"
    }],
    rows: [{
      when: "2026-08-12 14:02",
      who: "Admin User",
      what: "Yearly price 22,000 → 25,000 MMK"
    }, {
      when: "2026-07-30 09:41",
      who: "Admin User",
      what: "Lifetime plan disabled"
    }, {
      when: "2026-07-02 11:15",
      who: "Admin User",
      what: "3 Months plan created"
    }],
    footerNote: "Audit log \u2014 every pricing change is recorded"
  }));
}

/* ——— Analytics (DESIGN.md §57). Minimal charts, primary metrics only. ——— */
const PRACTICE_BARS = [42, 55, 61, 48, 70, 88, 76];
const DAYS = ["M", "T", "W", "T", "F", "S", "S"];
function AnalyticsScreen() {
  const [range, setRange] = React.useState("7D");
  const max = Math.max(...PRACTICE_BARS);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement(AdminHeader, {
    size: "lg",
    title: "Analytics",
    subtitle: "DAU, retention, practice and conversion \u2014 no decorative charts."
  }), /*#__PURE__*/React.createElement(FilterBar, {
    groups: [{
      key: "range",
      label: "Range",
      options: ["7D", "30D", "90D"]
    }],
    activeValues: {
      range
    },
    onChange: (k, v) => setRange(v)
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(StatCard, {
    label: "DAU",
    value: "2,341",
    delta: "+8.1%",
    ornament: "none"
  }), /*#__PURE__*/React.createElement(StatCard, {
    label: "MAU",
    value: "9,802",
    delta: "+5.4%",
    ornament: "square"
  }), /*#__PURE__*/React.createElement(StatCard, {
    label: "D7 Retention",
    value: "41%",
    note: "target 45%",
    ornament: "none"
  }), /*#__PURE__*/React.createElement(StatCard, {
    label: "Pro Conversion",
    value: "9.6%",
    delta: "+0.8%",
    ornament: "circle"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "2fr 1fr",
      gap: 32
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: 24,
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
      paddingBottom: 16,
      borderBottom: "2px solid var(--lk-divider)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 20,
      lineHeight: "30px"
    }
  }, "Practice Minutes"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      color: "var(--lk-grey-500)"
    }
  }, "avg / user / day")), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 220,
      background: "var(--lk-canvas)",
      boxShadow: "var(--lk-ring)",
      padding: 16,
      boxSizing: "border-box",
      display: "flex",
      alignItems: "flex-end",
      justifyContent: "center",
      gap: 12
    }
  }, PRACTICE_BARS.map((v, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 44,
      height: v / max * 160,
      background: v === max ? "var(--lk-orange)" : "var(--lk-black)",
      boxShadow: "var(--lk-ring)"
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 10,
      color: "var(--lk-text-tertiary)"
    }
  }, DAYS[i]))))), /*#__PURE__*/React.createElement(DataTable, {
    dense: true,
    columns: [{
      key: "tool",
      label: "Popular Tools",
      font: "body"
    }, {
      key: "n",
      label: "Sessions",
      width: 110,
      align: "right",
      strong: true
    }],
    rows: [{
      tool: "Tuner",
      n: "18,204"
    }, {
      tool: "Chords",
      n: "11,873"
    }, {
      tool: "Metronome",
      n: "7,410"
    }, {
      tool: "Songs",
      n: "6,982"
    }, {
      tool: "Scales",
      n: "3,551"
    }]
  })));
}
Object.assign(window, {
  LKAdminPlans: PremiumPlansScreen,
  LKAdminAnalytics: AnalyticsScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/admin_portal/BusinessScreens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/admin_portal/ContentScreens.jsx
try { (() => {
const {
  ContentEditor,
  DataTable,
  StatusBadge,
  AppButton,
  AppTextField,
  AppChip,
  AdminHeader,
  PremiumBadge
} = window.LKeyDesignSystem_355d7c;
const CIcon = window.LKAdminIcon;
const Select = ({
  label,
  value,
  options,
  onChange
}) => /*#__PURE__*/React.createElement("label", {
  style: {
    display: "flex",
    flexDirection: "column",
    gap: 4
  }
}, /*#__PURE__*/React.createElement("span", {
  style: {
    fontFamily: "var(--lk-font-mono)",
    fontWeight: 500,
    fontSize: 12,
    lineHeight: "14.4px",
    textTransform: "uppercase",
    color: "var(--lk-text-technical)"
  }
}, label), /*#__PURE__*/React.createElement("select", {
  value: value,
  onChange: e => onChange && onChange(e.target.value),
  style: {
    appearance: "none",
    border: "none",
    boxSizing: "border-box",
    minHeight: 45.59,
    padding: "12px",
    background: "var(--lk-surface)",
    boxShadow: "var(--lk-ring-hairline),var(--lk-shadow)",
    borderRadius: 0,
    fontFamily: "var(--lk-font-mono)",
    fontWeight: 500,
    fontSize: 14
  }
}, options.map(o => /*#__PURE__*/React.createElement("option", {
  key: o
}, o))));

/* ——— Song editor (DESIGN.md §49–51). Sections incl. Rights; publish is explicit. ——— */
function SongEditorScreen({
  song,
  onBack
}) {
  const s = song || {
    id: "#8022",
    title: "Rainy Yangon",
    artist: "Sai Sai",
    status: "draft"
  };
  const [form, setForm] = React.useState({
    title: s.title,
    artist: s.artist,
    language: "Myanmar",
    genre: "Pop",
    key: "G",
    capo: "2",
    bpm: "92",
    difficulty: "Beginner",
    chords: "[VERSE 1]\nG          C\nWaking up to the sound of the rain...",
    rightsHolder: "",
    source: "",
    permission: "Permission Required"
  });
  const [status, setStatus] = React.useState(s.status);
  const [saved, setSaved] = React.useState(null);
  const set = k => v => {
    setForm(f => ({
      ...f,
      [k]: v
    }));
    setSaved(null);
  };
  const setText = k => e => set(k)(e.target.value);

  // Re-seed when a different song is opened from the database.
  React.useEffect(() => {
    setForm(f => ({
      ...f,
      title: s.title,
      artist: s.artist
    }));
    setStatus(s.status);
    setSaved(null);
  }, [s.id, s.title, s.artist, s.status]);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement(AdminHeader, {
    size: "lg",
    title: "Song Editor",
    subtitle: "Editing " + s.id + " — drafts are never visible to players.",
    actions: /*#__PURE__*/React.createElement(AppButton, {
      size: "md",
      variant: "secondary",
      onClick: onBack
    }, "Back to Database")
  }), /*#__PURE__*/React.createElement(ContentEditor, {
    title: "Song Information",
    status: /*#__PURE__*/React.createElement(StatusBadge, {
      status: status
    }),
    sections: [{
      title: "Basic Information",
      children: /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(AppTextField, {
        label: "Title",
        value: form.title,
        onChange: setText("title")
      }), /*#__PURE__*/React.createElement(AppTextField, {
        label: "Artist",
        value: form.artist,
        onChange: setText("artist")
      }), /*#__PURE__*/React.createElement(Select, {
        label: "Language",
        value: form.language,
        onChange: set("language"),
        options: ["Myanmar", "English"]
      }), /*#__PURE__*/React.createElement(Select, {
        label: "Genre",
        value: form.genre,
        onChange: set("genre"),
        options: ["Pop", "Rock", "Acoustic", "Worship"]
      }))
    }, {
      title: "Music Information",
      columns: 4,
      children: /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Select, {
        label: "Key",
        value: form.key,
        onChange: set("key"),
        options: ["C", "D", "E", "G", "A", "Am", "Em"]
      }), /*#__PURE__*/React.createElement(AppTextField, {
        label: "Capo",
        value: form.capo,
        onChange: setText("capo")
      }), /*#__PURE__*/React.createElement(AppTextField, {
        label: "BPM",
        value: form.bpm,
        onChange: setText("bpm")
      }), /*#__PURE__*/React.createElement(Select, {
        label: "Difficulty",
        value: form.difficulty,
        onChange: set("difficulty"),
        options: ["Beginner", "Intermediate", "Advanced"]
      }))
    }, {
      title: "Chord Content",
      columns: 1,
      children: /*#__PURE__*/React.createElement("textarea", {
        value: form.chords,
        onChange: setText("chords"),
        rows: 5,
        "aria-label": "Chord content",
        style: {
          resize: "vertical",
          border: "none",
          boxSizing: "border-box",
          padding: 12,
          background: "var(--lk-surface)",
          boxShadow: "var(--lk-ring-hairline),var(--lk-shadow)",
          fontFamily: "var(--lk-font-mono)",
          fontWeight: 500,
          fontSize: 14,
          lineHeight: "22px"
        }
      })
    }, {
      title: "Rights",
      children: /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(AppTextField, {
        label: "Content Rights",
        placeholder: "Rights holder",
        value: form.rightsHolder,
        onChange: setText("rightsHolder")
      }), /*#__PURE__*/React.createElement(AppTextField, {
        label: "Source",
        placeholder: "Where this content came from",
        value: form.source,
        onChange: setText("source")
      }), /*#__PURE__*/React.createElement(Select, {
        label: "Permission Status",
        value: form.permission,
        onChange: set("permission"),
        options: ["Licensed", "Owned", "Permission Required"]
      }))
    }],
    actions: /*#__PURE__*/React.createElement(React.Fragment, null, saved ? /*#__PURE__*/React.createElement("span", {
      style: {
        alignSelf: "center",
        marginRight: "auto",
        fontFamily: "var(--lk-font-mono)",
        fontWeight: 500,
        fontSize: 12,
        letterSpacing: "var(--lk-ls-tech-track)",
        textTransform: "uppercase",
        color: "var(--lk-text-secondary)"
      }
    }, saved) : null, /*#__PURE__*/React.createElement(AppButton, {
      size: "md",
      variant: "ghost"
    }, "Preview"), /*#__PURE__*/React.createElement(AppButton, {
      size: "md",
      variant: "secondary",
      onClick: () => {
        setStatus("draft");
        setSaved("Draft saved");
      }
    }, "Save Draft"), /*#__PURE__*/React.createElement(AppButton, {
      size: "md",
      variant: "primary",
      onClick: () => {
        setStatus("published");
        setSaved("Published");
      }
    }, "Publish"))
  }));
}

/* ——— Chords (DESIGN.md §52). Library table; live preview belongs to the editor. ——— */
const CHORDS = [{
  name: "C Major",
  formula: "1 3 5",
  notes: "C E G",
  voicings: 4,
  pro: false
}, {
  name: "A Minor",
  formula: "1 b3 5",
  notes: "A C E",
  voicings: 3,
  pro: false
}, {
  name: "G7",
  formula: "1 3 5 b7",
  notes: "G B D F",
  voicings: 5,
  pro: false
}, {
  name: "Cmaj9",
  formula: "1 3 5 7 9",
  notes: "C E G B D",
  voicings: 2,
  pro: true
}, {
  name: "F#m7b5",
  formula: "1 b3 b5 b7",
  notes: "F# A C E",
  voicings: 2,
  pro: true
}];
function ChordsScreen() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement(AdminHeader, {
    size: "lg",
    title: "Chord Library",
    subtitle: "Formulas, voicings and premium gating.",
    actions: /*#__PURE__*/React.createElement(AppButton, {
      size: "md"
    }, "Add Chord")
  }), /*#__PURE__*/React.createElement(DataTable, {
    columns: [{
      key: "name",
      label: "Chord",
      font: "body",
      strong: true
    }, {
      key: "formula",
      label: "Formula",
      width: 160
    }, {
      key: "notes",
      label: "Notes",
      width: 160
    }, {
      key: "voicings",
      label: "Voicings",
      width: 110,
      align: "center"
    }, {
      key: "tier",
      label: "Tier",
      width: 110
    }, {
      key: "actions",
      label: "Actions",
      width: 100,
      align: "center"
    }],
    rows: CHORDS.map(c => ({
      name: c.name,
      formula: /*#__PURE__*/React.createElement("span", {
        style: {
          letterSpacing: "1.4px",
          fontWeight: 700
        }
      }, c.formula),
      notes: c.notes,
      voicings: c.voicings,
      tier: c.pro ? /*#__PURE__*/React.createElement(PremiumBadge, {
        size: "sm"
      }) : /*#__PURE__*/React.createElement(AppChip, {
        variant: "tag"
      }, "Free"),
      actions: /*#__PURE__*/React.createElement(CIcon, {
        name: "edit",
        w: 15,
        h: 15
      })
    })),
    footerNote: "Showing 5 of 214 chords"
  }));
}
Object.assign(window, {
  LKAdminSongEditor: SongEditorScreen,
  LKAdminChords: ChordsScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/admin_portal/ContentScreens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/admin_portal/DashboardScreen.jsx
try { (() => {
const {
  StatCard,
  DataTable,
  AppButton,
  AppChip,
  StatusBadge
} = window.LKeyDesignSystem_355d7c;
const DbIcon = ({
  name,
  w = 18,
  h
}) => /*#__PURE__*/React.createElement("img", {
  src: "../../assets/icons/" + name + ".svg",
  width: w,
  height: h || w,
  alt: "",
  style: {
    display: "block"
  }
});
const BARS = [{
  h: 66,
  tone: "black",
  label: null
}, {
  h: 96,
  tone: "black",
  label: null
}, {
  h: 120,
  tone: "black",
  label: null
}, {
  h: 138,
  tone: "black",
  label: null
}, {
  h: 150,
  tone: "black",
  label: null
}, {
  h: 165,
  tone: "accent",
  label: "11.2k"
}, {
  h: 187,
  tone: "black",
  label: null
}, {
  h: 210,
  tone: "black",
  label: null
}];
function GrowthChart({
  range,
  onRange
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: "24px 24px 71.56px",
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      gap: 24,
      gridColumn: "1 / span 2"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
      paddingBottom: 16,
      borderBottom: "2px solid var(--lk-divider)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 20,
      lineHeight: "30px"
    }
  }, "User Growth"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8
    }
  }, ["7D", "30D", "ALL"].map(r => /*#__PURE__*/React.createElement(AppButton, {
    key: r,
    size: "sm",
    variant: range === r ? "primary" : "secondary",
    onClick: () => onRange(r)
  }, r)))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      height: 256,
      background: "var(--lk-canvas)",
      boxShadow: "var(--lk-ring)",
      padding: 16,
      boxSizing: "border-box",
      display: "flex",
      alignItems: "flex-end",
      justifyContent: "center",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: 10,
      top: 10,
      height: 220,
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between"
    }
  }, ["15k", "10k", "5k", "0"].map(t => /*#__PURE__*/React.createElement("span", {
    key: t,
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 10,
      lineHeight: "14.4px",
      color: "var(--lk-text-tertiary)"
    }
  }, t))), BARS.map((b, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      position: "relative",
      width: 64.38,
      height: b.h,
      background: b.tone === "accent" ? "var(--lk-orange)" : "var(--lk-black)",
      boxShadow: b.tone === "accent" ? "var(--lk-ring),2px 0px 0px 0px var(--lk-black)" : "var(--lk-ring)"
    }
  }, b.label ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: 2.18,
      top: -30,
      height: 36,
      background: "var(--lk-black)",
      boxShadow: "var(--lk-ring)",
      padding: 4,
      boxSizing: "border-box"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 400,
      fontSize: 16,
      lineHeight: "24px",
      color: "var(--lk-white)"
    }
  }, b.label)) : null))));
}
function PaymentsPanel() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      overflow: "hidden",
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      display: "flex",
      flexDirection: "column"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      padding: 24,
      borderBottom: "2px solid var(--lk-divider)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 20,
      lineHeight: "30px"
    }
  }, "Recent Payments"), /*#__PURE__*/React.createElement(DbIcon, {
    name: "more-horizontal",
    w: 16,
    h: 4
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "0 0 0 0"
    }
  }, /*#__PURE__*/React.createElement(DataTable, {
    dense: true,
    gridded: true,
    style: {
      gap: 0
    },
    columns: [{
      key: "id",
      label: "ID",
      width: 78,
      strong: true
    }, {
      key: "user",
      label: "User",
      width: 78,
      strong: true
    }, {
      key: "plan",
      label: "Plan",
      width: 62,
      strong: true
    }, {
      key: "bar",
      label: "",
      width: 61,
      align: "center"
    }],
    rows: [{
      id: "#8021",
      user: "J. Smith",
      plan: "Pro",
      bar: /*#__PURE__*/React.createElement("div", {
        style: {
          height: 12,
          width: "100%",
          background: "var(--lk-orange)",
          boxShadow: "var(--lk-ring)"
        }
      })
    }, {
      id: "#8020",
      user: "K. Aung",
      plan: "Pro",
      bar: /*#__PURE__*/React.createElement("div", {
        style: {
          height: 12,
          width: "100%",
          background: "var(--lk-orange)",
          boxShadow: "var(--lk-ring)"
        }
      })
    }, {
      id: "#8019",
      user: "M. Thant",
      plan: "Pro",
      bar: /*#__PURE__*/React.createElement("div", {
        style: {
          height: 12,
          width: "100%",
          background: "var(--lk-orange)",
          boxShadow: "var(--lk-ring)"
        }
      })
    }, {
      id: "#8018",
      user: "S. Win",
      plan: "Pro",
      bar: /*#__PURE__*/React.createElement("div", {
        style: {
          height: 12,
          width: "100%",
          background: "var(--lk-orange)",
          boxShadow: "var(--lk-ring)"
        }
      })
    }]
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: 24,
      borderTop: "2px solid var(--lk-divider)"
    }
  }, /*#__PURE__*/React.createElement("a", {
    href: "#payments",
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      letterSpacing: "0.7px",
      textTransform: "uppercase"
    }
  }, "View All Transactions")));
}
function DashboardScreen() {
  const [range, setRange] = React.useState("7D");
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 32
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "flex-end",
      justifyContent: "space-between",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 24,
      lineHeight: "28.8px",
      textTransform: "uppercase"
    }
  }, "Dashboard"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      color: "var(--lk-grey-500)"
    }
  }, "Platform health, content and revenue at a glance.")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(AppButton, {
    size: "md",
    variant: "secondary",
    icon: /*#__PURE__*/React.createElement(DbIcon, {
      name: "history-clock",
      w: 14,
      h: 14
    })
  }, "Last 7 days"), /*#__PURE__*/React.createElement(AppButton, {
    size: "md",
    variant: "primary",
    icon: /*#__PURE__*/React.createElement(DbIcon, {
      name: "download",
      w: 14,
      h: 14
    })
  }, "Export Report"))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(StatCard, {
    label: "Total Users",
    value: "12,542",
    delta: "+14.2%",
    icon: /*#__PURE__*/React.createElement(DbIcon, {
      name: "users",
      w: 22,
      h: 16
    })
  }), /*#__PURE__*/React.createElement(StatCard, {
    label: "Active Today",
    value: "2,341",
    delta: "+8.1%",
    ornament: "square"
  }), /*#__PURE__*/React.createElement(StatCard, {
    label: "Premium",
    value: "1,203",
    delta: "+3.4%"
  }), /*#__PURE__*/React.createElement(StatCard, {
    label: "Songs",
    value: "4,892",
    note: "+24 this week",
    icon: /*#__PURE__*/React.createElement(DbIcon, {
      name: "library-music",
      w: 18,
      h: 18
    }),
    ornament: "none"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 1fr 1fr",
      gap: 32
    }
  }, /*#__PURE__*/React.createElement(GrowthChart, {
    range: range,
    onRange: setRange
  }), /*#__PURE__*/React.createElement(PaymentsPanel, null)));
}
Object.assign(window, {
  LKAdminDashboard: DashboardScreen,
  LKAdminIcon: DbIcon
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/admin_portal/DashboardScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/admin_portal/PeopleScreens.jsx
try { (() => {
const {
  DataTable,
  StatusBadge,
  StatCard,
  FilterBar,
  AppButton,
  AppTextField,
  AppChip,
  AdminHeader,
  ConfirmDialog,
  PremiumBadge
} = window.LKeyDesignSystem_355d7c;
const PIcon = window.LKAdminIcon;

/* ——— User management (DESIGN.md §Admin Portal → User Management). ——— */
const USERS = [{
  id: "#U-1042",
  name: "Kyaw Zin",
  plan: "Pro",
  joined: "2026-03-14",
  active: "Today",
  status: "published",
  word: "Active"
}, {
  id: "#U-1041",
  name: "May Thu",
  plan: "Free",
  joined: "2026-03-12",
  active: "Yesterday",
  status: "published",
  word: "Active"
}, {
  id: "#U-0977",
  name: "J. Smith",
  plan: "Pro",
  joined: "2026-01-30",
  active: "3d ago",
  status: "draft",
  word: "Inactive"
}, {
  id: "#U-0871",
  name: "Aung Ko",
  plan: "Free",
  joined: "2025-11-02",
  active: "41d ago",
  status: "failed",
  word: "Suspended"
}];
function UsersScreen() {
  const [filters, setFilters] = React.useState({
    plan: "All",
    status: "All"
  });
  const [confirm, setConfirm] = React.useState(null);
  const rows = USERS.filter(u => (filters.plan === "All" || u.plan === filters.plan) && (filters.status === "All" || u.word === filters.status));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement(AdminHeader, {
    size: "lg",
    title: "User Management",
    subtitle: "Search, subscriptions, activity, suspension.",
    actions: /*#__PURE__*/React.createElement("div", {
      style: {
        width: 320
      }
    }, /*#__PURE__*/React.createElement(AppTextField, {
      placeholder: "Search name or ID...",
      icon: /*#__PURE__*/React.createElement(PIcon, {
        name: "search",
        w: 18,
        h: 18
      })
    }))
  }), /*#__PURE__*/React.createElement(FilterBar, {
    groups: [{
      key: "plan",
      label: "Plan",
      options: ["All", "Pro", "Free"]
    }, {
      key: "status",
      label: "Status",
      options: ["All", "Active", "Inactive", "Suspended"]
    }],
    activeValues: filters,
    onChange: (k, v) => setFilters({
      ...filters,
      [k]: v
    }),
    trailing: /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: "var(--lk-font-mono)",
        fontWeight: 500,
        fontSize: 12,
        color: "var(--lk-grey-500)"
      }
    }, rows.length, " of 12,542 users")
  }), /*#__PURE__*/React.createElement(DataTable, {
    columns: [{
      key: "id",
      label: "ID",
      width: 110,
      strong: true
    }, {
      key: "name",
      label: "User",
      font: "body",
      strong: true
    }, {
      key: "plan",
      label: "Plan",
      width: 96
    }, {
      key: "joined",
      label: "Joined",
      width: 130
    }, {
      key: "active",
      label: "Last Active",
      width: 130
    }, {
      key: "status",
      label: "Status",
      width: 140
    }, {
      key: "actions",
      label: "Actions",
      width: 130,
      align: "center"
    }],
    rows: rows.map(u => ({
      id: u.id,
      name: u.name,
      plan: u.plan === "Pro" ? /*#__PURE__*/React.createElement(PremiumBadge, {
        size: "sm"
      }) : /*#__PURE__*/React.createElement(AppChip, {
        variant: "tag"
      }, "Free"),
      joined: u.joined,
      active: u.active,
      status: /*#__PURE__*/React.createElement(StatusBadge, {
        status: u.status
      }, u.word),
      actions: u.word === "Suspended" ? /*#__PURE__*/React.createElement(AppButton, {
        size: "sm",
        variant: "secondary",
        onClick: () => setConfirm({
          u,
          restore: true
        })
      }, "Restore") : /*#__PURE__*/React.createElement(AppButton, {
        size: "sm",
        variant: "secondary",
        onClick: () => setConfirm({
          u
        })
      }, "Suspend")
    })),
    footerNote: "Showing 4 of 12,542 users",
    pagination: /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(AppButton, {
      size: "sm",
      variant: "primary"
    }, "1"), /*#__PURE__*/React.createElement(AppButton, {
      size: "sm",
      variant: "secondary"
    }, "2"), /*#__PURE__*/React.createElement(AppButton, {
      size: "sm",
      variant: "secondary"
    }, "Next \u203A"))
  }), confirm ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: "fixed",
      inset: 0,
      zIndex: 10
    }
  }, /*#__PURE__*/React.createElement(ConfirmDialog, {
    open: true,
    destructive: !confirm.restore,
    title: confirm.restore ? "Restore user?" : "Suspend user?",
    body: confirm.u.name + " (" + confirm.u.id + ") will " + (confirm.restore ? "regain access immediately." : "lose access until restored. Their data is kept."),
    confirmLabel: confirm.restore ? "Restore" : "Suspend",
    onConfirm: () => setConfirm(null),
    onCancel: () => setConfirm(null),
    style: {
      height: "100%"
    }
  })) : null);
}

/* ——— Payments (DESIGN.md §56). Status shown as word + dot, backend is truth. ——— */
const PAYMENTS = [{
  id: "ORD-8021",
  user: "Kyaw Zin",
  plan: "Yearly",
  amount: "25,000",
  provider: "MyanMyanPay",
  ref: "MMP-99811",
  status: "published",
  word: "Complete",
  time: "08:31"
}, {
  id: "ORD-8020",
  user: "May Thu",
  plan: "Monthly",
  amount: "2,500",
  provider: "MyanMyanPay",
  ref: "MMP-99807",
  status: "pending",
  word: "Pending",
  time: "08:22"
}, {
  id: "ORD-8019",
  user: "Aung Ko",
  plan: "Yearly",
  amount: "25,000",
  provider: "MyanMyanPay",
  ref: "MMP-99794",
  status: "failed",
  word: "Failed",
  time: "07:58"
}, {
  id: "ORD-8018",
  user: "S. Win",
  plan: "Monthly",
  amount: "2,500",
  provider: "MyanMyanPay",
  ref: "MMP-99790",
  status: "published",
  word: "Complete",
  time: "07:12"
}];
function PaymentsScreen() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement(AdminHeader, {
    size: "lg",
    title: "Payments",
    subtitle: "MMQR orders, provider references and webhook state.",
    actions: /*#__PURE__*/React.createElement(AppButton, {
      size: "md",
      variant: "secondary",
      icon: /*#__PURE__*/React.createElement(PIcon, {
        name: "download",
        w: 14,
        h: 14
      })
    }, "Export CSV")
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(StatCard, {
    label: "Revenue (30d)",
    value: "4.2M",
    note: "MMK",
    icon: /*#__PURE__*/React.createElement(PIcon, {
      name: "history-clock",
      w: 16,
      h: 16
    })
  }), /*#__PURE__*/React.createElement(StatCard, {
    label: "Successful",
    value: "182",
    delta: "+11%",
    ornament: "square"
  }), /*#__PURE__*/React.createElement(StatCard, {
    label: "Failed",
    value: "9",
    note: "webhook mismatches: 0",
    ornament: "none"
  })), /*#__PURE__*/React.createElement(DataTable, {
    columns: [{
      key: "id",
      label: "Order",
      width: 120,
      strong: true
    }, {
      key: "user",
      label: "User",
      font: "body"
    }, {
      key: "plan",
      label: "Plan",
      width: 100
    }, {
      key: "amount",
      label: "MMK",
      width: 100,
      align: "right"
    }, {
      key: "provider",
      label: "Provider",
      width: 140
    }, {
      key: "ref",
      label: "Ref",
      width: 120
    }, {
      key: "status",
      label: "Status",
      width: 130
    }, {
      key: "time",
      label: "Time",
      width: 90
    }],
    rows: PAYMENTS.map(p => ({
      ...p,
      status: /*#__PURE__*/React.createElement(StatusBadge, {
        status: p.status
      }, p.word)
    })),
    footerNote: "Showing 4 of 191 orders this month"
  }));
}
Object.assign(window, {
  LKAdminUsers: UsersScreen,
  LKAdminPayments: PaymentsScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/admin_portal/PeopleScreens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/admin_portal/SongDatabaseScreen.jsx
try { (() => {
const {
  DataTable,
  StatusBadge,
  AppChip,
  AppButton,
  AppTextField,
  AppIconButton,
  AppSectionHeader
} = window.LKeyDesignSystem_355d7c;
const Icon = window.LKAdminIcon;
const ROWS = [{
  id: "#8021",
  title: "Neon Skyline",
  artist: "The Midnight",
  key: "C#m",
  bpm: "118",
  status: "published"
}, {
  id: "#8022",
  title: "Rainy Yangon",
  artist: "Sai Sai",
  key: "A Mix",
  bpm: "105",
  status: "draft"
}, {
  id: "#8023",
  title: "Acoustic Guitar Song",
  artist: "L Key Originals",
  key: "E Maj",
  bpm: "85",
  status: "published"
}, {
  id: "#8024",
  title: "Slow Burn",
  artist: "Iron Cross",
  key: "D Min",
  bpm: "140",
  status: "archived"
}];
function SongDatabaseScreen({
  onDelete,
  onEdit
}) {
  const [query, setQuery] = React.useState("");
  const rows = ROWS.filter(r => (r.id + r.title + r.artist).toLowerCase().includes(query.toLowerCase()));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "flex-end",
      justifyContent: "space-between",
      gap: 24,
      padding: "16px 0"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 48,
      lineHeight: "52.8px",
      letterSpacing: "-0.96px",
      textTransform: "uppercase"
    }
  }, "SONG DATABASE"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      color: "var(--lk-grey-500)"
    }
  }, "Manage library, metadata, and publication status.")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 320
    }
  }, /*#__PURE__*/React.createElement(AppTextField, {
    placeholder: "Search ID, Title, Artist...",
    value: query,
    onChange: e => setQuery(e.target.value),
    icon: /*#__PURE__*/React.createElement(Icon, {
      name: "search",
      w: 18,
      h: 18
    })
  })), /*#__PURE__*/React.createElement(AppButton, {
    size: "md",
    variant: "primary",
    style: {
      width: 189.22
    },
    icon: /*#__PURE__*/React.createElement("svg", {
      width: "14",
      height: "14",
      viewBox: "0 0 14 14",
      fill: "#fff"
    }, /*#__PURE__*/React.createElement("path", {
      d: "M 6 8 L 0 8 L 0 6 L 6 6 L 6 0 L 8 0 L 8 6 L 14 6 L 14 8 L 8 8 L 8 14 L 6 14 L 6 8 Z"
    }))
  }, "Add New Song"))), /*#__PURE__*/React.createElement(DataTable, {
    columns: [{
      key: "id",
      label: "ID",
      width: 96,
      strong: false
    }, {
      key: "title",
      label: "Title",
      font: "body"
    }, {
      key: "artist",
      label: "Artist"
    }, {
      key: "key",
      label: "Key",
      width: 96
    }, {
      key: "bpm",
      label: "BPM",
      width: 96
    }, {
      key: "status",
      label: "Status",
      width: 136
    }, {
      key: "actions",
      label: "Actions",
      width: 112,
      align: "center"
    }],
    rows: rows.map(r => ({
      id: r.id,
      title: r.title,
      artist: r.artist,
      key: /*#__PURE__*/React.createElement(AppChip, {
        variant: "tag"
      }, r.key),
      bpm: r.bpm,
      status: /*#__PURE__*/React.createElement(StatusBadge, {
        status: r.status
      }),
      actions: /*#__PURE__*/React.createElement("span", {
        style: {
          display: "flex",
          gap: 8
        }
      }, /*#__PURE__*/React.createElement(AppIconButton, {
        label: "Edit",
        variant: "bare",
        size: 23,
        onClick: () => onEdit && onEdit(r)
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "edit",
        w: 15,
        h: 15
      })), /*#__PURE__*/React.createElement(AppIconButton, {
        label: "Delete",
        variant: "bare",
        size: 26,
        onClick: () => onDelete && onDelete(r)
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "trash",
        w: 18.333,
        h: 16.5
      })))
    })),
    footerNote: "Showing 1 to " + rows.length + " of 42 entries",
    pagination: /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(AppButton, {
      size: "sm",
      variant: "secondary",
      style: {
        opacity: 0.5
      }
    }, "< Prev"), /*#__PURE__*/React.createElement(AppButton, {
      size: "sm",
      variant: "primary"
    }, "1"), /*#__PURE__*/React.createElement(AppButton, {
      size: "sm",
      variant: "secondary"
    }, "2"), /*#__PURE__*/React.createElement(AppButton, {
      size: "sm",
      variant: "secondary"
    }, "3"), /*#__PURE__*/React.createElement(AppButton, {
      size: "sm",
      variant: "secondary"
    }, "Next >"))
  }));
}
Object.assign(window, {
  LKAdminSongDatabase: SongDatabaseScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/admin_portal/SongDatabaseScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile_app/ChordScreen.jsx
try { (() => {
const {
  ChordDiagram,
  AppButton,
  AppChip
} = window.LKeyDesignSystem_355d7c;
const {
  PlayGlyph
} = window.LKGlyphs;
function ChordScreen() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "24px 24px 100px",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      gap: 48
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      paddingTop: 8
    }
  }, /*#__PURE__*/React.createElement(ChordDiagram, {
    name: "C MAJOR",
    width: 278,
    strings: 6,
    frets: 4,
    mutedStrings: [0],
    openStrings: [2, 5],
    positions: [{
      string: 1,
      fret: 3,
      finger: 3
    }, {
      string: 2,
      fret: 2,
      finger: 2
    }, {
      string: 4,
      fret: 1,
      finger: 1,
      root: true
    }],
    fingers: ["", "C", "E", "G", "C", "E"]
  })), /*#__PURE__*/React.createElement(AppButton, {
    variant: "accent",
    size: "hero",
    icon: /*#__PURE__*/React.createElement(PlayGlyph, null),
    style: {
      width: 252.63
    }
  }, "Play Chord"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16,
      width: "100%",
      justifyContent: "center"
    }
  }, /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "FORMULA",
    style: {
      flex: 1
    }
  }, "1 3 5"), /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "ROOT NOTE",
    style: {
      flex: 1
    }
  }, "C")));
}
Object.assign(window, {
  LKMobileChord: ChordScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile_app/ChordScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile_app/HomeScreen.jsx
try { (() => {
const NS = window.LKeyDesignSystem_355d7c;
const {
  TopAppBar,
  AppIconButton,
  AppButton,
  AppCard,
  AppChip,
  SongCard,
  PracticeProgress,
  AppSectionHeader
} = NS;
const HmIcon = ({
  name,
  w = 20,
  h
}) => /*#__PURE__*/React.createElement("img", {
  src: "../../assets/icons/" + name + ".svg",
  width: w,
  height: h || w,
  alt: "",
  style: {
    display: "block"
  }
});
const MenuGlyph = () => /*#__PURE__*/React.createElement("svg", {
  width: "18",
  height: "12",
  viewBox: "0 0 18 12",
  fill: "currentColor"
}, /*#__PURE__*/React.createElement("path", {
  d: "M 0 12 L 0 10 L 18 10 L 18 12 L 0 12 M 0 7 L 0 5 L 18 5 L 18 7 L 0 7 M 0 2 L 0 0 L 18 0 L 18 2 L 0 2 Z"
}));
const TuneGlyph = ({
  s = 27,
  c = "#000"
}) => /*#__PURE__*/React.createElement("svg", {
  width: s,
  height: s,
  viewBox: "0 0 27 27",
  fill: c
}, /*#__PURE__*/React.createElement("path", {
  d: "M 12 27 L 12 18 L 15 18 L 15 21 L 27 21 L 27 24 L 15 24 L 15 27 L 12 27 M 0 24 L 0 21 L 9 21 L 9 24 L 0 24 M 6 18 L 6 15 L 0 15 L 0 12 L 6 12 L 6 9 L 9 9 L 9 18 L 6 18 M 12 15 L 12 12 L 27 12 L 27 15 L 12 15 M 18 9 L 18 0 L 21 0 L 21 3 L 27 3 L 27 6 L 21 6 L 21 9 L 18 9 M 0 6 L 0 3 L 15 3 L 15 6 L 0 6 Z"
}));
const PlayGlyph = ({
  c = "#000"
}) => /*#__PURE__*/React.createElement("svg", {
  width: "11",
  height: "14",
  viewBox: "0 0 11 14",
  fill: c
}, /*#__PURE__*/React.createElement("path", {
  d: "M 0 14 L 0 0 L 11 7 L 0 14 Z"
}));
const ArrowGlyph = ({
  c = "#fff"
}) => /*#__PURE__*/React.createElement("svg", {
  width: "16",
  height: "16",
  viewBox: "0 0 16 16",
  fill: c
}, /*#__PURE__*/React.createElement("path", {
  d: "M 12.175 9 L 0 9 L 0 7 L 12.175 7 L 6.575 1.4 L 8 0 L 16 8 L 8 16 L 6.575 14.6 L 12.175 9 Z"
}));
const PlusGlyph = () => /*#__PURE__*/React.createElement("svg", {
  width: "17.5",
  height: "17.5",
  viewBox: "0 0 17.5 17.5",
  fill: "#000"
}, /*#__PURE__*/React.createElement("path", {
  d: "M 7.5 10 L 0 10 L 0 7.5 L 7.5 7.5 L 7.5 0 L 10 0 L 10 7.5 L 17.5 7.5 L 17.5 10 L 10 10 L 10 17.5 L 7.5 17.5 L 7.5 10 Z"
}));
function AppBar({
  onMenu
}) {
  return /*#__PURE__*/React.createElement(TopAppBar, {
    leading: /*#__PURE__*/React.createElement(AppIconButton, {
      label: "Menu",
      variant: "plain",
      size: 34,
      style: {
        height: 28
      },
      onClick: onMenu
    }, /*#__PURE__*/React.createElement(MenuGlyph, null)),
    trailing: /*#__PURE__*/React.createElement(AppIconButton, {
      label: "Settings",
      variant: "plain"
    }, /*#__PURE__*/React.createElement(HmIcon, {
      name: "settings",
      w: 20.1,
      h: 20
    }))
  });
}
function HomeScreen({
  onOpenChord,
  onOpenSong,
  onTune,
  onPractice
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 32,
      padding: "0 24px 24px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 7
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 400,
      fontSize: 24,
      lineHeight: "28.8px"
    }
  }, "Good Morning,"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 400,
      fontSize: 36,
      lineHeight: "39.6px",
      textTransform: "uppercase"
    }
  }, "GUITARIST!")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    onClick: onTune,
    style: {
      minHeight: 200,
      background: "var(--lk-orange)",
      boxShadow: "var(--lk-shadow)",
      padding: 24,
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between",
      cursor: "pointer"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "flex-start"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 600,
      fontSize: 24,
      lineHeight: "28.8px"
    }
  }, "Quick Tune"), /*#__PURE__*/React.createElement(TuneGlyph, null)), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "32px 0 0",
      display: "flex",
      justifyContent: "space-between",
      alignItems: "flex-end"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      textTransform: "uppercase"
    }
  }, "STANDARD E"), /*#__PURE__*/React.createElement(AppIconButton, {
    label: "Start tuner",
    variant: "circle",
    size: 48
  }, /*#__PURE__*/React.createElement(PlayGlyph, null)))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, ["Metronome", "Chords", "Scales"].map(t => /*#__PURE__*/React.createElement("button", {
    key: t,
    type: "button",
    onClick: t === "Chords" ? onOpenChord : undefined,
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      minHeight: 60,
      background: "var(--lk-white)",
      boxShadow: "var(--lk-shadow)",
      padding: 16,
      boxSizing: "border-box",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: "center",
      fontFamily: "var(--lk-font-display)",
      fontWeight: 600,
      fontSize: 18,
      lineHeight: "28px"
    }
  }, t), /*#__PURE__*/React.createElement(HmIcon, {
    name: "stack-pin",
    w: 20
  }))))), /*#__PURE__*/React.createElement(AppCard, {
    style: {
      padding: "23px 24px 24px",
      gap: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 7
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 400,
      fontSize: 24,
      lineHeight: "28.8px"
    }
  }, "Daily Session"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 400,
      fontSize: 14,
      lineHeight: "19.6px",
      letterSpacing: "0.7px",
      textTransform: "uppercase",
      color: "var(--lk-grey-500)"
    }
  }, "FOCUS: PENTATONIC SPEED"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "baseline",
      gap: 8,
      paddingTop: 9
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 36,
      lineHeight: "39.6px"
    }
  }, "30:00"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-grey-600)"
    }
  }, "/ 60:00 MIN"))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "16px 0",
      display: "flex",
      flexDirection: "column",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(PracticeProgress, {
    value: 49,
    max: 100
  }), /*#__PURE__*/React.createElement(AppButton, {
    variant: "primary",
    size: "lg",
    block: true,
    iconPosition: "right",
    icon: /*#__PURE__*/React.createElement(ArrowGlyph, null),
    onClick: onPractice
  }, "Resume"))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 23.99
    }
  }, /*#__PURE__*/React.createElement(AppSectionHeader, {
    title: "Recent Riffs",
    actionLabel: "View library"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(SongCard, {
    title: "Master of Puppets",
    artist: "METALLICA",
    tag: "RHYTHM",
    bpm: 120,
    cover: "../../assets/images/song-cover-1.jpg",
    onClick: onOpenSong,
    action: /*#__PURE__*/React.createElement(AppIconButton, {
      label: "More",
      variant: "bare",
      size: 16,
      style: {
        height: 35,
        padding: 0
      }
    }, /*#__PURE__*/React.createElement(HmIcon, {
      name: "more-vertical",
      w: 4,
      h: 16
    }))
  }), /*#__PURE__*/React.createElement(SongCard, {
    title: "Voodoo Child",
    artist: "JIMI HENDRIX",
    tag: "LEAD",
    bpm: 85,
    bpmTone: "muted",
    cover: "../../assets/images/song-cover-2.jpg",
    onClick: onOpenSong,
    action: /*#__PURE__*/React.createElement(AppIconButton, {
      label: "More",
      variant: "bare",
      size: 16,
      style: {
        height: 35,
        padding: 0
      }
    }, /*#__PURE__*/React.createElement(HmIcon, {
      name: "more-vertical-alt",
      w: 4,
      h: 16
    }))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      minHeight: 220,
      background: "var(--lk-grey-100)",
      boxShadow: "var(--lk-shadow)",
      padding: "55.6px 24px",
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      paddingBottom: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 64,
      height: 64,
      borderRadius: "var(--lk-radius-pill)",
      background: "var(--lk-white)",
      boxShadow: "var(--lk-ring)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center"
    }
  }, /*#__PURE__*/React.createElement(PlusGlyph, null))), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 600,
      fontSize: 24,
      lineHeight: "28.8px"
    }
  }, "Import Tab")))));
}
Object.assign(window, {
  LKMobileHome: HomeScreen,
  LKMobileAppBar: AppBar,
  LKGlyphs: {
    MenuGlyph,
    TuneGlyph,
    PlayGlyph,
    ArrowGlyph,
    PlusGlyph,
    Icon: HmIcon
  }
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile_app/HomeScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile_app/LibraryScreens.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  AppTextField,
  SongCard,
  AppCard,
  AppChip,
  AppButton,
  AppIconButton,
  AppSectionHeader,
  PracticeProgress,
  EmptyState,
  PremiumBadge
} = window.LKeyDesignSystem_355d7c;
const {
  Icon: SIcon
} = window.LKGlyphs;
const H1s = ({
  children
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    fontFamily: "var(--lk-font-display)",
    fontWeight: 700,
    fontSize: 36,
    lineHeight: "39.6px",
    letterSpacing: "-1.8px",
    textTransform: "uppercase"
  }
}, children);
const SUBs = ({
  children
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    fontFamily: "var(--lk-font-mono)",
    fontWeight: 500,
    fontSize: 14,
    lineHeight: "19.6px",
    letterSpacing: "0.7px",
    textTransform: "uppercase",
    color: "var(--lk-grey-500)"
  }
}, children);

/* ——— Song library (README.md → Songs: search, categories, favorites). ——— */
const LIB = [{
  title: "Master of Puppets",
  artist: "METALLICA",
  tag: "RHYTHM",
  bpm: 120,
  cover: "../../assets/images/song-cover-1.jpg"
}, {
  title: "Voodoo Child",
  artist: "JIMI HENDRIX",
  tag: "LEAD",
  bpm: 85,
  bpmTone: "muted",
  cover: "../../assets/images/song-cover-2.jpg"
}, {
  title: "Acoustic Guitar Song",
  artist: "L KEY ORIGINALS",
  tag: "FINGERSTYLE",
  bpm: 92,
  bpmTone: "muted"
}];
function SongLibraryScreen({
  onOpenSong
}) {
  const [q, setQ] = React.useState("");
  const [cat, setCat] = React.useState("All");
  const rows = LIB.filter(s => (s.title + s.artist).toLowerCase().includes(q.toLowerCase()));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      padding: "24px 24px 24px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(H1s, null, "Songs"), /*#__PURE__*/React.createElement(SUBs, null, "42 songs \xB7 Myanmar + English")), /*#__PURE__*/React.createElement(AppTextField, {
    placeholder: "SEARCH SONGS...",
    value: q,
    onChange: e => setQ(e.target.value),
    icon: /*#__PURE__*/React.createElement(SIcon, {
      name: "search",
      w: 18,
      h: 18
    })
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      boxShadow: "var(--lk-ring)",
      alignSelf: "flex-start"
    }
  }, ["All", "Myanmar", "English", "Favorites"].map(x => /*#__PURE__*/React.createElement("button", {
    key: x,
    type: "button",
    onClick: () => setCat(x),
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      padding: "3.5px 12px",
      minHeight: 26.39,
      background: cat === x ? "var(--lk-black)" : "var(--lk-white)",
      color: cat === x ? "var(--lk-white)" : "var(--lk-grey-500)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      borderRight: "1px solid var(--lk-black)"
    }
  }, x))), cat === "Favorites" ? /*#__PURE__*/React.createElement(EmptyState, {
    align: "left",
    headline: "No favorites yet.",
    body: "Save something for later."
  }) : /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, rows.map(s => /*#__PURE__*/React.createElement(SongCard, _extends({
    key: s.title
  }, s, {
    onClick: onOpenSong,
    action: /*#__PURE__*/React.createElement(AppIconButton, {
      label: "More",
      variant: "bare",
      size: 16,
      style: {
        height: 35,
        padding: 0
      }
    }, /*#__PURE__*/React.createElement(SIcon, {
      name: "more-vertical",
      w: 4,
      h: 16
    }))
  })))));
}

/* ——— Learn (README.md → Learning: Course → Module → Lesson → Exercise). ——— */
const COURSES = [{
  label: "COURSE · 12 LESSONS",
  title: "Guitar Fundamentals",
  done: 7,
  total: 12
}, {
  label: "COURSE · 9 LESSONS",
  title: "Open & Barre Chords",
  done: 2,
  total: 9
}, {
  label: "COURSE · 8 LESSONS",
  title: "Rhythm & Strumming",
  done: 0,
  total: 8
}, {
  label: "COURSE · 10 LESSONS",
  title: "CAGED System",
  done: 0,
  total: 10,
  pro: true
}];
function LearnScreen({
  onPractice
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      padding: "24px 24px 24px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(H1s, null, "Learn"), /*#__PURE__*/React.createElement(SUBs, null, "Course \u2192 module \u2192 lesson")), /*#__PURE__*/React.createElement(AppCard, {
    tone: "accent",
    label: "CONTINUE \xB7 LESSON 8 OF 12",
    title: "Barre Chord Basics",
    style: {
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-body)",
      fontWeight: 400,
      fontSize: 16,
      lineHeight: "24px"
    }
  }, "Build the F major shape one finger at a time."), /*#__PURE__*/React.createElement(AppButton, {
    variant: "primary",
    size: "lg",
    block: true,
    onClick: onPractice
  }, "Resume Lesson")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, COURSES.map(c => /*#__PURE__*/React.createElement(AppCard, {
    key: c.title,
    variant: "ring",
    padding: 20,
    style: {
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      letterSpacing: "0.7px",
      textTransform: "uppercase",
      color: "var(--lk-grey-500)"
    }
  }, c.label, c.pro ? /*#__PURE__*/React.createElement(PremiumBadge, {
    size: "sm"
  }) : null), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 600,
      fontSize: 20,
      lineHeight: "30px"
    }
  }, c.title)), /*#__PURE__*/React.createElement(PracticeProgress, {
    value: c.done,
    max: c.total,
    height: 16
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-grey-600)"
    }
  }, c.done, " / ", c.total, " LESSONS")))));
}

/* ——— Practice (DESIGN.md §30–31). Session plan + streak, progress not decoration. ——— */
const PLAN = [{
  t: "CHORD SWITCHING",
  min: 10,
  done: true
}, {
  t: "PENTATONIC",
  min: 10,
  done: true
}, {
  t: "STRUMMING",
  min: 10,
  done: false
}];
function PracticeScreen() {
  const [started, setStarted] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      padding: "24px 24px 24px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(H1s, null, "Today's Practice"), /*#__PURE__*/React.createElement(SUBs, null, "Streak \xB7 6 days")), /*#__PURE__*/React.createElement(AppCard, {
    variant: "ring",
    style: {
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(PracticeProgress, {
    value: 20,
    max: 30,
    elapsed: "20:00",
    total: "30:00 MIN",
    label: "Session"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column"
    }
  }, PLAN.map(x => /*#__PURE__*/React.createElement("div", {
    key: x.t,
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 12,
      padding: "12px 0",
      borderBottom: "1px solid var(--lk-fill-ghost)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 10
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 16,
      height: 16,
      boxSizing: "border-box",
      boxShadow: "var(--lk-ring)",
      background: x.done ? "var(--lk-orange)" : "var(--lk-white)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 10
    }
  }, x.done ? "✓" : ""), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 14,
      lineHeight: "19.6px"
    }
  }, x.t)), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-grey-500)"
    }
  }, x.min, " MIN")))), /*#__PURE__*/React.createElement(AppButton, {
    variant: started ? "primary" : "accent",
    size: "lg",
    block: true,
    onClick: () => setStarted(!started)
  }, started ? "Pause" : "Start")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "STREAK",
    style: {
      flex: 1
    }
  }, "6 DAYS"), /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "THIS WEEK",
    style: {
      flex: 1
    }
  }, "142 MIN"), /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "BEST BPM",
    style: {
      flex: 1
    }
  }, "96")), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      textTransform: "uppercase",
      color: "var(--lk-text-tertiary)",
      textAlign: "center"
    }
  }, "Weekly analytics \xB7 weak areas \u2014 ", /*#__PURE__*/React.createElement("span", {
    style: {
      background: "var(--lk-accent)",
      color: "var(--lk-accent-on)",
      fontWeight: 700,
      padding: "1px 5px"
    }
  }, "PRO")));
}
Object.assign(window, {
  LKSongLibrary: SongLibraryScreen,
  LKLearn: LearnScreen,
  LKPractice: PracticeScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile_app/LibraryScreens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile_app/ProfileScreens.jsx
try { (() => {
const {
  AppCard,
  AppChip,
  AppButton,
  PremiumBadge,
  StatusBadge
} = window.LKeyDesignSystem_355d7c;
const H1p = ({
  children
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    fontFamily: "var(--lk-font-display)",
    fontWeight: 700,
    fontSize: 36,
    lineHeight: "39.6px",
    letterSpacing: "-1.8px",
    textTransform: "uppercase"
  }
}, children);
const MONO = (s = {}) => ({
  fontFamily: "var(--lk-font-mono)",
  fontWeight: 500,
  fontSize: 14,
  lineHeight: "19.6px",
  ...s
});

/* ——— Profile. Identity, stats, settings, Pro entry (DESIGN.md §36, §68). ——— */
function ProfileScreen({
  go,
  pro
}) {
  const [lang, setLang] = React.useState("EN");
  const [dark, setDark] = React.useState(false);
  const Row = ({
    label,
    control
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 12,
      padding: "14px 0",
      borderBottom: "1px solid var(--lk-fill-ghost)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-body)",
      fontWeight: 600,
      fontSize: 16,
      lineHeight: "24px"
    }
  }, label), control);
  const Seg = ({
    value,
    options,
    onChange
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      boxShadow: "var(--lk-ring)"
    }
  }, options.map(o => /*#__PURE__*/React.createElement("button", {
    key: o,
    type: "button",
    onClick: () => onChange(o),
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      padding: "3.5px 12px",
      minHeight: 26.39,
      background: value === o ? "var(--lk-black)" : "var(--lk-white)",
      color: value === o ? "var(--lk-white)" : "var(--lk-grey-500)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      borderRight: "1px solid var(--lk-black)"
    }
  }, o)));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      padding: "24px 24px 24px"
    }
  }, /*#__PURE__*/React.createElement(H1p, null, "Profile"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 16,
      padding: 12,
      boxSizing: "border-box",
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 48,
      height: 48,
      borderRadius: "var(--lk-radius-pill)",
      overflow: "hidden",
      boxShadow: "var(--lk-ring)",
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/images/admin-avatar.jpg",
    alt: "",
    style: {
      width: "100%",
      height: "100%",
      objectFit: "cover",
      display: "block"
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      fontFamily: "var(--lk-font-body)",
      fontWeight: 700,
      fontSize: 16,
      lineHeight: "24px"
    }
  }, "Guitarist", pro ? /*#__PURE__*/React.createElement(PremiumBadge, {
    size: "sm"
  }) : null), /*#__PURE__*/React.createElement("span", {
    style: MONO({
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-grey-500)"
    })
  }, "Member since 2026"))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "STREAK",
    style: {
      flex: 1
    }
  }, "6 DAYS"), /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "PRACTICE",
    style: {
      flex: 1
    }
  }, "14.2 HRS"), /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "SONGS",
    style: {
      flex: 1
    }
  }, "18")), !pro ? /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--lk-orange)",
      boxShadow: "var(--lk-shadow)",
      padding: 24,
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 10
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 24,
      lineHeight: "28.8px",
      textTransform: "uppercase"
    }
  }, "Go Pro"), /*#__PURE__*/React.createElement(PremiumBadge, {
    tone: "inverse"
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-body)",
      fontWeight: 400,
      fontSize: 16,
      lineHeight: "24px"
    }
  }, "Unlock your complete guitar toolkit."), /*#__PURE__*/React.createElement(AppButton, {
    variant: "primary",
    size: "lg",
    block: true,
    onClick: () => go("paywall")
  }, "See Plans")) : /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: 24,
      boxSizing: "border-box",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 20,
      lineHeight: "30px",
      textTransform: "uppercase"
    }
  }, "Pro is active."), /*#__PURE__*/React.createElement(StatusBadge, {
    status: "published"
  }, "Yearly")), /*#__PURE__*/React.createElement(AppCard, {
    variant: "ring",
    padding: 20,
    style: {
      gap: 0
    }
  }, /*#__PURE__*/React.createElement(Row, {
    label: "Language",
    control: /*#__PURE__*/React.createElement(Seg, {
      value: lang,
      options: ["MM", "EN"],
      onChange: setLang
    })
  }), /*#__PURE__*/React.createElement(Row, {
    label: "Dark mode",
    control: /*#__PURE__*/React.createElement(Seg, {
      value: dark ? "ON" : "OFF",
      options: ["OFF", "ON"],
      onChange: v => setDark(v === "ON")
    })
  }), /*#__PURE__*/React.createElement(Row, {
    label: "Reference pitch",
    control: /*#__PURE__*/React.createElement("span", {
      style: MONO({
        fontWeight: 700
      })
    }, "440 Hz")
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      paddingTop: 16
    }
  }, /*#__PURE__*/React.createElement(AppButton, {
    variant: "secondary",
    size: "md",
    block: true
  }, "Sign Out"))));
}

/* ——— Paywall (DESIGN.md §33). Capability list, plan pick, explicit continue. ——— */
const FEATURES = ["Advanced tuner", "Custom tunings", "Advanced chords", "CAGED", "Scale trainer", "Practice analytics", "AI Guitar Coach"];
function PaywallScreen({
  go
}) {
  const [plan, setPlan] = React.useState("yearly");
  const Plan = ({
    id,
    name,
    price,
    star
  }) => /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: () => setPlan(id),
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      textAlign: "left",
      flex: 1,
      padding: 16,
      boxSizing: "border-box",
      background: plan === id ? "var(--lk-orange)" : "var(--lk-white)",
      boxShadow: plan === id ? "var(--lk-ring),var(--lk-shadow-sm)" : "var(--lk-ring)",
      display: "flex",
      flexDirection: "column",
      gap: 4
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: MONO({
      fontWeight: 700,
      fontSize: 12,
      lineHeight: "14.4px",
      letterSpacing: "0.7px",
      textTransform: "uppercase"
    })
  }, name, star ? " ⭐" : ""), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 24,
      lineHeight: "28.8px"
    }
  }, price), /*#__PURE__*/React.createElement("span", {
    style: MONO({
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-grey-600)"
    })
  }, "MMK"));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      padding: "24px 24px 24px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(H1p, null, "Go Pro"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-body)",
      fontWeight: 400,
      fontSize: 18,
      lineHeight: "28.8px",
      color: "var(--lk-grey-600)"
    }
  }, "Unlock your complete guitar toolkit.")), /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: 24,
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      gap: 10
    }
  }, FEATURES.map(f => /*#__PURE__*/React.createElement("span", {
    key: f,
    style: MONO({
      display: "flex",
      gap: 10
    })
  }, /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      color: "var(--lk-text)",
      fontWeight: 700
    }
  }, "\u2713"), f))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(Plan, {
    id: "monthly",
    name: "Monthly",
    price: "2,500"
  }), /*#__PURE__*/React.createElement(Plan, {
    id: "yearly",
    name: "Yearly",
    price: "25,000",
    star: true
  })), /*#__PURE__*/React.createElement(AppButton, {
    variant: "primary",
    size: "lg",
    block: true,
    onClick: () => go("payment")
  }, "Continue"), /*#__PURE__*/React.createElement("span", {
    style: MONO({
      fontSize: 12,
      lineHeight: "18px",
      color: "var(--lk-grey-500)",
      textAlign: "center"
    })
  }, "Pay with KBZPay, AYA Pay, WavePay or any MMQR wallet. Cancel anytime."));
}

/* ——— Payment (DESIGN.md §34–35). MMQR flow; status comes from the backend, never claimed early. ——— */
function DemoQr() {
  // Deterministic placeholder pattern — NOT a scannable code.
  const cells = [];
  let seed = 7;
  for (let i = 0; i < 169; i++) {
    seed = (seed * 137 + 11) % 251;
    cells.push(seed % 3 !== 0);
  }
  const eye = (x, y) => x < 4 && y < 4 || x > 8 && y < 4 || x < 4 && y > 8;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: 156,
      height: 156,
      padding: 10,
      boxSizing: "border-box",
      background: "var(--lk-white)",
      boxShadow: "var(--lk-ring)",
      display: "grid",
      gridTemplateColumns: "repeat(13,1fr)"
    },
    "aria-label": "Demo QR placeholder"
  }, cells.map((on, i) => {
    const x = i % 13,
      y = Math.floor(i / 13);
    return /*#__PURE__*/React.createElement("div", {
      key: i,
      style: {
        background: eye(x, y) ? x % 3 === 1 && y % 3 === 1 || x === 0 || y === 0 || x === 3 || y === 3 || x === 9 || y === 9 || x === 12 || y === 12 ? "var(--lk-black)" : "var(--lk-white)" : on ? "var(--lk-black)" : "var(--lk-white)"
      }
    });
  }));
}
function PaymentScreen({
  go
}) {
  const [stage, setStage] = React.useState("select"); // select → waiting → done
  const [left, setLeft] = React.useState(300);
  React.useEffect(() => {
    if (stage !== "waiting") return;
    const id = setInterval(() => setLeft(s => Math.max(0, s - 1)), 1000);
    return () => clearInterval(id);
  }, [stage]);
  const mm = String(Math.floor(left / 60)).padStart(1, "0"),
    ss = String(left % 60).padStart(2, "0");
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      padding: "24px 24px 24px"
    }
  }, /*#__PURE__*/React.createElement(H1p, null, "Guitar Pro"), /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: 24,
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "baseline"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: MONO({
      letterSpacing: "0.7px",
      textTransform: "uppercase",
      color: "var(--lk-grey-500)"
    })
  }, "Yearly"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 24,
      lineHeight: "28.8px"
    }
  }, "25,000 ", /*#__PURE__*/React.createElement("span", {
    style: MONO({
      fontSize: 12
    })
  }, "MMK"))), /*#__PURE__*/React.createElement("div", {
    style: {
      borderTop: "2px solid var(--lk-divider)",
      paddingTop: 16,
      display: "flex",
      flexDirection: "column",
      gap: 16,
      alignItems: "center"
    }
  }, stage === "select" ? /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(AppChip, {
    variant: "dark"
  }, "[ MMQR ]"), /*#__PURE__*/React.createElement("span", {
    style: MONO({
      fontSize: 12,
      lineHeight: "18px",
      color: "var(--lk-grey-500)",
      textAlign: "center"
    })
  }, "Scan with KBZPay / AYA Pay / WavePay / CB Pay"), /*#__PURE__*/React.createElement(AppButton, {
    variant: "accent",
    size: "lg",
    block: true,
    onClick: () => {
      setStage("waiting");
      setLeft(300);
    }
  }, "Show QR")) : stage === "waiting" ? /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(DemoQr, null), /*#__PURE__*/React.createElement("span", {
    style: MONO({
      fontWeight: 700,
      letterSpacing: "0.7px",
      textTransform: "uppercase"
    })
  }, "Waiting for payment"), /*#__PURE__*/React.createElement("span", {
    style: MONO({
      fontSize: 12,
      lineHeight: "18px",
      color: "var(--lk-grey-500)",
      textAlign: "center"
    })
  }, "Complete payment in your selected mobile wallet."), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16,
      alignSelf: "stretch"
    }
  }, /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "AMOUNT",
    style: {
      flex: 1
    }
  }, "25,000 MMK"), /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "EXPIRES",
    style: {
      flex: 1
    }
  }, mm, ":", ss)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 12,
      alignSelf: "stretch"
    }
  }, /*#__PURE__*/React.createElement(AppButton, {
    variant: "secondary",
    size: "md",
    style: {
      flex: 1
    },
    onClick: () => setStage("select")
  }, "Cancel"), /*#__PURE__*/React.createElement(AppButton, {
    variant: "primary",
    size: "md",
    style: {
      flex: 1
    },
    onClick: () => setStage("done")
  }, "Simulate Webhook"))) : /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 24,
      lineHeight: "28.8px",
      textTransform: "uppercase",
      color: "var(--lk-orange)"
    }
  }, "Payment Complete"), /*#__PURE__*/React.createElement("span", {
    style: MONO({
      fontWeight: 700,
      letterSpacing: "0.7px",
      textTransform: "uppercase"
    })
  }, "Pro is active."), /*#__PURE__*/React.createElement(AppButton, {
    variant: "primary",
    size: "lg",
    block: true,
    onClick: () => go("profile", true)
  }, "Done")))), /*#__PURE__*/React.createElement("span", {
    style: MONO({
      fontSize: 12,
      lineHeight: "18px",
      color: "var(--lk-text-tertiary)",
      textAlign: "center"
    })
  }, "Demo QR \u2014 not scannable. Status is only ever confirmed by the backend."));
}
Object.assign(window, {
  LKProfile: ProfileScreen,
  LKPaywall: PaywallScreen,
  LKPayment: PaymentScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile_app/ProfileScreens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile_app/SongViewerScreen.jsx
try { (() => {
const {
  AppChip
} = window.LKeyDesignSystem_355d7c;
const {
  PlayGlyph,
  Icon: SvIcon
} = window.LKGlyphs;
const SECTIONS = [{
  label: "[INTRO]",
  lines: [{
    chords: [{
      n: "G",
      x: 0
    }, {
      n: "C",
      x: 84
    }, {
      n: "Em",
      x: 168
    }, {
      n: "D",
      x: 252
    }],
    lyric: ""
  }]
}, {
  label: "[VERSE 1]",
  lines: [{
    chords: [{
      n: "G",
      x: 0
    }, {
      n: "C",
      x: 136.73
    }],
    lyric: "Waking up to the sound of the rain\nfalling down"
  }, {
    chords: [{
      n: "Em",
      x: 0
    }, {
      n: "D",
      x: 140.45
    }],
    lyric: "Grab my old six-string, playing it loud"
  }, {
    chords: [{
      n: "G",
      x: 0
    }, {
      n: "C",
      x: 132.2
    }],
    lyric: "Coffee on the table, cold in the cup"
  }, {
    chords: [{
      n: "Em",
      x: 0
    }, {
      n: "D",
      x: 146.9
    }],
    lyric: "Trying to find the words to sum it all up"
  }]
}, {
  label: "[CHORUS]",
  lines: [{
    chords: [{
      n: "C",
      x: 0
    }, {
      n: "G",
      x: 120.5
    }],
    lyric: "Oh, this acoustic guitar song"
  }, {
    chords: [{
      n: "Em",
      x: 0
    }, {
      n: "D",
      x: 128.9
    }],
    lyric: "Carries me right back where I belong"
  }, {
    chords: [{
      n: "C",
      x: 0
    }, {
      n: "G",
      x: 132.4
    }],
    lyric: "Through the highs and the lows, we sing along"
  }, {
    chords: [{
      n: "D",
      x: 0
    }],
    lyric: "Just me and this acoustic guitar song"
  }]
}];
function ChordChip({
  children
}) {
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: "inline-flex",
      height: 35,
      padding: "0 6px",
      boxSizing: "border-box",
      background: "var(--lk-overlay-chord)",
      boxShadow: "var(--lk-shadow-sm)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 14,
      lineHeight: "35px"
    }
  }, children);
}
function SongViewerScreen({
  transpose = 0,
  onTranspose,
  autoScroll,
  onAutoScroll
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "32px 16px 32px",
      display: "flex",
      flexDirection: "column",
      gap: 32
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: "23px 24px 24px",
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 24,
      lineHeight: "28.8px",
      textTransform: "uppercase"
    }
  }, "ACOUSTIC GUITAR SONG"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16,
      justifyContent: "center",
      padding: "16px 0 0",
      borderTop: "2px solid var(--lk-divider)"
    }
  }, /*#__PURE__*/React.createElement(AppChip, {
    label: "KEY"
  }, "G Major"), /*#__PURE__*/React.createElement(AppChip, {
    label: "CAPO"
  }, "2nd Fret"), /*#__PURE__*/React.createElement(AppChip, {
    label: "BPM",
    icon: /*#__PURE__*/React.createElement(SvIcon, {
      name: "heart",
      w: 13.333,
      h: 12.233
    })
  }, "92"))), /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: "24px 24px 48px",
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      gap: 24
    }
  }, SECTIONS.map(s => /*#__PURE__*/React.createElement("div", {
    key: s.label,
    style: {
      display: "flex",
      flexDirection: "column"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      borderBottom: "2px solid var(--lk-divider)",
      paddingBottom: 4,
      marginBottom: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      textTransform: "uppercase",
      color: "var(--lk-grey-500)"
    }
  }, s.label)), s.lines.map((line, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      marginBottom: line.lyric ? 4 : 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      height: 44
    }
  }, line.chords.map(c => /*#__PURE__*/React.createElement("span", {
    key: c.n + c.x,
    style: {
      position: "absolute",
      left: c.x,
      top: 6
    }
  }, /*#__PURE__*/React.createElement(ChordChip, null, c.n)))), line.lyric ? /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: "var(--lk-font-body)",
      fontWeight: 400,
      fontSize: 18,
      lineHeight: "28.8px",
      whiteSpace: "pre-line"
    }
  }, line.lyric) : null)))))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "sticky",
      bottom: 0,
      background: "var(--lk-fill-chip)",
      borderTop: "2px solid var(--lk-divider)",
      padding: 16,
      boxSizing: "border-box"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      height: 44,
      padding: 4,
      boxSizing: "border-box",
      background: "var(--lk-white)",
      boxShadow: "var(--lk-ring-shadow-sm)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      paddingRight: 8,
      borderRight: "2px solid var(--lk-black)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 14,
      lineHeight: "19.6px",
      textTransform: "uppercase",
      paddingLeft: 8
    }
  }, "TRANSPOSE"), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: () => onTranspose && onTranspose(-1),
    "aria-label": "Transpose down",
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      width: 32,
      height: 32,
      background: "var(--lk-black)",
      boxShadow: "var(--lk-ring)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center"
    }
  }, /*#__PURE__*/React.createElement("svg", {
    width: "14",
    height: "2",
    viewBox: "0 0 14 2",
    fill: "#fff"
  }, /*#__PURE__*/React.createElement("path", {
    d: "M 0 2 L 0 0 L 14 0 L 14 2 L 0 2 Z"
  }))), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 32,
      textAlign: "center",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 14,
      lineHeight: "19.6px"
    }
  }, transpose > 0 ? "+" + transpose : transpose), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: () => onTranspose && onTranspose(1),
    "aria-label": "Transpose up",
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      width: 32,
      height: 32,
      background: "var(--lk-black)",
      boxShadow: "var(--lk-ring)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center"
    }
  }, /*#__PURE__*/React.createElement("svg", {
    width: "14",
    height: "14",
    viewBox: "0 0 14 14",
    fill: "#fff"
  }, /*#__PURE__*/React.createElement("path", {
    d: "M 6 8 L 0 8 L 0 6 L 6 6 L 6 0 L 8 0 L 8 6 L 14 6 L 14 8 L 8 8 L 8 14 L 6 14 L 6 8 Z"
  })))), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onAutoScroll,
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      width: 118.42,
      height: 59.19,
      boxSizing: "border-box",
      background: autoScroll ? "var(--lk-black)" : "var(--lk-orange)",
      color: autoScroll ? "var(--lk-white)" : "var(--lk-black)",
      boxShadow: "var(--lk-ring-shadow)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(PlayGlyph, {
    c: autoScroll ? "#fff" : "#000"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 14,
      lineHeight: "19.6px",
      textAlign: "center",
      whiteSpace: "pre-line"
    }
  }, "AUTO-\nSCROLL")))));
}
Object.assign(window, {
  LKMobileSongViewer: SongViewerScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile_app/SongViewerScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile_app/ToolsScreens.jsx
try { (() => {
const {
  TunerMeter,
  BpmDisplay,
  Fretboard,
  AppButton,
  AppChip,
  PremiumBadge,
  AppSectionHeader
} = window.LKeyDesignSystem_355d7c;
const {
  Icon: TIcon
} = window.LKGlyphs;
const H1 = ({
  children
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    fontFamily: "var(--lk-font-display)",
    fontWeight: 700,
    fontSize: 36,
    lineHeight: "39.6px",
    letterSpacing: "-1.8px",
    textTransform: "uppercase"
  }
}, children);
const SUB = ({
  children
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    fontFamily: "var(--lk-font-mono)",
    fontWeight: 500,
    fontSize: 14,
    lineHeight: "19.6px",
    letterSpacing: "0.7px",
    textTransform: "uppercase",
    color: "var(--lk-grey-500)"
  }
}, children);

/* ——— Tools hub. Tool list per README.md feature set; PRO gating per DESIGN.md §32. ——— */
function ToolsHubScreen({
  go
}) {
  const TOOLS = [{
    t: "Tuner",
    view: "tuner"
  }, {
    t: "Metronome",
    view: "metronome"
  }, {
    t: "Chords",
    view: "chord"
  }, {
    t: "Scales",
    view: "scales"
  }, {
    t: "Transposer",
    view: "song"
  }, {
    t: "Capo Assistant",
    view: "song"
  }, {
    t: "Ear Training",
    pro: true
  }, {
    t: "Recording",
    pro: true
  }];
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      padding: "24px 24px 24px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(H1, null, "Tools"), /*#__PURE__*/React.createElement(SUB, null, "Precision utilities \xB7 offline")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, TOOLS.map(x => /*#__PURE__*/React.createElement("button", {
    key: x.t,
    type: "button",
    onClick: () => !x.pro && x.view && go(x.view),
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      minHeight: 60,
      background: "var(--lk-white)",
      boxShadow: "var(--lk-shadow)",
      padding: 16,
      boxSizing: "border-box",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 600,
      fontSize: 18,
      lineHeight: "28px"
    }
  }, x.t), x.pro ? /*#__PURE__*/React.createElement(PremiumBadge, {
    size: "sm"
  }) : null), /*#__PURE__*/React.createElement(TIcon, {
    name: "stack-pin",
    w: 20
  })))));
}

/* ——— Tuner (DESIGN.md §21–22). Pick a string; the needle settles to lock. ——— */
const STRINGS = [{
  n: "E",
  o: 2,
  hz: 82.41
}, {
  n: "A",
  o: 2,
  hz: 110.0
}, {
  n: "D",
  o: 3,
  hz: 146.83
}, {
  n: "G",
  o: 3,
  hz: 196.0
}, {
  n: "B",
  o: 3,
  hz: 246.94
}, {
  n: "E",
  o: 4,
  hz: 329.63
}];
function TunerScreen() {
  const [sel, setSel] = React.useState(0);
  const [cents, setCents] = React.useState(-18);
  React.useEffect(() => {
    const id = setInterval(() => setCents(c => Math.abs(c) < 1 ? 0 : c * 0.72), 160);
    return () => clearInterval(id);
  }, [sel]);
  const s = STRINGS[sel];
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      padding: "24px 24px 24px",
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      alignSelf: "stretch",
      display: "flex",
      flexDirection: "column",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(H1, null, "Tuner"), /*#__PURE__*/React.createElement(SUB, null, "Microphone \xB7 standard tuning")), /*#__PURE__*/React.createElement(TunerMeter, {
    width: 342,
    note: s.n,
    octave: s.o,
    frequency: s.hz * (1 + cents / 1731),
    cents: Math.round(cents),
    tuning: "STANDARD",
    referencePitch: 440
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8,
      alignSelf: "stretch",
      justifyContent: "center"
    }
  }, STRINGS.map((x, i) => /*#__PURE__*/React.createElement("button", {
    key: i,
    type: "button",
    onClick: () => {
      setSel(i);
      setCents(i % 2 ? 22 : -24);
    },
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      width: 48,
      height: 48,
      boxSizing: "border-box",
      background: i === sel ? "var(--lk-orange)" : "var(--lk-white)",
      boxShadow: i === sel ? "var(--lk-ring),var(--lk-shadow-sm)" : "var(--lk-ring)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 14,
      lineHeight: "19.6px"
    }
  }, x.n, x.o))), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      textTransform: "uppercase",
      color: "var(--lk-text-tertiary)"
    }
  }, "Chromatic \xB7 drop & open tunings \u2014 ", /*#__PURE__*/React.createElement("span", {
    style: {
      background: "var(--lk-accent)",
      color: "var(--lk-accent-on)",
      fontWeight: 700,
      padding: "1px 5px"
    }
  }, "PRO")));
}

/* ——— Metronome (DESIGN.md §27). Running state pulses the beat indicator. ——— */
function MetronomeScreen() {
  const [bpm, setBpm] = React.useState(120);
  const [sig, setSig] = React.useState("4/4");
  const [running, setRunning] = React.useState(false);
  const [beat, setBeat] = React.useState(0);
  const beats = Number(sig[0]);
  React.useEffect(() => {
    if (!running) return;
    const id = setInterval(() => setBeat(b => (b + 1) % beats), 60000 / bpm);
    return () => clearInterval(id);
  }, [running, bpm, beats]);
  const taps = React.useRef([]);
  const tap = () => {
    const now = Date.now();
    taps.current = taps.current.filter(t => now - t < 3000).concat(now);
    if (taps.current.length > 1) {
      const iv = (taps.current[taps.current.length - 1] - taps.current[0]) / (taps.current.length - 1);
      setBpm(Math.max(30, Math.min(240, Math.round(60000 / iv))));
    }
  };
  const Step = ({
    d,
    label
  }) => /*#__PURE__*/React.createElement("button", {
    type: "button",
    "aria-label": label,
    onClick: () => setBpm(b => Math.max(30, Math.min(240, b + d))),
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      width: 48,
      height: 48,
      background: "var(--lk-black)",
      color: "var(--lk-white)",
      boxShadow: "var(--lk-ring)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 18
    }
  }, d > 0 ? "+" : "–");
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      padding: "24px 24px 24px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(H1, null, "Metronome"), /*#__PURE__*/React.createElement(SUB, null, "Tap tempo \xB7 subdivisions")), /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--lk-surface)",
      boxShadow: "var(--lk-ring-shadow)",
      padding: 24,
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(Step, {
    d: -4,
    label: "Slower"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      width: 170,
      textAlign: "center"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 700,
      fontSize: 64,
      lineHeight: "64px",
      letterSpacing: "-1.28px"
    }
  }, bpm), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      letterSpacing: "0.7px",
      textTransform: "uppercase",
      color: "var(--lk-grey-500)"
    }
  }, "BPM")), /*#__PURE__*/React.createElement(Step, {
    d: 4,
    label: "Faster"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8
    }
  }, Array.from({
    length: beats
  }).map((_, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      width: i === 0 ? 16 : 12,
      height: i === 0 ? 16 : 12,
      borderRadius: "var(--lk-radius-pill)",
      boxShadow: "var(--lk-ring)",
      background: running && i === beat ? i === 0 ? "var(--lk-orange)" : "var(--lk-black)" : "transparent"
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      boxShadow: "var(--lk-ring)"
    }
  }, ["4/4", "3/4", "6/8"].map(x => /*#__PURE__*/React.createElement("button", {
    key: x,
    type: "button",
    onClick: () => {
      setSig(x);
      setBeat(0);
    },
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      padding: "3.5px 12px",
      minHeight: 26.39,
      background: sig === x ? "var(--lk-black)" : "var(--lk-white)",
      color: sig === x ? "var(--lk-white)" : "var(--lk-grey-500)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      borderRight: "1px solid var(--lk-black)"
    }
  }, x))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 12,
      alignSelf: "stretch"
    }
  }, /*#__PURE__*/React.createElement(AppButton, {
    variant: "secondary",
    size: "lg",
    style: {
      flex: 1
    },
    onClick: tap
  }, "Tap"), /*#__PURE__*/React.createElement(AppButton, {
    variant: running ? "primary" : "accent",
    size: "lg",
    style: {
      flex: 1
    },
    onClick: () => {
      setRunning(!running);
      setBeat(0);
    }
  }, running ? "Stop" : "Start"))), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      textTransform: "uppercase",
      color: "var(--lk-text-tertiary)",
      textAlign: "center"
    }
  }, "Progressive BPM \xB7 accents \xB7 sounds \u2014 ", /*#__PURE__*/React.createElement("span", {
    style: {
      background: "var(--lk-accent)",
      color: "var(--lk-accent-on)",
      fontWeight: 700,
      padding: "1px 5px"
    }
  }, "PRO")));
}

/* ——— Scales (DESIGN.md §25–26). A minor pentatonic, box 1; roots in orange. ——— */
const PENTA = [{
  string: 0,
  fret: 5,
  label: "A",
  root: true
}, {
  string: 0,
  fret: 8,
  label: "C"
}, {
  string: 1,
  fret: 5,
  label: "E"
}, {
  string: 1,
  fret: 8,
  label: "G"
}, {
  string: 2,
  fret: 5,
  label: "C"
}, {
  string: 2,
  fret: 7,
  label: "E"
}, {
  string: 3,
  fret: 5,
  label: "G"
}, {
  string: 3,
  fret: 7,
  label: "A",
  root: true
}, {
  string: 4,
  fret: 5,
  label: "D"
}, {
  string: 4,
  fret: 7,
  label: "E"
}, {
  string: 5,
  fret: 5,
  label: "A",
  root: true
}, {
  string: 5,
  fret: 8,
  label: "C"
}];
function ScalesScreen() {
  const [scale, setScale] = React.useState("Pentatonic");
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 24,
      padding: "24px 24px 24px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(H1, null, "A Minor Pentatonic"), /*#__PURE__*/React.createElement(SUB, null, "Box 1 \xB7 frets 5\u20138")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      boxShadow: "var(--lk-ring)",
      alignSelf: "flex-start"
    }
  }, ["Pentatonic", "Minor", "Blues"].map(x => /*#__PURE__*/React.createElement("button", {
    key: x,
    type: "button",
    onClick: () => setScale(x),
    style: {
      appearance: "none",
      border: "none",
      cursor: "pointer",
      padding: "3.5px 12px",
      minHeight: 26.39,
      background: scale === x ? "var(--lk-black)" : "var(--lk-white)",
      color: scale === x ? "var(--lk-white)" : "var(--lk-grey-500)",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      borderRight: "1px solid var(--lk-black)"
    }
  }, x))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "FORMULA",
    style: {
      flex: 1
    }
  }, "1 b3 4 5 b7"), /*#__PURE__*/React.createElement(AppChip, {
    variant: "bento",
    label: "ROOT",
    style: {
      flex: 1
    }
  }, "A")), /*#__PURE__*/React.createElement("div", {
    style: {
      overflowX: "auto",
      margin: "0 -24px",
      padding: "0 24px 6px"
    }
  }, /*#__PURE__*/React.createElement(Fretboard, {
    frets: 10,
    fretWidth: 40,
    rowHeight: 34,
    markers: PENTA
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(BpmDisplay, {
    size: "md",
    bpm: 80,
    beats: 4,
    activeBeat: -1,
    timeSignature: "4/4"
  }), /*#__PURE__*/React.createElement(AppButton, {
    variant: "accent",
    size: "lg"
  }, "Practice")));
}
Object.assign(window, {
  LKToolsHub: ToolsHubScreen,
  LKTuner: TunerScreen,
  LKMetronome: MetronomeScreen,
  LKScales: ScalesScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile_app/ToolsScreens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/website/LandingScreen.jsx
try { (() => {
const {
  AppButton
} = window.LKeyDesignSystem_355d7c;
const WebIcon = ({
  name,
  w,
  h
}) => /*#__PURE__*/React.createElement("img", {
  src: "../../assets/icons/" + name + ".svg",
  width: w,
  height: h || w,
  alt: "",
  style: {
    display: "block"
  }
});
const TuneGlyph = () => /*#__PURE__*/React.createElement("svg", {
  width: "27",
  height: "27",
  viewBox: "0 0 27 27",
  fill: "#fff"
}, /*#__PURE__*/React.createElement("path", {
  d: "M 12 27 L 12 18 L 15 18 L 15 21 L 27 21 L 27 24 L 15 24 L 15 27 L 12 27 M 0 24 L 0 21 L 9 21 L 9 24 L 0 24 M 6 18 L 6 15 L 0 15 L 0 12 L 6 12 L 6 9 L 9 9 L 9 18 L 6 18 M 12 15 L 12 12 L 27 12 L 27 15 L 12 15 M 18 9 L 18 0 L 21 0 L 21 3 L 27 3 L 27 6 L 21 6 L 21 9 L 18 9 M 0 6 L 0 3 L 15 3 L 15 6 L 0 6 Z"
}));
const DownloadGlyph = () => /*#__PURE__*/React.createElement("svg", {
  width: "16",
  height: "16",
  viewBox: "0 0 16 16",
  fill: "#000"
}, /*#__PURE__*/React.createElement("path", {
  d: "M 8 12 L 3 7 L 4.4 5.55 L 7 8.15 L 7 0 L 9 0 L 9 8.15 L 11.6 5.55 L 13 7 L 8 12 M 2 16 C 1.45 16 0.979 15.804 0.587 15.413 C 0.196 15.021 0 14.55 0 14 L 0 11 L 2 11 L 2 14 L 14 14 L 14 11 L 16 11 L 16 14 C 16 14.55 15.804 15.021 15.413 15.413 C 15.021 15.804 14.55 16 14 16 L 2 16 Z"
}));
const CARD_TITLE = {
  fontFamily: "var(--lk-font-display)",
  fontWeight: 400,
  fontSize: 16,
  lineHeight: "24px"
};
const CARD_DESC = {
  fontFamily: "var(--lk-font-body)",
  fontWeight: 400,
  fontSize: 16,
  lineHeight: "24px",
  color: "var(--lk-grey-500)",
  whiteSpace: "pre-line"
};
function Hero() {
  return /*#__PURE__*/React.createElement("section", {
    style: {
      position: "relative",
      overflow: "hidden",
      minHeight: 695.39,
      padding: "127.39px 24px 128px",
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      justifyContent: "center",
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: 0,
      top: 0,
      width: "100%",
      height: 695.17,
      opacity: 0.1,
      background: "radial-gradient(905.097px 491.559px at 50% 50%, rgb(0,0,0) 9.43%, rgba(0,0,0,0) 9.43%)"
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      width: 557.04,
      maxWidth: 896,
      display: "flex",
      flexDirection: "column",
      gap: 32,
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 400,
      fontSize: 96,
      lineHeight: "86.4px",
      letterSpacing: "-4.8px",
      textAlign: "center",
      textTransform: "uppercase",
      whiteSpace: "pre-line"
    }
  }, "YOUR GUITAR.\nYOUR MUSIC.\nANYWHERE."), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 20,
      lineHeight: "28px",
      letterSpacing: "2px",
      textTransform: "uppercase"
    }
  }, "[ TUNE . LEARN . PRACTICE . PLAY ]"), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "32px 0"
    }
  }, /*#__PURE__*/React.createElement(AppButton, {
    variant: "accent",
    size: "xl",
    icon: /*#__PURE__*/React.createElement(DownloadGlyph, null)
  }, "Download App"))));
}
function BentoGrid() {
  return /*#__PURE__*/React.createElement("section", {
    style: {
      width: 1232,
      display: "grid",
      gridTemplateRows: "368px 236px",
      gridTemplateColumns: "repeat(12, 1fr)",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      gridColumn: "1 / span 8",
      background: "var(--lk-paper)",
      boxShadow: "var(--lk-shadow)",
      padding: 32,
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "flex-start",
      paddingBottom: 32
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 8,
      width: 417.75
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: CARD_TITLE
  }, "PRECISION TUNER"), /*#__PURE__*/React.createElement("span", {
    style: CARD_DESC
  }, "Studio-grade accuracy in your pocket. Features chromatic,\nalternate tunings, and polyphonic mode.")), /*#__PURE__*/React.createElement("div", {
    style: {
      width: 64,
      height: 64,
      borderRadius: "var(--lk-radius-pill)",
      background: "var(--lk-black)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement(TuneGlyph, null))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      height: 192,
      background: "var(--lk-paper)"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: 16,
      top: 10,
      display: "flex",
      alignItems: "baseline"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 400,
      fontSize: 16,
      lineHeight: "24px"
    }
  }, "E"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 400,
      fontSize: 24,
      lineHeight: "32px",
      color: "var(--lk-text-tertiary)"
    }
  }, "2")), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      right: 16,
      top: 24,
      height: 32,
      background: "var(--lk-black)",
      padding: "4px 8px",
      boxSizing: "border-box"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 400,
      fontSize: 16,
      lineHeight: "24px",
      color: "var(--lk-white)"
    }
  }, "82.4 Hz")), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: "53%",
      top: 60,
      width: 4,
      height: 128,
      background: "var(--lk-orange)",
      transform: "rotate(15deg)",
      transformOrigin: "50% 100%"
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: 0,
      bottom: 8,
      width: "100%",
      padding: "0 16px",
      boxSizing: "border-box",
      display: "flex",
      justifyContent: "space-between"
    }
  }, ["-50", "0", "+50"].map(t => /*#__PURE__*/React.createElement("span", {
    key: t,
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 500,
      fontSize: 12,
      lineHeight: "14.4px",
      color: "var(--lk-text-tertiary)"
    }
  }, t))))), /*#__PURE__*/React.createElement("div", {
    style: {
      gridColumn: "9 / span 4",
      height: 304,
      background: "var(--lk-black)",
      boxShadow: "var(--lk-shadow)",
      padding: 32,
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      ...CARD_TITLE,
      color: "var(--lk-white)"
    }
  }, "METRONOME"), /*#__PURE__*/React.createElement("span", {
    style: {
      ...CARD_DESC,
      color: "var(--lk-grey-300)"
    }
  }, "Complex polyrhythms made simple.")), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "32px 0",
      display: "flex",
      flexDirection: "column",
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-display)",
      fontWeight: 400,
      fontSize: 72,
      lineHeight: "72px",
      color: "var(--lk-white)"
    }
  }, "120"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 400,
      fontSize: 16,
      lineHeight: "24px",
      letterSpacing: "1.6px",
      textTransform: "uppercase",
      color: "var(--lk-orange)"
    }
  }, "BPM"), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "24px 0",
      display: "flex",
      gap: 8
    }
  }, [0, 1, 2, 3].map(i => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      width: 16,
      height: 16,
      borderRadius: "var(--lk-radius-pill)",
      background: "var(--lk-orange)"
    }
  }))))), /*#__PURE__*/React.createElement("div", {
    style: {
      gridColumn: "1 / span 6",
      height: 225,
      position: "relative",
      overflow: "hidden",
      background: "var(--lk-paper)",
      boxShadow: "var(--lk-shadow)",
      padding: 32,
      boxSizing: "border-box"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: 436,
      top: 7,
      width: 200,
      height: 250,
      opacity: 0.1,
      display: "grid",
      gridTemplateColumns: "160px",
      gridAutoRows: "180px",
      overflow: "hidden"
    }
  }, [0, 1].map(i => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      width: 160,
      height: 180,
      boxShadow: "inset 0 0 0 2px var(--lk-black)"
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      display: "flex",
      flexDirection: "column",
      gap: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: CARD_TITLE
  }, "CHORD LIBRARY"), /*#__PURE__*/React.createElement(WebIcon, {
    name: "library-music-lg",
    w: 25,
    h: 25
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      ...CARD_DESC,
      maxWidth: 384
    }
  }, "Over 10,000 voicings. Discover new shapes and\ninversions instantly."), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8,
      padding: "8px 0"
    }
  }, ["Cmaj7", "Am9", "G13"].map(c => /*#__PURE__*/React.createElement("span", {
    key: c,
    style: {
      height: 32,
      background: "var(--lk-orange)",
      padding: "4px 12px",
      boxSizing: "border-box",
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 400,
      fontSize: 16,
      lineHeight: "24px"
    }
  }, c))))), /*#__PURE__*/React.createElement("div", {
    style: {
      gridColumn: "7 / span 6",
      height: 224,
      background: "var(--lk-paper)",
      boxShadow: "var(--lk-shadow)",
      padding: 32,
      boxSizing: "border-box",
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
      paddingBottom: 24
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: CARD_TITLE
  }, "PRACTICE TOOLS"), /*#__PURE__*/React.createElement(WebIcon, {
    name: "graduation-cap",
    w: 27.5,
    h: 22.5
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      ...CARD_DESC,
      paddingBottom: 32
    }
  }, "Track your progress, build routines, and master the fretboard with\ninteractive drills."), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 32,
      background: "var(--lk-paper)",
      display: "flex",
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: "65%",
      height: "100%",
      background: "var(--lk-orange)",
      padding: "0 8px",
      boxSizing: "border-box",
      display: "flex",
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: "var(--lk-font-mono)",
      fontWeight: 700,
      fontSize: 16,
      lineHeight: "24px"
    }
  }, "LEVEL 42")))));
}
function LandingScreen() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 64,
      alignItems: "center",
      padding: "0 0 112px"
    }
  }, /*#__PURE__*/React.createElement(Hero, null), /*#__PURE__*/React.createElement(BentoGrid, null));
}
Object.assign(window, {
  LKWebLanding: LandingScreen,
  LKWebIcon: WebIcon
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/website/LandingScreen.jsx", error: String((e && e.message) || e) }); }

__ds_ns.ContentEditor = __ds_scope.ContentEditor;

__ds_ns.DataTable = __ds_scope.DataTable;

__ds_ns.FilterBar = __ds_scope.FilterBar;

__ds_ns.StatCard = __ds_scope.StatCard;

__ds_ns.StatusBadge = __ds_scope.StatusBadge;

__ds_ns.AppButton = __ds_scope.AppButton;

__ds_ns.AppCard = __ds_scope.AppCard;

__ds_ns.AppChip = __ds_scope.AppChip;

__ds_ns.AppIconButton = __ds_scope.AppIconButton;

__ds_ns.AppSectionHeader = __ds_scope.AppSectionHeader;

__ds_ns.AppTextField = __ds_scope.AppTextField;

__ds_ns.PremiumBadge = __ds_scope.PremiumBadge;

__ds_ns.ConfirmDialog = __ds_scope.ConfirmDialog;

__ds_ns.EmptyState = __ds_scope.EmptyState;

__ds_ns.BpmDisplay = __ds_scope.BpmDisplay;

__ds_ns.ChordDiagram = __ds_scope.ChordDiagram;

__ds_ns.Fretboard = __ds_scope.Fretboard;

__ds_ns.PracticeProgress = __ds_scope.PracticeProgress;

__ds_ns.SongCard = __ds_scope.SongCard;

__ds_ns.TunerMeter = __ds_scope.TunerMeter;

__ds_ns.AdminHeader = __ds_scope.AdminHeader;

__ds_ns.AdminSidebar = __ds_scope.AdminSidebar;

__ds_ns.BottomNavBar = __ds_scope.BottomNavBar;

__ds_ns.TopAppBar = __ds_scope.TopAppBar;

})();
