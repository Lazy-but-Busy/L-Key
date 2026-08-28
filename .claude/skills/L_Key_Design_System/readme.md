# L Key — Design System

> **Everything Your Guitar Needs.** Tune. Learn. Practice. Play.

L Key is a **Myanmar-first guitar companion app for iOS and Android**, built in Flutter. It brings tuner, chords, fretboard, scales, metronome, trainers, songs, theory, practice tracking and AI assistance into one focused mobile tool, for players from their first three chords to advanced improvisers. Around the app sit two Next.js surfaces: an **Admin Portal** (content, users, payments) and a **landing website** (marketing and SEO). Payment is designed around **MyanMyanPay + MMQR** for local wallets (KBZPay, AYA Pay, WavePay, CB Pay).

The product's stated feel: *a precision musical instrument designed by a modern software company* — confident, musical, technical, tactile, focused, playful, approachable; **premium without being luxurious**. Its visual balance is deliberately weighted **70% minimal/precise · 20% neo-brutalist/raw · 10% playful/musical**.

## Products represented

| Surface | Tech | In this system |
| --- | --- | --- |
| Mobile app (iOS + Android) | Flutter | `ui_kits/mobile_app/` — Home, Chord detail, Song viewer |
| Admin Portal | Next.js | `ui_kits/admin_portal/` — Dashboard, Song database |
| Landing website | Next.js | `ui_kits/website/` — Hero + bento feature grid |
| Backend | REST + PostgreSQL | not a design surface |

## Sources used

- **Figma file:** `L Key UIs.fig` (mounted virtual filesystem, page `Page-1`, six top-level frames: `Html → Body` nodes `1:2`, `1:136`, `1:299`, `2:2`, `2:207`, `2:365`). The file defines **no Figma component sets, no Variable collections and no text styles** — it is six flat HTML-export frames. Every numeric value in `tokens/` marked "(fig)" was transcribed from those frames.
- **GitHub repository:** <https://github.com/Lazy-but-Busy/L-Key> (branch `main`). It currently holds documentation only — `README.md`, `PRD.md`, `DESIGN.md`, `CLAUDE.md`. **Read these repositories directly if you have access**; `DESIGN.md` in particular is the authoritative brand spec and is far more detailed than this summary. No Flutter/Next.js implementation code exists upstream yet, so nothing was recreated from code.
- **Attached codebase:** `L-Key/` (same four documents, read locally).
- **Fonts:** Space Grotesk, Hanken Grotesk and JetBrains Mono TTFs supplied by the brand owner and copied into `assets/fonts/`. **No substitution was needed.**
- See `github.md` for the sync record and screen map.

---

## CONTENT FUNDAMENTALS

**Register.** Terse, technical, a little dry. Copy reads like an instrument's panel legend, not like marketing. Sentences are short and often verbless: `Manage library, metadata, and publication status.` `Complex polyrhythms made simple.` `Studio-grade accuracy in your pocket.`

**Casing.** Three distinct casings carry meaning:
- **UPPERCASE** — screen titles, section headers, buttons, technical labels, statuses: `SONG DATABASE`, `RECENT RIFFS`, `STANDARD E`, `FOCUS: PENTATONIC SPEED`, `AUTO-SCROLL`, `DOWNLOAD APP`.
- **Sentence case** — descriptions, lyrics, lesson prose, admin field labels: `Waking up to the sound of the rain falling down`.
- **Title Case** — component-level names inside cards: `Quick Tune`, `Daily Session`, `Play Chord`, `Import Tab`.

**Person.** Second person, sparingly. The app addresses the player (`Track your progress`, `Your first questionable solo belongs here`) but never says "we". Greetings are personal without being chummy: `Good Morning,` / `GUITARIST!`.

**Numbers are content.** Musical facts are always exact and always monospaced: `82.41 Hz`, `-02 cents`, `120 BPM`, `2nd Fret`, `1 3 5`, `Capo: 2 · Play: C · Sounds: D`, `25,000 MMK`. Never round them for looks and never let a number sit in a proportional face.

**Bracket and bullet habits.** Song structure uses square brackets — `[INTRO]`, `[VERSE 1]`, `[CHORUS]`. Marketing eyebrows do too — `[ TUNE . LEARN . PRACTICE . PLAY ]`. Meta rows join with a bullet: `METALLICA • RHYTHM`. Feature lists in the paywall use a check character, `✓ Advanced tuner`.

**Humour** is allowed only in empty states, and only once: `NO RECORDINGS YET. / Your first questionable solo belongs here.` Errors get no jokes: `COULDN'T LOAD SONGS. / Check your connection and try again.`

**Honesty rules.** Never claim a payment succeeded before the backend confirms it (`WAITING FOR PAYMENT` → `PAYMENT COMPLETE`). Never invent a practice measurement. Premium copy promises capability — *More power.* — never luxury.

**Emoji.** Not used in the product UI. (`README.md` in the repo uses them as documentation section markers; that is repo prose, not interface copy.) Unicode symbols do appear as functional glyphs: `✓`, `•`, `<`/`>` in pagination, `⭐` beside a plan name in the paywall spec.

**Myanmar language.** Myanmar is a first-class language, not a translation layer. Myanmar text gets equal design consideration — test font size, line wrapping, button height, nav labels, long song titles and mixed Myanmar + English. Never translate English and assume the layout still works.

---

## VISUAL FOUNDATIONS

**Colour.** Monochrome foundation, one accent. Black `#000000` ink, off-white paper (`#F0F0F0` in the spec; the Figma frames actually paint `#F9F9F9`, and the admin canvas `#F3F3F3` — both are tokenised), white cards, and **Guitar Orange `#FF4D00`**. Orange is a semantic, not a decoration: active, playable, important, selected, recording, premium, progress, in-tune. One orange element per group, maximum. Six greys (`#E5E5E5 → #333333`) plus the exact surface tints the file uses (`#E8E8E8` table head, `#EEEEEE` tag, `#E2E2E2` bento chip). Semantics: danger `#BA1A1A` (muted strings, delete, failed), success `#28A745` on `#E6FFED` (published). Dark mode is a separate palette, not an inversion: `#000` ground, `#111`/`#1C1C1C` surfaces, `#F0F0F0` type *and borders*, same orange.

**Type.** Three families, three jobs, no exceptions. **Space Grotesk** for display — screen titles, chord names, tuner notes, BPM, big numbers, hero headlines. **Hanken Grotesk** for body — descriptions, lessons, lyrics, settings, admin field labels. **JetBrains Mono** for everything technical — Hz, cents, BPM, capo, fret numbers, timestamps, metadata, statuses, table cells, nav captions. Display sizes run 96 / 48 / 36 / 24 / 20 / 18 with tight negative tracking that grows with size (-4.8 at 96, -2.4 or -0.96 at 48, -1.8 at 36, -1.2 at 24). Mono runs 20 / 16 / 14 / 12 / 10 with *positive* tracking on uppercase labels (+0.7), formulas (+1.4) and eyebrows (+2).

**Spacing.** A 4px scale: 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64 · 80. Mobile screen padding is 16px per spec; the Figma frames use 24px gutters on app screens and 16px in the song viewer. Admin canvas padding is 32px; sidebar 320px; bottom tab bar 71px; mobile frame 390px; desktop frame 1280px with a 1232px content grid.

**Backgrounds.** Flat colour, full stop. No photographic backgrounds, no textures, no repeating patterns. Exactly **one gradient exists in the whole system** — a 10%-opacity radial dot on the website hero — and one hatch: 45° black stripes at 20% over an orange progress fill. Nothing else gradients, ever. Bento cards sit directly on paper with hard shadows.

**Borders.** 2px solid black is the primary border; 3px for especially important interactive components; 1px hairlines for table grids. In the Figma frames borders are drawn as `inset 0 0 0 2px #000` box-shadows so the ring never changes the box size — the `--lk-ring*` tokens preserve that technique. Dark mode borders are `#F0F0F0`.

**Corner radii.** **0px is the default and the design language.** 4px and 8px are allowed as deliberate variations; a 2px radius appears on one small icon hit-area. Full pills (`9999px`) are reserved for genuinely circular objects: the play button, avatars, beat dots, finger markers, stat-card ornaments. Cards are never rounded.

**Shadows.** Hard offset, zero blur, pure black: `2px 2px 0` for small components, `4px 4px 0` as the default, `6px 6px 0` for large interactive surfaces. One inversion exists: the admin logout button is black with a `4px 4px 0 #FF4D00` orange shadow. Blurred shadows are never the primary language — there is no elevation system, no ambient shade, no glow.

**Cards.** White (or paper) rectangles, no radius. Mobile cards carry the 4px shadow alone; admin and song-viewer cards carry a 2px inset ring **plus** the 4px shadow. Padding 24px on mobile, 32px on desktop feature cards. Structure per DESIGN.md §17: category → title → metadata → action.

**Hover and press.** Press is the real state and it is physical: translate 3px toward the shadow and drop the shadow to `1px 1px 0`. Hover is restrained — no lift, no scale, no colour wash; links move from black to Guitar Orange. Disabled is 40% opacity, never a grey re-tint.

**Motion.** Short, functional, tactile, predictable: ~90–140ms with a decisive ease (`cubic-bezier(0.2,0,0,1)`). Motion communicates state, progress and interaction — needle movement, beat pulse, press. No decorative animation, no bounce, no parallax, no infinite spinners where a meaningful state exists (prefer skeletons; for audio, a waveform + `LISTENING...`). Haptics for tuner lock, metronome beat, press, successful action, trainer answer — used sparingly.

**Transparency and blur.** Almost none. Glassmorphism is explicitly banned. The only transparencies in the file: a 10% black scrim over song artwork, a ~0.2% white plate behind chord chips over lyrics (so the 2px shadow reads), 20% on the progress hatch, 50% on decorative stat-card ornaments, 10% on the hero gradient. `backdrop-filter` is never used.

**Imagery.** Close guitar detail, hands playing, fretboard photography, abstract instrument texture — monochrome-leaning, warm-neutral, no generic stock. Images support the product rather than dominate it, sit at 128px tall in song cards, always under a 10% black scrim, often with an orange badge over them. Two real photographs and one avatar are shipped in `assets/images/`.

**Layout rules.** Fixed elements: the mobile bottom tab bar (71px, always visible), the song viewer's persistent bottom controls (transpose / auto-scroll — performance controls must never be a navigation away), and the admin sidebar rail. Content is capped (896px on mobile main areas, 1232–1280px on desktop). Grids are explicit: the marketing bento is 12 columns with 8/4/6/6 spans; the admin dashboard is 3 columns with a 2-column chart. Do not hardcode screen dimensions — the app must work from small phones to tablets.

**Charts.** Minimal and blocky. The dashboard's "user growth" is deliberately **bars, not a line** — the source frame calls it a "Neo-Brutalist alternative to line" — black bars with 2px rings, one orange bar, a black tooltip. No axes chrome beyond three mono y-labels.

---

## ICONOGRAPHY

- **Style:** simple geometric line/solid icons drawn on a small pixel grid, single colour (black; white on black; orange only when the icon *is* the accent). Icons never compete with typography and are never decorative. Sizes in use: 4×16 (overflow dots), 16×4 (ellipsis), 9.3, 11×14 (play), 13.3, 14, 15, 16×18 (home), 17.5, 18, 20.1, 22×16, 25, 27, 27.5.
- **Source:** there is **no icon font and no sprite sheet**. The Figma frames carry icons two ways: as extracted `.svg` files and as inline vector paths. Both were copied verbatim into this system — 18 SVGs in `assets/icons/`, and the inline paths (hamburger, play, plus, minus, arrow-right, tune sliders, home, download, logout, trend) copied literally into the UI-kit screens and `AppSectionHeader`. Nothing was redrawn or approximated.
- **Naming:** each file is named for **what it actually draws**, read from its path data — not for where the frame happened to use it. That matters, because the source reuses glyphs loosely: the BPM chip in the song viewer really is a *heart*, and the same stacked-cards-plus-note mark appears at two sizes.
- **Available SVGs (18):** `settings`, `settings-alt` (a second gear), `search`, `edit`, `trash`, `download`, `users`, `dashboard`, `library-music` (stacked cards + music note, 20px), `library-music-lg` (same mark, 25px), `graduation-cap`, `stack-pin` (stacked cards + map pin), `heart`, `add-circle` (plus in a circle), `history-clock` (clock with a reset arrow), `more-vertical`, `more-vertical-alt`, `more-horizontal`.
- **Glyphs the file does not contain:** there is **no** star, no metronome, no chord grid, no fretboard, no tuner, no database, no calendar, no plain arrow icon. Do not substitute a lookalike — either use one of the 18 above or leave the slot to type.
- **Assignments made (documented, not sourced):** the source frame reuses one icon instance for all five bottom tabs and all five admin sidebar rows, so only `Home` and `Dashboard` have distinct art. Everything else was assigned from real file glyphs — mobile tabs `Tools → settings-alt`, `Learn → graduation-cap`, `Songs → library-music`, `Profile → users`; admin rows `Songs → library-music`, `Chords → stack-pin`, `Payments → history-clock`. Replace these the moment the Flutter/Next.js builds have real art.
- **Emoji:** never in the interface. Unicode symbols are used functionally: `✓` in feature lists, `•` in meta rows, `<` `>` in pagination, `▶` only where a real play SVG is unavailable.
- **Brand mark:** **the source contains no logo file.** The wordmark is always set in type — Space Grotesk, uppercase, `L KEY`, with size-matched negative tracking (48/-2.4 admin rail, 36/-1.8 app bar, 24/-1.2 compact, 16/-0.8 web header). Do not draw, reconstruct or generate a logo; render the words.

---

## Index

| Path | What it is |
| --- | --- |
| `styles.css` | Global entry point — `@import`s only. Link this one file. |
| `tokens/fonts.css` | `@font-face` for all three families (19 weights). |
| `tokens/colors.css` | Base colour ramp + exact Figma surface tints. |
| `tokens/typography.css` | Families, weights, and every size / line-height / tracking step. |
| `tokens/spacing.css` | 4px scale + real layout constants. |
| `tokens/borders.css` | Border widths, radii, hard-shadow and ring tokens, press timing, hatch. |
| `tokens/semantic.css` | Semantic aliases + the `[data-theme="dark"]` scope. |
| `tokens/utilities.css` | Optional type/surface classes and link colours. |
| `assets/fonts/` | 19 brand TTFs. |
| `assets/icons/` | 18 SVGs extracted from the Figma file. |
| `assets/images/` | 2 song photographs + 1 avatar, copied verbatim. |
| `guidelines/*.card.html` | 20 foundation specimen cards (Colors, Type, Spacing, Brand). |
| `components/` | 24 React primitives, grouped below. |
| `ui_kits/mobile_app/` | 13 screens: Home · Chord · Song viewer (fig-sourced) + tuner, tools, metronome, scales, songs, learn, practice, profile, paywall, payment (spec-derived), click-through. |
| `ui_kits/admin_portal/` | 8 screens: Dashboard · Song database (fig-sourced) + song editor, chords, users, payments, premium plans, analytics (spec-derived), click-through. |
| `ui_kits/website/` | Landing page. |
| `thumbnail.html` | Homepage tile. |
| `github.md` | Source repository association + screen map. |
| `SKILL.md` | Agent-Skills front matter for use in Claude Code. |

### Components

Import from the compiled bundle: `const { AppButton } = window.LKeyDesignSystem_355d7c`.

**`components/core/`** — `AppButton`, `AppIconButton`, `AppTextField`, `AppChip`, `AppCard`, `AppSectionHeader`, `PremiumBadge`

**`components/music/`** — `ChordDiagram`, `Fretboard`, `TunerMeter`, `BpmDisplay`, `PracticeProgress`, `SongCard`

**`components/navigation/`** — `TopAppBar`, `BottomNavBar`, `AdminSidebar`, `AdminHeader`

**`components/admin/`** — `StatCard`, `DataTable`, `FilterBar`, `StatusBadge`, `ContentEditor`

**`components/feedback/`** — `EmptyState`, `ConfirmDialog`

This inventory is exactly the component list `DESIGN.md` §65 defines (13 mobile + 9 admin), with each component's `.prompt.md` giving usage and variants.

### Intentional additions

Two components are not named in DESIGN.md §65 but appear in every Figma frame, so they were authored rather than inlined per screen:

- **`TopAppBar`** — the menu / wordmark / settings header present on all four mobile-width frames.
- **`BottomNavBar`** — the 71px five-tab bar specified in DESIGN.md §19 ("compact bottom navigation") and drawn in every app frame.

Nothing else was invented: no Toast, Avatar, Tabs, Tooltip, Accordion or Select exists here, because the source defines none.

### Known gaps and caveats

- The Figma file contains **no component sets, no Variables and no text styles** (`METADATA.md` lists 0 of each). The token set is therefore assembled from DESIGN.md's written spec plus values read off the six frames — it is complete against those sources, but it is not a Figma Variables export.
- **Dark mode is unverified visually.** DESIGN.md §6 gives the palette; no dark frame was drawn. The `[data-theme="dark"]` scope implements the spec but no screen was designed against it.
- **Spec-derived screens are now built and marked.** The Figma file draws only six frames; every other mobile and admin screen (tuner, tools, metronome, scales, song library, learn, practice, profile, paywall, MMQR payment; admin song editor, chords, users, payments, premium plans, analytics) was built from DESIGN.md's written layouts and is labelled *spec-derived* in each kit's README — treat the six fig-sourced screens as the fidelity benchmark. Marketing pages beyond the landing hero remain unbuilt.
- **Pricing:** only Yearly 25,000 MMK appears in the sources. Monthly 2,500 / 3 Months 7,000 / Lifetime 60,000 MMK are placeholders awaiting real pricing.
- **Myanmar script is not rendered anywhere** in this system: the Figma file contains no Myanmar text and no Myanmar-capable font was supplied. Myanmar line-height and wrapping behaviour still needs testing with a real Myanmar font.
- The `#F0F0F0` / `#F9F9F9` background discrepancy between DESIGN.md and the Figma frames is preserved rather than resolved — both are tokenised (`--lk-off-white`, `--lk-paper`) and `--lk-bg` currently points at the value the frames actually use.
