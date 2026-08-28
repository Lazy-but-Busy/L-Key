import * as React from "react";

/**
 * Empty / error / no-results state. Headline uppercase, body one dry sentence.
 */
export interface EmptyStateProps {
  /** Uppercase Space Grotesk line, e.g. "NO RECORDINGS YET." */
  headline?: string;
  /** One short body sentence — subtle humour is allowed (DESIGN.md §37). */
  body?: string;
  /** Optional recovery action, e.g. an AppButton "Retry". */
  action?: React.ReactNode;
  icon?: React.ReactNode;
  align?: "center" | "left";
  style?: React.CSSProperties;
}

export function EmptyState(props: EmptyStateProps): JSX.Element;
