/**
 * L KEY DESIGN TOKENS — GENERATED FILE. DO NOT EDIT.
 * 
 * Source:    packages/design-tokens/tokens.json
 * Generator: packages/design-tokens/build.mjs
 * Regenerate with `npm run tokens`. CI runs `npm run tokens:check`.
 */

export const tokens = {
  "color": {
    "black": {
      "value": "#000000",
      "source": "DESIGN.md §5 PRIMARY"
    },
    "white": {
      "value": "#FFFFFF",
      "source": "surface for cards on the off-white ground"
    },
    "offWhite": {
      "value": "#F0F0F0",
      "source": "DESIGN.md §5 BACKGROUND / OFF_WHITE"
    },
    "orange": {
      "value": "#FF4D00",
      "source": "DESIGN.md §5 ACCENT / GUITAR_ORANGE"
    },
    "grey100": {
      "value": "#E5E5E5",
      "source": "DESIGN.md §5"
    },
    "grey200": {
      "value": "#D0D0D0",
      "source": "DESIGN.md §5"
    },
    "grey300": {
      "value": "#B5B5B5",
      "source": "DESIGN.md §5"
    },
    "grey400": {
      "value": "#888888",
      "source": "DESIGN.md §5 — decorative only, fails AA as text on any L Key ground"
    },
    "grey500": {
      "value": "#666666",
      "source": "DESIGN.md §5"
    },
    "grey600": {
      "value": "#333333",
      "source": "DESIGN.md §5"
    },
    "darkBackground": {
      "value": "#000000",
      "source": "DESIGN.md §6 BACKGROUND"
    },
    "darkSurface": {
      "value": "#111111",
      "source": "DESIGN.md §6 SURFACE"
    },
    "darkSurface2": {
      "value": "#1C1C1C",
      "source": "DESIGN.md §6 SURFACE_2"
    },
    "darkText": {
      "value": "#F0F0F0",
      "source": "DESIGN.md §6 PRIMARY_TEXT"
    },
    "darkTextSecondary": {
      "value": "#999999",
      "source": "DESIGN.md §6 SECONDARY_TEXT"
    },
    "danger": {
      "value": "#BA1A1A",
      "source": "gap-fill — DESIGN.md §38 requires error states but names no colour"
    },
    "success": {
      "value": "#1E7A34",
      "source": "gap-fill — DESIGN.md §56 requires status display but names no colour"
    },
    "dangerDark": {
      "value": "#F87171",
      "source": "gap-fill — #BA1A1A is 2.92:1 on the dark surface; DESIGN.md §68 forbids simply inverting"
    },
    "successDark": {
      "value": "#3DD68C",
      "source": "gap-fill — #1E7A34 is 3.50:1 on the dark surface"
    }
  },
  "typography": {
    "family": {
      "display": {
        "value": "Space Grotesk",
        "source": "DESIGN.md §8 Display"
      },
      "body": {
        "value": "Hanken Grotesk",
        "source": "DESIGN.md §8 Body"
      },
      "mono": {
        "value": "JetBrains Mono",
        "source": "DESIGN.md §8 Technical"
      },
      "myanmar": {
        "value": "Noto Sans Myanmar",
        "source": "gap-fill — the three brand faces carry no Burmese glyphs; see docs/adr/0006-myanmar-font-fallback.md"
      }
    },
    "weight": {
      "light": {
        "value": 300
      },
      "regular": {
        "value": 400
      },
      "medium": {
        "value": 500
      },
      "semiBold": {
        "value": 600
      },
      "bold": {
        "value": 700
      }
    },
    "scale": {
      "displayXl": {
        "size": 64,
        "lineHeight": 0.95,
        "letterSpacing": -0.05,
        "family": "display",
        "weight": "bold",
        "source": "DESIGN.md §9 Display XL 48-64, upper bound"
      },
      "display": {
        "size": 48,
        "lineHeight": 1.1,
        "letterSpacing": -0.02,
        "family": "display",
        "weight": "bold",
        "source": "DESIGN.md §9 Display 36-48, upper bound"
      },
      "h1": {
        "size": 32,
        "lineHeight": 1.1,
        "letterSpacing": -0.05,
        "family": "display",
        "weight": "bold",
        "source": "DESIGN.md §9 H1"
      },
      "h2": {
        "size": 24,
        "lineHeight": 1.2,
        "letterSpacing": -0.05,
        "family": "display",
        "weight": "bold",
        "source": "DESIGN.md §9 H2"
      },
      "h3": {
        "size": 20,
        "lineHeight": 1.5,
        "letterSpacing": 0,
        "family": "display",
        "weight": "semiBold",
        "source": "DESIGN.md §9 H3"
      },
      "bodyLarge": {
        "size": 18,
        "lineHeight": 1.6,
        "letterSpacing": 0,
        "family": "body",
        "weight": "regular",
        "source": "DESIGN.md §9 Body Large"
      },
      "body": {
        "size": 16,
        "lineHeight": 1.5,
        "letterSpacing": 0,
        "family": "body",
        "weight": "regular",
        "source": "DESIGN.md §9 Body"
      },
      "bodySmall": {
        "size": 14,
        "lineHeight": 1.5,
        "letterSpacing": 0,
        "family": "body",
        "weight": "regular",
        "source": "DESIGN.md §9 Body Small"
      },
      "label": {
        "size": 12,
        "lineHeight": 1.2,
        "letterSpacing": 0,
        "family": "mono",
        "weight": "medium",
        "source": "DESIGN.md §9 Label"
      },
      "technicalLg": {
        "size": 16,
        "lineHeight": 1.5,
        "letterSpacing": 0.05,
        "family": "mono",
        "weight": "medium",
        "source": "DESIGN.md §9 Technical 12-16, upper bound"
      },
      "technical": {
        "size": 14,
        "lineHeight": 1.4,
        "letterSpacing": 0.05,
        "family": "mono",
        "weight": "medium",
        "source": "DESIGN.md §9-10 Technical with tracking"
      },
      "technicalSm": {
        "size": 12,
        "lineHeight": 1.2,
        "letterSpacing": 0.05,
        "family": "mono",
        "weight": "medium",
        "source": "DESIGN.md §9 Technical 12-16, lower bound"
      }
    }
  },
  "spacing": {
    "s1": {
      "value": 4
    },
    "s2": {
      "value": 8
    },
    "s3": {
      "value": 12
    },
    "s4": {
      "value": 16
    },
    "s5": {
      "value": 20
    },
    "s6": {
      "value": 24
    },
    "s8": {
      "value": 32
    },
    "s10": {
      "value": 40
    },
    "s12": {
      "value": 48
    },
    "s16": {
      "value": 64
    },
    "s20": {
      "value": 80
    }
  },
  "border": {
    "hairline": {
      "value": 1,
      "source": "table grid lines"
    },
    "default": {
      "value": 2,
      "source": "DESIGN.md §11 primary neo-brutalist border"
    },
    "strong": {
      "value": 3,
      "source": "DESIGN.md §11 important interactive components"
    }
  },
  "radius": {
    "none": {
      "value": 0
    },
    "sm": {
      "value": 4
    },
    "md": {
      "value": 8
    },
    "pill": {
      "value": 9999,
      "source": "circular avatars and play buttons only"
    }
  },
  "shadow": {
    "sm": {
      "offsetX": 2,
      "offsetY": 2,
      "blur": 0,
      "source": "DESIGN.md §13 small component"
    },
    "default": {
      "offsetX": 4,
      "offsetY": 4,
      "blur": 0,
      "source": "DESIGN.md §13 primary"
    },
    "lg": {
      "offsetX": 6,
      "offsetY": 6,
      "blur": 0,
      "source": "DESIGN.md §13 large interactive"
    },
    "pressed": {
      "offsetX": 1,
      "offsetY": 1,
      "blur": 0,
      "source": "DESIGN.md §15 pressed state"
    }
  },
  "animation": {
    "durationFast": {
      "value": 90,
      "unit": "ms",
      "source": "design system --lk-duration-fast"
    },
    "durationBase": {
      "value": 140,
      "unit": "ms",
      "source": "design system --lk-duration"
    },
    "easing": {
      "value": [
        0.2,
        0,
        0,
        1
      ],
      "source": "design system --lk-ease cubic-bezier(0.2,0,0,1)"
    },
    "pressTranslate": {
      "value": 3,
      "source": "DESIGN.md §15 translate toward the shadow; magnitude from design system --lk-press-translate"
    }
  },
  "dimension": {
    "tapTarget": {
      "value": 44,
      "source": "WCAG 2.5.5 / design system --lk-tap-target"
    },
    "screenPadding": {
      "value": 16,
      "source": "DESIGN.md §14 mobile screen padding"
    },
    "screenPaddingWide": {
      "value": 24,
      "source": "DESIGN.md §14 tablet/web 24-40, lower bound"
    },
    "adminPadding": {
      "value": 32,
      "source": "design system --lk-admin-padding"
    },
    "bottomNavHeight": {
      "value": 71,
      "source": "design system --lk-bottomnav-height"
    },
    "topBarHeight": {
      "value": 76,
      "source": "design system --lk-topbar-height"
    },
    "sidebarWidth": {
      "value": 320,
      "source": "design system --lk-sidebar-width"
    },
    "contentMaxWidth": {
      "value": 1232,
      "source": "design system --lk-content-max"
    }
  },
  "semantic": {
    "light": {
      "background": "offWhite",
      "surface": "white",
      "surfaceSunken": "grey100",
      "surfaceInverse": "black",
      "textPrimary": "black",
      "textSecondary": "grey600",
      "textTertiary": "grey500",
      "textInverse": "offWhite",
      "border": "black",
      "divider": "black",
      "accent": "orange",
      "accentOn": "black",
      "focusRing": "black",
      "danger": "danger",
      "success": "success"
    },
    "dark": {
      "background": "darkBackground",
      "surface": "darkSurface",
      "surfaceSunken": "darkSurface2",
      "surfaceInverse": "darkText",
      "textPrimary": "darkText",
      "textSecondary": "darkTextSecondary",
      "textTertiary": "darkTextSecondary",
      "textInverse": "darkBackground",
      "border": "darkText",
      "divider": "darkText",
      "accent": "orange",
      "accentOn": "black",
      "focusRing": "orange",
      "danger": "dangerDark",
      "success": "successDark"
    }
  },
  "contrastPairs": {
    "pairs": [
      {
        "fg": "textPrimary",
        "bg": "background",
        "min": 4.5,
        "note": "body copy on the app ground"
      },
      {
        "fg": "textPrimary",
        "bg": "surface",
        "min": 4.5,
        "note": "body copy on a card"
      },
      {
        "fg": "textSecondary",
        "bg": "background",
        "min": 4.5
      },
      {
        "fg": "textSecondary",
        "bg": "surface",
        "min": 4.5
      },
      {
        "fg": "textTertiary",
        "bg": "background",
        "min": 4.5,
        "note": "grey-400 fails here at 3.11:1; grey-500 is why this passes"
      },
      {
        "fg": "textTertiary",
        "bg": "surface",
        "min": 4.5
      },
      {
        "fg": "textSecondary",
        "bg": "surfaceSunken",
        "min": 4.5
      },
      {
        "fg": "accentOn",
        "bg": "accent",
        "min": 4.5,
        "note": "orange is a surface colour; black sits on it"
      },
      {
        "fg": "textInverse",
        "bg": "surfaceInverse",
        "min": 4.5
      },
      {
        "fg": "danger",
        "bg": "surface",
        "min": 4.5
      },
      {
        "fg": "danger",
        "bg": "background",
        "min": 4.5
      },
      {
        "fg": "success",
        "bg": "surface",
        "min": 4.5
      },
      {
        "fg": "success",
        "bg": "background",
        "min": 4.5
      },
      {
        "fg": "focusRing",
        "bg": "background",
        "min": 3,
        "note": "WCAG 2.4.11 — the ring must read against the app ground"
      },
      {
        "fg": "focusRing",
        "bg": "surface",
        "min": 3
      },
      {
        "fg": "accent",
        "bg": "surface",
        "min": 3,
        "note": "orange is 2.92:1 on the #F0F0F0 ground, so an orange fill NEVER carries a boundary alone — it always takes a border or hard shadow (DESIGN.md §42, no meaning by colour alone)"
      }
    ]
  }
} as const;

export type SemanticColorKey = keyof typeof tokens.semantic.light;
export type SpacingKey = keyof typeof tokens.spacing;
export type TypeScaleKey = keyof typeof tokens.typography.scale;

/** CSS custom-property name for a semantic colour role. */
export const cssVar = (key: SemanticColorKey): string =>
  `var(--lk-${key.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase()})`;
