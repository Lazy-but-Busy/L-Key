# @lkey/design-tokens

Every design value in L Key, in one file, generated into three targets.

```text
tokens.json  ──►  build.mjs  ──┬──►  mobile/lib/app/theme/tokens.g.dart
                               ├──►  dist/tokens.css     (admin, website)
                               └──►  dist/tokens.ts      (typed TS access)
```

## Commands

```sh
npm run tokens         # regenerate all three targets
npm run tokens:check   # fail if committed output has drifted
```

Both run from the repository root.

## Changing a token

1. Edit `tokens.json`. Nothing else.
2. Run `npm run tokens`.
3. Commit `tokens.json` and every generated file together.

Never edit a generated file. `tokens:check` runs in CI and will fail.

## Categories

`color` · `typography` · `spacing` · `border` · `radius` · `shadow` ·
`animation` · `dimension`, plus a `semantic` layer and `contrastPairs`.

Every entry carries a `source` field citing the DESIGN.md section it comes
from, or stating explicitly that DESIGN.md is silent and where the value came
from instead. If you cannot write that field honestly, the value probably
should not be added.

## Use the semantic layer

Feature code reads semantic roles, never the raw ramp.

```dart
// Flutter
final colors = context.lkColors;
Container(color: colors.surface);
```

```css
/* Web */
background: var(--lk-surface);
```

`LkPalette` and `--lk-color-*` exist so new semantic roles can be defined.
They are not for widgets.

## The contrast gate

`build.mjs` measures every pair in `contrastPairs` across both themes and
**fails the build** below its threshold. This is not advisory and the
threshold is not to be lowered — if a pair fails, change the semantic mapping.

It has already earned its place. It rejected `grey400` as tertiary text
(3.11:1), caught Guitar Orange at 2.92:1 on the `#F0F0F0` ground, and caught
the light danger red at 2.92:1 on the dark surface.

## Notes for maintainers

- `letterSpacing` is stored in **em** and resolved to logical pixels for Dart,
  which needs an absolute value. `lineHeight` is a unitless multiplier.
- The generator runs `dart format` on its Dart output so the committed file
  satisfies both the drift check and `dart format --set-exit-if-changed`.
- Generated Dart is analysed, not excluded. Excluding it once hid a real
  compile error.
