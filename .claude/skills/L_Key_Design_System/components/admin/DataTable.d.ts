import * as React from "react";

export interface DataTableColumn {
  /** Key into each row object. */
  key: string;
  /** Header text — rendered uppercase mono. */
  label: string;
  /** Fixed column width in px; omit to flex. */
  width?: number;
  align?: "left" | "center" | "right";
  /** Bold the cell value (mono 700) — used for IDs. */
  strong?: boolean;
  /** "body" switches the cell to Hanken Grotesk (titles); default mono. */
  font?: "mono" | "body";
}

/** The admin table. Renders semantic <table> markup; cells accept nodes, so drop
 *  StatusBadge / AppChip / AppIconButton straight in. */
export interface DataTableProps {
  columns?: DataTableColumn[];
  /** Row objects keyed by column key; values may be strings or React nodes. */
  rows?: Record<string, React.ReactNode>[];
  /** Left-hand mono note, e.g. "Showing 1 to 4 of 42 entries". */
  footerNote?: React.ReactNode;
  /** Pager buttons (usually AppButton size="sm"). */
  pagination?: React.ReactNode;
  /** 47.59px rows instead of 66px — the compact dashboard table. */
  dense?: boolean;
  /** Full hairline black grid on every cell (Recent Payments style). */
  gridded?: boolean;
  /** Optional <caption>, announced before the table. Mono uppercase. */
  caption?: React.ReactNode;
  /** Shown in a full-width row when `rows` is empty. */
  emptyLabel?: React.ReactNode;
  style?: React.CSSProperties;
}

export function DataTable(props: DataTableProps): JSX.Element;
