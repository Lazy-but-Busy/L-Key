import * as React from "react";

/** A song in a library, recent list or search result. */
export interface SongCardProps {
  title?: string;
  /** Rendered uppercase in mono. */
  artist?: string;
  /** Second half of the meta line, e.g. "RHYTHM", "FINGERSTYLE". */
  tag?: string;
  /** Tempo — renders the orange badge on the artwork when set. */
  bpm?: number | string;
  /** accent = Guitar Orange badge (default), muted = grey-200 badge (secondary items). */
  bpmTone?: "accent" | "muted";
  /** Artwork URL. Use a real image from assets/images — never a drawn placeholder. */
  cover?: string;
  /** Trailing element on the meta row (usually an AppIconButton with the overflow glyph). */
  action?: React.ReactNode;
  onClick?: () => void;
  style?: React.CSSProperties;
}

export function SongCard(props: SongCardProps): JSX.Element;
