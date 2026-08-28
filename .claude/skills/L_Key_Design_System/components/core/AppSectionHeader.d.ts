import * as React from "react";

/** Uppercase section title with an optional mono "VIEW LIBRARY →" action. */
export interface AppSectionHeaderProps {
  title: string;
  /** Mono uppercase action text; renders with the file's arrow glyph. */
  actionLabel?: string;
  onAction?: () => void;
  /** md = Space Grotesk 24 semibold (in-screen sections), lg = 48 bold (page titles). Default "md". */
  size?: "md" | "lg";
  style?: React.CSSProperties;
}

export function AppSectionHeader(props: AppSectionHeaderProps): JSX.Element;
