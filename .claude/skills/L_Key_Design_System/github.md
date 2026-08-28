repo: Lazy-but-Busy/L-Key
branch: main
path: (repo root — documentation only; `mobile/`, `admin/`, `website/`, `backend/` are not yet committed)

## Last sync

date: 2026-08-28T08:42:44Z

### Updated in this project

- Built the token system (colors, typography, spacing, borders, shadows) from `DESIGN.md` §5–14.
- Authored 24 components matching the `DESIGN.md` §65 component-naming inventory.
- Recreated the six frames of "L Key UIs.fig" as three UI kits: mobile app, admin portal, landing website.
- Wrote foundation specimen cards for colour, type, spacing and brand motifs.

## Screen map

| Project surface | Built from |
| --- | --- |
| `tokens/*.css` | `DESIGN.md` §5–14, §66 + exact values read from L Key UIs.fig |
| `components/core/*`, `components/music/*` | `DESIGN.md` §15–31, §65 (mobile list) |
| `components/admin/*`, `components/navigation/AdminSidebar.jsx`, `AdminHeader.jsx` | `DESIGN.md` §44–57, §65 (admin list) |
| `components/feedback/*` | `DESIGN.md` §37–38 |
| `ui_kits/mobile_app/*` | L Key UIs.fig `/Page-1/Html-Body`, `/Html-Body3`, `/Html-Body2` |
| `ui_kits/admin_portal/*` | L Key UIs.fig `/Page-1/Html-Body4`, `/Html-Body5` |
| `ui_kits/website/*` | L Key UIs.fig `/Page-1/Html-Body6` |
| `readme.md` content & tone sections | `README.md`, `PRD.md`, `DESIGN.md` |

Note: the repository currently contains only `README.md`, `PRD.md`, `DESIGN.md` and `CLAUDE.md`. No Flutter, Next.js or backend source exists upstream yet, so no implementation code was read or copied.
