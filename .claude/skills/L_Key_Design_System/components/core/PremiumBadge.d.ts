import * as React from "react";

/** Marks a Pro-gated capability. Orange + black type, never gold or glowing (DESIGN.md §32). */
export interface PremiumBadgeProps {
  /** Default "PRO". */
  children?: React.ReactNode;
  /** accent = Guitar Orange on black type; inverse = black on white type. Default "accent". */
  tone?: "accent" | "inverse";
  size?: "sm" | "md";
  style?: React.CSSProperties;
}

export function PremiumBadge(props: PremiumBadgeProps): JSX.Element;
