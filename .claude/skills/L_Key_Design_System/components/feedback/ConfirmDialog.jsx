import React from "react";

const FOCUSABLE = 'button,[href],input,select,textarea,[tabindex]:not([tabindex="-1"])';

/* Confirm dialog. Rectangular, hard 6px shadow, destructive action stated in words.
   Named via aria-labelledby, focus moves in on open and is restored on close,
   Tab is trapped inside the panel, and Escape or a scrim click cancels. */
export function ConfirmDialog({ open = true, title = "DELETE SONG?", body, confirmLabel = "Delete", cancelLabel = "Cancel", destructive = true, onConfirm, onCancel, style }) {
  const panelRef = React.useRef(null);
  const cancelRef = React.useRef(null);
  const titleId = React.useId();
  const bodyId = React.useId();

  React.useEffect(() => {
    if (!open) return undefined;
    const previous = document.activeElement;
    if (cancelRef.current) cancelRef.current.focus();

    const onKeyDown = (e) => {
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

  return (
    <div
      onClick={(e) => { if (e.target === e.currentTarget && onCancel) onCancel(); }}
      style={{ position: "relative", display: "flex", alignItems: "center", justifyContent: "center", padding: 24, background: "rgba(0,0,0,0.4)", boxSizing: "border-box", ...style }}
    >
      <div ref={panelRef} role="dialog" aria-modal="true" aria-labelledby={titleId} aria-describedby={body ? bodyId : undefined}
        style={{ width: 380, maxWidth: "100%", boxSizing: "border-box", background: "var(--lk-surface)", boxShadow: "inset 0 0 0 2px var(--lk-black),var(--lk-shadow-lg)", display: "flex", flexDirection: "column" }}>
        <div style={{ padding: 24, display: "flex", flexDirection: "column", gap: 12 }}>
          <span id={titleId} style={{ fontFamily: "var(--lk-font-display)", fontWeight: 700, fontSize: 24, lineHeight: "28.8px", textTransform: "uppercase", color: destructive ? "var(--lk-danger)" : "var(--lk-text)" }}>{title}</span>
          {body ? <span id={bodyId} style={{ fontFamily: "var(--lk-font-body)", fontWeight: 400, fontSize: 16, lineHeight: "24px", color: "var(--lk-text-secondary)" }}>{body}</span> : null}
        </div>
        <div style={{ display: "flex", gap: 12, justifyContent: "flex-end", padding: 24, borderTop: "2px solid var(--lk-divider)" }}>
          <button ref={cancelRef} type="button" onClick={onCancel} style={{ appearance: "none", border: "none", cursor: "pointer", background: "var(--lk-white)", color: "var(--lk-black)", boxShadow: "var(--lk-ring)", padding: "0 24px", minHeight: 48, fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase" }}>{cancelLabel}</button>
          <button type="button" onClick={onConfirm} style={{ appearance: "none", border: "none", cursor: "pointer", background: destructive ? "var(--lk-danger)" : "var(--lk-black)", color: "var(--lk-white)", boxShadow: "var(--lk-shadow)", padding: "0 24px", minHeight: 48, fontFamily: "var(--lk-font-mono)", fontWeight: 500, fontSize: 14, letterSpacing: "var(--lk-ls-tech-track)", textTransform: "uppercase" }}>{confirmLabel}</button>
        </div>
      </div>
    </div>
  );
}
