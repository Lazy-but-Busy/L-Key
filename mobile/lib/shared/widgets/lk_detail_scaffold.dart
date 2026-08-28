import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_icon_button.dart';
import 'package:l_key/shared/widgets/lk_top_app_bar.dart';

/// The frame for a screen pushed above the shell.
///
/// Only `/settings` uses this. A screen pushed *inside* a branch keeps the
/// bottom bar and takes the full height instead, so it needs no frame of its
/// own — see [lkFullScreenPadding].
///
/// The design system's top bar carries a menu on the left; a screen above the
/// shell has no bottom bar to return through, so it needs a way back, and the
/// icon set contains no back glyph. This is a documented addition rather than
/// a substituted lookalike.
class LkDetailScaffold extends StatelessWidget {
  /// Creates a detail scaffold.
  const LkDetailScaffold({
    required this.title,
    required this.child,
    super.key,
    this.fallbackRoute,
  });

  /// The screen's name. Announced with the back control rather than painted
  /// in the bar, which carries the wordmark.
  final String title;

  /// Screen content. Scrolling is the caller's responsibility.
  final Widget child;

  /// Where to go when there is nothing to pop — which happens when the screen
  /// was opened by a cold deep link.
  final String? fallbackRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            LkTopAppBar(
              // The wordmark, not the screen name: the body already sets the
              // title as an H1, and the design system's bar always carries
              // the wordmark.
              title: l10n.appName,
              compact: true,
              leading: LkIconButton(
                icon: Icons.arrow_back,
                semanticLabel: l10n.commonBack,
                variant: LkIconButtonVariant.bare,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else if (fallbackRoute != null) {
                    context.go(fallbackRoute!);
                  }
                },
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Page padding for a screen sitting under the top bar, which already
/// provides the space above the content.
const EdgeInsets lkScreenPadding = EdgeInsets.fromLTRB(
  LkSpacing.s6,
  0,
  LkSpacing.s6,
  LkSpacing.s6,
);

/// Page padding for a full-screen surface, which has no bar above it and so
/// must open its own space.
const EdgeInsets lkFullScreenPadding = EdgeInsets.all(LkSpacing.s6);
