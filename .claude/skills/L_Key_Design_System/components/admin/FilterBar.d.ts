import * as React from "react";

export interface FilterGroup {
  key: string;
  /** Uppercase mono caption before the segment group. */
  label?: string;
  /** Segment labels, first is the default. */
  options: string[];
}

/** Segmented filters above an admin table (range, status, language, difficulty…). */
export interface FilterBarProps {
  groups?: FilterGroup[];
  /** Current selection per group key. */
  activeValues?: Record<string, string>;
  onChange?: (groupKey: string, value: string) => void;
  /** Right-hand slot — search field, "Add new" button, export. */
  trailing?: React.ReactNode;
  style?: React.CSSProperties;
}

export function FilterBar(props: FilterBarProps): JSX.Element;
