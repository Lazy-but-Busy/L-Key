import * as React from "react";

/**
 * The tactile primary action. Rectangular, hard 4px offset shadow, translates
 * toward the shadow when pressed.
 */
export interface AppButtonProps {
  children?: React.ReactNode;
  /** primary = black, accent = Guitar Orange, secondary = white, ghost = outline only. Default "primary". */
  variant?: "primary" | "accent" | "secondary" | "ghost";
  /**
   * sm  — 26px, JetBrains Mono 12 (table / chart toggles)
   * md  — 48px, JetBrains Mono 14 tracked uppercase (admin actions)
   * lg  — 52px, Space Grotesk 18 uppercase (mobile primary)
   * xl  — 56px, Space Grotesk 16 uppercase (marketing CTA)
   * hero — 61px, Space Grotesk 24 (chord "Play Chord")
   * Default "lg".
   */
  size?: "sm" | "md" | "lg" | "xl" | "hero";
  /** Icon element (an <img> of an assets/icons SVG, or inline svg). */
  icon?: React.ReactNode;
  iconPosition?: "left" | "right";
  /** Stretch to the container width. */
  block?: boolean;
  disabled?: boolean;
  onClick?: (e: React.MouseEvent<HTMLButtonElement>) => void;
  style?: React.CSSProperties;
}

export function AppButton(props: AppButtonProps): JSX.Element;
