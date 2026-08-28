# UI kit — L Key mobile app (Flutter, iOS + Android)

The three Figma frames plus the rest of the app's screens built from the written spec in `DESIGN.md` / `README.md` (no frame exists for them — each is marked *spec-derived* below).

| Screen | Source | File |
| --- | --- | --- |
| Home | fig `Html → Body` (node 1:2) | `HomeScreen.jsx` |
| Chord detail | fig node 1:299 | `ChordScreen.jsx` |
| Song viewer | fig node 1:136 | `SongViewerScreen.jsx` |
| Tools hub | spec-derived (README feature list, §32 PRO gating) | `ToolsScreens.jsx` |
| Tuner | spec-derived (DESIGN.md §21–22) | `ToolsScreens.jsx` |
| Metronome | spec-derived (§27) | `ToolsScreens.jsx` |
| Scales | spec-derived (§25–26) | `ToolsScreens.jsx` |
| Song library | spec-derived (README → Songs) | `LibraryScreens.jsx` |
| Learn | spec-derived (README → Learning) | `LibraryScreens.jsx` |
| Practice | spec-derived (§30–31) | `LibraryScreens.jsx` |
| Profile | spec-derived | `ProfileScreens.jsx` |
| Paywall | spec-derived (§33) | `ProfileScreens.jsx` |
| Payment (MMQR) | spec-derived (§34–35) | `ProfileScreens.jsx` |

`index.html` mounts all 13 behind the real 71px tab bar. Live behaviour: tuner needle settles to an orange lock per string; metronome runs (start/stop, tap tempo, time signatures); song search filters; transpose/auto-scroll work; paywall → MMQR QR → “Simulate Webhook” → `PAYMENT COMPLETE / PRO IS ACTIVE.` flips the profile to Pro. The payment QR is a labelled non-scannable placeholder, and success only ever follows the (simulated) webhook — per the spec's payment honesty rules.

Only the Yearly price (25,000 MMK) is sourced; Monthly 2,500 MMK is a placeholder awaiting real pricing.

## Fidelity notes
- Frame width is 390px; gutters are 24px on Home/Chords and 16px on the song viewer, exactly as in the file.
- Home's "Quick Tune" card is the only orange surface on the screen. Song card 2's BPM badge is grey `#D0D0D0`, not orange — that difference is in the source.
- The chord grid, fret nut (16px black bar) and 4px strings come from `StringsVertical` / `StringStatusTop` in the file.
- Bottom-tab glyphs: `Home` uses the file's own house path. The source frame reuses one instance for all five tabs, so `Tools / Learn / Songs / Profile` are assigned from real file glyphs (`settings-alt`, `graduation-cap`, `library-music`, `users`) — see readme.md → Iconography.
- Icon files are named for what they draw, not where the frame used them: the song viewer's BPM chip glyph really is a *heart* (`heart.svg`), and the quick-tool row's trailing mark is stacked cards with a map pin (`stack-pin.svg`). Both are the source's own art, unchanged.
- Not drawn in the Figma file: everything below the first three rows of the table above. Those screens follow the ASCII layouts and rules in DESIGN.md — treat the three fig-sourced screens as the fidelity benchmark and the rest as faithful extrapolation to review.
