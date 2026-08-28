import * as React from "react";

export interface BottomNavItem {
  /** Mono 12 caption — Home, Tools, Learn, Songs, Profile (DESIGN.md §19). */
  label: string;
  icon?: React.ReactNode;
}

/** The mobile primary navigation: five tabs, active tab filled Guitar Orange. */
export interface BottomNavBarProps {
  items?: BottomNavItem[];
  activeIndex?: number;
  onSelect?: (index: number) => void;
  style?: React.CSSProperties;
}

export function BottomNavBar(props: BottomNavBarProps): JSX.Element;
