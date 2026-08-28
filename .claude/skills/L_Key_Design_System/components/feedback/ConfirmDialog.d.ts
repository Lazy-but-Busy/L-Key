import * as React from "react";

/** Blocking confirmation for destructive or irreversible admin actions. */
export interface ConfirmDialogProps {
  open?: boolean;
  /** Uppercase question, e.g. "DELETE SONG?" */
  title?: string;
  /** What will actually happen, in plain words. */
  body?: string;
  confirmLabel?: string;
  cancelLabel?: string;
  /** Destructive styling: title and confirm button take --lk-danger. Default true. */
  destructive?: boolean;
  onConfirm?: () => void;
  onCancel?: () => void;
  style?: React.CSSProperties;
}

export function ConfirmDialog(props: ConfirmDialogProps): JSX.Element | null;
