import * as React from "react";

export interface AdminNavItem {
  label: string;
  icon?: React.ReactNode;
}

/** Admin Portal navigation drawer — 320px, 4px black rail on its right edge. */
export interface AdminSidebarProps {
  /** Wordmark, Space Grotesk 48 / -2.4px. Default "L KEY". */
  brand?: string;
  /** Signed-in admin card. `avatar` should point at a real image asset. */
  user?: { name: string; role: string; avatar?: string };
  items?: AdminNavItem[];
  activeIndex?: number;
  onSelect?: (index: number) => void;
  /** Bottom slot — the source puts "System Logout" here (black button, orange shadow). */
  footer?: React.ReactNode;
  style?: React.CSSProperties;
}

export function AdminSidebar(props: AdminSidebarProps): JSX.Element;
