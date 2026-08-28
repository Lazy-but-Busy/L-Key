import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// The bar every L Key screen starts with: leading control, wordmark, action.
///
/// The design system ships no logo file — the wordmark is always set in type,
/// Space Grotesk uppercase with tight tracking — so this renders [title] as
/// text rather than an asset.
class LkTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a top app bar.
  const LkTopAppBar({
    required this.title,
    super.key,
    this.leading,
    this.trailing,
    this.compact = false,
  });

  /// The already-localised wordmark or screen title.
  final String title;

  /// Optional leading control, such as back or menu.
  final Widget? leading;

  /// Optional trailing control, conventionally settings.
  final Widget? trailing;

  /// Uses the smaller wordmark step, for a pushed detail screen.
  final bool compact;

  @override
  Size get preferredSize => const Size.fromHeight(LkDimens.topBarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return SizedBox(
      height: LkDimens.topBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: LkSpacing.s6),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: LkDimens.tapTarget,
              child: Align(alignment: Alignment.centerLeft, child: leading),
            ),
            Expanded(
              child: Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact ? context.lkType.h2 : context.lkType.h1)
                    .copyWith(
                      color: colors.textPrimary,
                    ),
              ),
            ),
            SizedBox(
              width: LkDimens.tapTarget,
              child: Align(alignment: Alignment.centerRight, child: trailing),
            ),
          ],
        ),
      ),
    );
  }
}
