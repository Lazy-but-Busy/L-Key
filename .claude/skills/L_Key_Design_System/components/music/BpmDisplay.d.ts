import * as React from "react";

/** Metronome / practice tempo readout with an accented beat indicator. */
export interface BpmDisplayProps {
  bpm?: number;
  /** Beats in the bar. Default 4. */
  beats?: number;
  /** 0-based index of the beat currently sounding. */
  activeBeat?: number;
  /** e.g. "4/4", "6/8". */
  timeSignature?: string;
  /** e.g. "8ths", "triplets" — appended after the time signature. */
  subdivision?: string;
  /** lg = 48px number, md = 36px. Default "lg". */
  size?: "lg" | "md";
  style?: React.CSSProperties;
}

export function BpmDisplay(props: BpmDisplayProps): JSX.Element;
