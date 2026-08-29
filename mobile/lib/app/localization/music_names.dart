/// The bridge from a stable domain identifier to display copy.
///
/// `core/music` names things with slugs — `drop-d`, `major-pentatonic` — and
/// knows nothing about a localisation file, because CLAUDE.md §10 keeps the
/// music engines free of Flutter. Every screen that shows one of those names
/// needs the same translation, so it lives here rather than in whichever
/// feature happened to need it first (CLAUDE.md §33).
library;

import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/core/music/tuning.dart';

/// The localised name of one tuning.
///
/// The domain has no access to a localisation file, so this is the bridge —
/// `Tuning.name` is a stable id, never display copy.
String tuningName(AppLocalizations l10n, Tuning tuning) =>
    switch (tuning.name) {
      'drop-d' => l10n.tuningDropD,
      'drop-c' => l10n.tuningDropC,
      'drop-b' => l10n.tuningDropB,
      'half-step-down' => l10n.tuningHalfStepDown,
      'full-step-down' => l10n.tuningFullStepDown,
      'dadgad' => l10n.tuningDadgad,
      'open-g' => l10n.tuningOpenG,
      'open-d' => l10n.tuningOpenD,
      'open-e' => l10n.tuningOpenE,
      'seven-string' => l10n.tuningSevenString,
      'eight-string' => l10n.tuningEightString,
      'bass-four' => l10n.tuningBassFour,
      'bass-five' => l10n.tuningBassFive,
      _ => l10n.tuningStandard,
    };
