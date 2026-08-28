# Build configuration

Values passed at build time with `--dart-define-from-file`. Nothing here is a
secret: everything in a dart-define is readable from a shipped binary
(CLAUDE.md §22), so this file only ever selects an environment and toggles
feature flags.

```sh
flutter run  --dart-define-from-file=config/local.json
flutter build apk --release --dart-define-from-file=config/production.json
```

`local.json` is committed as the working example. `dev.json`, `staging.json`
and `production.json` are git-ignored — create them from `local.json` and set
`API_BASE_URL` for the target environment.

Native iOS/Android build *flavours* are deliberately not configured yet; they
add signing and scheme plumbing that nothing needs until there is something to
release.
