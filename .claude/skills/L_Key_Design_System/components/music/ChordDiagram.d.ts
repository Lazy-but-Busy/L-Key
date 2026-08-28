import * as React from "react";

export interface ChordPosition {
  /** 0-based string index, left to right as drawn. */
  string: number;
  /** 1-based fret number. */
  fret: number;
  /** Finger number printed inside the marker. */
  finger?: number | string;
  /** Root note — renders in Guitar Orange (DESIGN.md §25). */
  root?: boolean;
}

/**
 * Chord diagram: 16px black fret nut, 4px strings, 36px finger markers.
 */
export interface ChordDiagramProps {
  /** Chord name shown above the canvas in Space Grotesk 36. Pass "" to hide. */
  name?: string;
  /** Number of strings drawn. Default 6. */
  strings?: number;
  /** Fret rows drawn. Default 4. */
  frets?: number;
  positions?: ChordPosition[];
  /** String indices marked "O". */
  openStrings?: number[];
  /** String indices marked "X" in --lk-danger. */
  mutedStrings?: number[];
  /** Finger-number row under the grid, one entry per string. */
  fingers?: (string | number)[];
  /** Grid width in px. Default 278 (the 342px card minus 32px padding). */
  width?: number;
  style?: React.CSSProperties;
}

export function ChordDiagram(props: ChordDiagramProps): JSX.Element;
