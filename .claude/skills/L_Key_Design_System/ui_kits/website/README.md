# UI kit — L Key landing website (Next.js)

Recreation of the marketing frame in **L Key UIs.fig** (`/Page-1/Html-Body6`, node 2:365), 1280px wide.

| Screen | Source frame | File |
| --- | --- | --- |
| Landing page | `Html → Body` (node 2:365) | `LandingScreen.jsx` |

## Fidelity notes
- Hero type is Space Grotesk **400** at 96/86.4 with -4.8px tracking — not bold. The eyebrow is JetBrains Mono 700 at 20/28 with +2px tracking, wrapped in literal square brackets: `[ TUNE . LEARN . PRACTICE . PLAY ]`.
- The hero's background is a single 10%-opacity radial gradient, copied verbatim from the frame — the only gradient anywhere in the system.
- The bento grid is 1232px on a 12-column grid, rows 368px / 236px, 24px gaps. Spans are 8 / 4 / 6 / 6.
- The metronome card is the one black surface on the page; its `BPM` label and beat dots are Guitar Orange.
- Card titles are Space Grotesk 16 uppercase; descriptions are Hanken Grotesk 16 in `--lk-grey-500`.
- The source frame has **no footer, no nav links and no second section** — none were invented. Pages listed in DESIGN.md §60–61 (`/features`, `/pricing`, FAQ, download CTA, screenshots) are undrawn and therefore unbuilt.
- Card-header glyphs are the frame's own art: `library-music-lg` on Chord Library, `graduation-cap` on Practice Tools. The Chord Library card's faint background is the frame's 8× 160×180 outlined rectangles at 10% opacity, not an enlarged icon.
