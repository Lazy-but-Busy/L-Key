import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/core/errors/failure.dart';

/// The user-facing copy for a failure: a short headline and a next step.
typedef FailureMessage = ({String headline, String body});

/// Resolves a [Failure] into localised copy.
///
/// This is the only sanctioned way to put an error on screen. It reads the
/// sealed hierarchy rather than [Failure.messageKey] so that adding a failure
/// type is a compile error here instead of a silent fallback, and it never
/// touches [Failure.technicalDetail] — CLAUDE.md §37 keeps that in the logs.
FailureMessage failureMessage(AppLocalizations l10n, Failure failure) {
  return switch (failure) {
    NetworkFailure() => (
      headline: l10n.errorNoConnection,
      body: l10n.errorNoConnectionBody,
    ),
    ServerFailure() ||
    DecodingFailure() ||
    PermissionFailure() ||
    UnexpectedFailure() => (
      headline: l10n.errorUnexpected,
      body: l10n.errorUnexpectedBody,
    ),
  };
}
