import * as React from "react";

/** A small mono-typed fact: key, capo, BPM, tuning, formula, root note. */
export interface AppChipProps {
  /** The value. */
  children?: React.ReactNode;
  /** Optional uppercase mono caption above/before the value (KEY, CAPO, FORMULA…). */
  label?: string;
  /**
   * chip   — grey-100, inset ring + 2px shadow (song header metadata)
   * tag    — flat #EEEEEE (table cells)
   * bento  — #E2E2E2 + 4px shadow, centred label over value (chord detail bento)
   * accent — Guitar Orange + ring (BPM badge over artwork, PRO markers)
   * dark   — black on white text (Hz readout)
   * Default "chip".
   */
  variant?: "chip" | "tag" | "bento" | "accent" | "dark";
  icon?: React.ReactNode;
  style?: React.CSSProperties;
}

export function AppChip(props: AppChipProps): JSX.Element;
