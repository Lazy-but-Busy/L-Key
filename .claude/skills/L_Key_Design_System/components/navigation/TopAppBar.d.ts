import * as React from "react";

/**
 * The mobile screen header — menu, wordmark, settings.
 */
export interface TopAppBarProps {
  /** Wordmark or screen title, rendered uppercase. Default "L KEY". */
  title?: string;
  /** lg = Space Grotesk 36 (app screens), md = 24 (admin mobile bar). Default "lg". */
  size?: "lg" | "md";
  /** Left slot — usually an AppIconButton with the hamburger glyph. */
  leading?: React.ReactNode;
  /** Right slot — usually an AppIconButton with assets/icons/settings.svg. */
  trailing?: React.ReactNode;
  style?: React.CSSProperties;
}

export function TopAppBar(props: TopAppBarProps): JSX.Element;
