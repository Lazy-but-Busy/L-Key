import * as React from "react";

/** A square (or circular) icon-only control — menu, settings, play, transpose steppers. */
export interface AppIconButtonProps {
  /** The glyph — an <img> pointing at assets/icons/*.svg, or inline svg. */
  children?: React.ReactNode;
  /** plain = white + 4px shadow, ring = white + inset ring, solid = black, accent = orange, circle = pill + ring, bare = no chrome. Default "plain". */
  variant?: "plain" | "ring" | "solid" | "accent" | "circle" | "bare";
  /** Square edge in px. Real values in the file: 28, 32, 34, 36, 48, 64. Default 36. */
  size?: number;
  /** Accessible label — required, the button has no text. */
  label: string;
  onClick?: (e: React.MouseEvent<HTMLButtonElement>) => void;
  style?: React.CSSProperties;
}

export function AppIconButton(props: AppIconButtonProps): JSX.Element;
