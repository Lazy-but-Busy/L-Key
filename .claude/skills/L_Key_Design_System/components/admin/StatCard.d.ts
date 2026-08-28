import * as React from "react";

/**
 * One dashboard KPI: mono label, 48px figure, orange delta.
 */
export interface StatCardProps {
  /** Uppercase mono caption — TOTAL USERS, ACTIVE TODAY, PREMIUM, SONGS. */
  label: string;
  /** Pre-formatted figure, e.g. "12,542". */
  value: string | number;
  /** Change string, e.g. "+14.2%". Always rendered in Guitar Orange. */
  delta?: string;
  deltaDirection?: "up" | "down";
  /** Secondary grey note, e.g. "+24 this week". */
  note?: string;
  /** Top-right glyph. */
  icon?: React.ReactNode;
  /** Decorative bleed shape behind the content. Default "circle". */
  ornament?: "circle" | "square" | "none";
  style?: React.CSSProperties;
}

export function StatCard(props: StatCardProps): JSX.Element;
