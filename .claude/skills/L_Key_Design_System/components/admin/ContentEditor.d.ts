import * as React from "react";

export interface ContentEditorSection {
  /** Uppercase mono section caption — BASIC INFORMATION, MUSIC INFORMATION, RIGHTS… */
  title: string;
  /** Fields (AppTextField, selects). */
  children?: React.ReactNode;
  /** Grid columns for this section. Default 2. */
  columns?: number;
}

/** The admin content editor shell for songs, chords, scales and lessons. */
export interface ContentEditorProps {
  /** Panel title, Space Grotesk 20. Default "Song Information". */
  title?: string;
  sections?: ContentEditorSection[];
  /** Right side of the header — usually a StatusBadge. */
  status?: React.ReactNode;
  /** Footer actions. Publishing must be an explicit action (DESIGN.md §50). */
  actions?: React.ReactNode;
  style?: React.CSSProperties;
}

export function ContentEditor(props: ContentEditorProps): JSX.Element;
