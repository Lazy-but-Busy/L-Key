import * as React from "react";

export interface FretMarker {
  /** 0-based string row, top to bottom. */
  string: number;
  /** 1-based fret. */
  fret: number;
  /** Note name or interval printed in the marker. */
  label?: string;
  /** Root note — Guitar Orange (DESIGN.md §25). */
  root?: boolean;
}

/** Interactive-looking technical fretboard for scales, modes, arpeggios and CAGED shapes. */
export interface FretboardProps {
  /** String labels, top row first. Default 6-string standard ["E","B","G","D","A","E"]. */
  strings?: string[];
  /** Fret count. Default 12. */
  frets?: number;
  markers?: FretMarker[];
  /** Px per fret. Default 52. */
  fretWidth?: number;
  /** Px per string row. Default 40. */
  rowHeight?: number;
  showFretNumbers?: boolean;
  style?: React.CSSProperties;
}

export function Fretboard(props: FretboardProps): JSX.Element;
