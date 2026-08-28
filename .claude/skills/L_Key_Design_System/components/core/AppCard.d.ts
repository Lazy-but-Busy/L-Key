import * as React from "react";

/** The container for one meaningful unit — a song, a chord, an exercise, a session. */
export interface AppCardProps {
  children?: React.ReactNode;
  /** Uppercase mono category line (DESIGN.md §17 card structure). */
  label?: string;
  /** Space Grotesk 24 title. */
  title?: string;
  /** Right-aligned element on the title row (usually an AppIconButton or link). */
  action?: React.ReactNode;
  /** shadow = 4px hard shadow only (mobile), ring = inset 2px ring + shadow (admin/song viewer), flat = neither. Default "shadow". */
  variant?: "shadow" | "ring" | "flat";
  /** Inner padding in px. 24 on mobile, 32 on desktop feature cards. Default 24. */
  padding?: number | string;
  /** surface = white, sunken = paper, accent = Guitar Orange, inverse = black. Default "surface". */
  tone?: "surface" | "sunken" | "accent" | "inverse";
  style?: React.CSSProperties;
}

export function AppCard(props: AppCardProps): JSX.Element;
