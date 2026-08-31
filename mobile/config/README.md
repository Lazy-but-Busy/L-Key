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

The `ADMOB_*` values in `local.json` are Google's own published test
identifiers (docs/adr/0018) — safe to commit, and they never serve a real ad
to a real user. `production.json`, and any build meant for a store listing,
must carry real AdMob unit ids instead — the same rule `API_BASE_URL` already
follows here, and the one CLAUDE.md §41 states for payment credentials.

Native iOS/Android build *flavours* are deliberately not configured yet; they
add signing and scheme plumbing that nothing needs until there is something to
release.
