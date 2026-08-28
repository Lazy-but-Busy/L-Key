import * as React from "react";

/** Publication / payment status pill: coloured dot plus the word, so colour is never the only signal. */
export interface StatusBadgeProps {
  /** Default "published". */
  status?: "published" | "draft" | "archived" | "pending" | "failed";
  /** Override the label text. */
  children?: React.ReactNode;
  style?: React.CSSProperties;
}

export function StatusBadge(props: StatusBadgeProps): JSX.Element;
