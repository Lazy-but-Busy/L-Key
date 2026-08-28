import * as React from "react";

/** Admin content header: uppercase page title, mono description, right-aligned actions. */
export interface AdminHeaderProps {
  title: string;
  /** One mono sentence describing the view, e.g. "Manage library, metadata, and publication status." */
  subtitle?: string;
  /** Buttons / search / filters. */
  actions?: React.ReactNode;
  /** lg = Space Grotesk 48 (list pages), md = 24 (dashboard). Default "md". */
  size?: "md" | "lg";
  style?: React.CSSProperties;
}

export function AdminHeader(props: AdminHeaderProps): JSX.Element;
