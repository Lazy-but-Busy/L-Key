# UI kit — L Key Admin Portal (Next.js)

The two admin frames from **L Key UIs.fig** plus the remaining portal views built from `DESIGN.md` §44–58 (marked *spec-derived*).

| Screen | Source | File |
| --- | --- | --- |
| Dashboard | fig `Html → Body` (node 2:2) | `DashboardScreen.jsx` |
| Song database | fig node 2:207 | `SongDatabaseScreen.jsx` |
| Song editor | spec-derived (§49–51, incl. Rights section) | `ContentScreens.jsx` |
| Chord library | spec-derived (§52) | `ContentScreens.jsx` |
| User management | spec-derived (suspend/restore + ConfirmDialog) | `PeopleScreens.jsx` |
| Payments | spec-derived (§56: order, provider ref, webhook state) | `PeopleScreens.jsx` |
| Premium plans | spec-derived (§55, with audit log) | `BusinessScreens.jsx` |
| Analytics | spec-derived (§57, minimal charts) | `BusinessScreens.jsx` |

`index.html` puts all eight behind the sidebar (nav extended to seven sections per §46). The song database's edit icon opens the Song editor; user suspend/restore raises `ConfirmDialog`; plan availability toggles live. Only Yearly 25,000 MMK is a sourced price — Monthly / 3 Months / Lifetime figures are placeholders.

## Fidelity notes
- Sidebar is 320px with a `4px 0 0 0` black rail; the active row is Guitar Orange with a 2px ring **and** a 4px shadow. "System Logout" is black with an *orange* hard shadow — that inversion is in the file.
- Canvas is `#F3F3F3`, cards are white with `inset 0 0 0 2px #000` + `4px 4px 0 #000`.
- Dashboard chart is deliberately bars, not a line — the source frame names it "Neo-Brutalist alternative to line". One bar is orange with a black tooltip reading `11.2k`.
- Table head band is `#E8E8E8`; the Recent Payments panel uses the dense, fully-gridded variant with hairline/2px black cell borders.
- Sidebar glyphs: only `Dashboard` has distinct art in the source. All other rows carry documented assignments from real file glyphs (`library-music`, `stack-pin`, `users`, `history-clock`, `add-circle`, `more-horizontal`) — see readme.md → Iconography. The Premium stat card carries no icon, because the file contains no star or premium mark.
- Status words extend StatusBadge via its label override (Active/Inactive/Suspended, Complete/Pending/Failed) — dot + word, never colour alone (§56).
- **Composition note:** the source drew the song database with a mobile-style top app bar rather than the sidebar. Here it is placed inside the sidebar shell so all views are navigable together; nothing else about the screen was changed.
