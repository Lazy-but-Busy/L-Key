# @lkey/design-tokens

Every design value in L Key, in one file, generated into three targets.

```text
tokens.json  ──►  build.mjs  ──┬──►  mobile/lib/app/theme/tokens.g.dart
                               ├──►  dist/tokens.css     (admin, website)
                               └──►  dist/tokens.ts      (typed TS access)
```

## Commands

```sh
npm run tokens              # regenerate all three targets
npm run tokens:check        # fail if committed output has drifted

npm run tokens:check:web    # CSS + TS only; needs no `dart`
npm run tokens:check:dart   # tokens.g.dart only; requires `dart`
```

All run from the repository root. Use the plain commands day to day; the
scoped ones exist for CI, where the two halves need different toolchains —
see *Notes for maintainers*.

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
  This is why the drift check is split across two CI jobs: only the Flutter
  job has `dart`, so only it can reproduce `tokens.g.dart`. The Node job runs
  `tokens:check:web`. Running the unscoped check on a machine without `dart`
  is a hard error, not a fallback — emitting unformatted Dart would report
  drift that regenerating cannot clear.
- Generated Dart is analysed, not excluded. Excluding it once hid a real
  compile error.
