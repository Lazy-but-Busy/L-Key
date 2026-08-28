import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/core/errors/failure_messages.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';

/// The error state: something went wrong and there is a way forward.
///
/// DESIGN.md §38 wants this concise — a headline, one line of guidance, and a
/// retry. The message comes from [failureMessage], so the exception text can
/// never reach the screen (CLAUDE.md §37).
class LkErrorState extends StatelessWidget {
  /// Creates an error state for [failure].
  const LkErrorState({required this.failure, super.key, this.onRetry});

  /// What went wrong.
  final Failure failure;

  /// Re-runs the failed operation. Omitted when there is nothing to retry.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = failureMessage(l10n, failure);
    final retry = onRetry;

    return LkEmptyState(
      headline: message.headline,
      body: message.body,
      action: retry == null
          ? null
          : LkButton(
              label: l10n.commonRetry,
              onPressed: retry,
              size: LkButtonSize.medium,
              variant: LkButtonVariant.secondary,
            ),
    );
  }
}
