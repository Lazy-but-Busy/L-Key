import * as React from "react";

/** Session / streak / exercise progress bar with the file's diagonal hatch fill. */
export interface PracticeProgressProps {
  value?: number;
  /** Default 100. */
  max?: number;
  /** Uppercase mono focus line, e.g. "FOCUS: PENTATONIC SPEED". */
  label?: string;
  /** Big Space Grotesk elapsed figure, e.g. "30:00". */
  elapsed?: string;
  /** Mono denominator, e.g. "60:00 MIN". */
  total?: string;
  /** Track height in px. Default 32. */
  height?: number;
  /** Diagonal hatch over the fill. Default true. */
  showStripes?: boolean;
  style?: React.CSSProperties;
}

export function PracticeProgress(props: PracticeProgressProps): JSX.Element;
