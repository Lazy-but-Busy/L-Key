import * as React from "react";

/** The flagship tuner readout: huge detected note, Hz, cents needle, tuning footer. */
export interface TunerMeterProps {
  /** Detected note letter. */
  note?: string;
  /** Octave number, set small beside the note. */
  octave?: number | string;
  /** Frequency in Hz, printed to 2dp. */
  frequency?: number;
  /** Deviation in cents, -50…+50. Negative = flat (needle left). */
  cents?: number;
  /** ±cents that counts as locked; the lock state turns Guitar Orange. Default 3. */
  tolerance?: number;
  /** Uppercase tuning name, e.g. "STANDARD", "DROP D". */
  tuning?: string;
  /** Reference pitch in Hz. Default 440. */
  referencePitch?: number;
  width?: number;
  style?: React.CSSProperties;
}

export function TunerMeter(props: TunerMeterProps): JSX.Element;
