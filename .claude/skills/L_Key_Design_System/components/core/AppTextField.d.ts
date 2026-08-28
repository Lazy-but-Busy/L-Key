import * as React from "react";

/** Rectangular high-contrast text input — search fields, admin forms. */
export interface AppTextFieldProps {
  /** Uppercase mono label rendered above the field. */
  label?: string;
  value?: string;
  placeholder?: string;
  /** Leading glyph, inset 12px from the left edge. */
  icon?: React.ReactNode;
  onChange?: (e: React.ChangeEvent<HTMLInputElement>) => void;
  /** Full-width. Default true. */
  block?: boolean;
  style?: React.CSSProperties;
  inputStyle?: React.CSSProperties;
}

export function AppTextField(props: AppTextFieldProps): JSX.Element;
