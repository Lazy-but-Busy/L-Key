# L Key — mobile

The Flutter application for iOS and Android.

## Run

```sh
flutter pub get
flutter gen-l10n
flutter run --dart-define-from-file=config/local.json
```

## Validate

```sh
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Or `npm run mobile:verify` from the repository root, which runs all three.
That is exactly what CI runs.

## Layout

```
lib/
├── app/            root widget, router, shell, theme, localisation
├── core/           config, errors, audio interfaces, utilities
├── features/       one directory per feature, each with its own README
└── shared/widgets/ the reusable component library
```

`shared/widgets/` holds one visual definition per component. DESIGN.md §67
asks for the API to be extended rather than forked, so there is no
`PrimaryButton2`.

## Rules that bite

**Design values are generated.** Every colour, size, radius, shadow and
duration comes from `packages/design-tokens/tokens.json` via
`lib/app/theme/tokens.g.dart`. A literal in a widget is a bug, and the
generated file is checked for drift in CI — edit the JSON and run
`npm run tokens` from the root.

**Strings are localised, content is not.** UI copy lives in
`lib/app/localization/*.arb` and needs an English description and a real
Burmese translation in the same commit; a test enforces both. Song and course
titles are content, not copy — those live in the feature's `*_mock_data.dart`
until an API supplies them.

**Public members need doc comments.** `very_good_analysis` enforces it, and it
is the most common reason a first `flutter analyze` fails.

**Nothing is faked.** Where a screen has no engine behind it yet, it says so
on screen rather than simulating a measurement (CLAUDE.md §47).

## Localisation

`flutter gen-l10n` regenerates `lib/app/localization/generated/` from the ARB
files. The output is committed. Burmese has no glyphs in any of the three
brand faces, so Noto Sans Myanmar is bundled as a fallback on every text
style — see docs/adr/0006.
