import 'package:flutter/material.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// Locale-aware access to the generated type scale.
///
/// DESIGN.md §36 requires Burmese font size and line wrapping to be tested
/// rather than assumed. The Latin scale runs as tight as 0.95, which clips the
/// diacritics Burmese stacks above and below the baseline, so every style
/// takes a taller line box when the resolved locale is Burmese. Nothing else
/// changes: same family, size, weight and tracking.
///
/// Read it through `context.lkType`, the same way colours are read through
/// `context.lkColors`. Reaching for [LkTypeScale] directly in a widget skips
/// this and will clip Burmese.
@immutable
class LkTypeStyles {
  const LkTypeStyles._({required this.isMyanmar});

  /// Resolves the styles for the locale in scope.
  factory LkTypeStyles.of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return LkTypeStyles._(isMyanmar: locale?.languageCode == 'my');
  }

  /// Whether the taller Burmese line box is in effect.
  final bool isMyanmar;

  TextStyle _resolve(TextStyle style) {
    if (!isMyanmar) return style;
    final height = style.height ?? 1;
    return height >= LkFonts.myanmarLineHeight
        ? style
        : style.copyWith(height: LkFonts.myanmarLineHeight);
  }

  /// The single largest step, for the tuner's detected note (DESIGN.md §21).
  TextStyle get hero => _resolve(LkTypeScale.hero);

  /// The largest display step.
  TextStyle get displayXl => _resolve(LkTypeScale.displayXl);

  /// Display.
  TextStyle get display => _resolve(LkTypeScale.display);

  /// Screen titles.
  TextStyle get h1 => _resolve(LkTypeScale.h1);

  /// Card and section titles.
  TextStyle get h2 => _resolve(LkTypeScale.h2);

  /// Sub-headings.
  TextStyle get h3 => _resolve(LkTypeScale.h3);

  /// Row titles and the default button label.
  TextStyle get h4 => _resolve(LkTypeScale.h4);

  /// Lead body copy.
  TextStyle get bodyLarge => _resolve(LkTypeScale.bodyLarge);

  /// Body copy.
  TextStyle get body => _resolve(LkTypeScale.body);

  /// Small body copy.
  TextStyle get bodySmall => _resolve(LkTypeScale.bodySmall);

  /// Uppercase technical captions.
  TextStyle get label => _resolve(LkTypeScale.label);

  /// Large technical values.
  TextStyle get technicalLg => _resolve(LkTypeScale.technicalLg);

  /// Technical values.
  TextStyle get technical => _resolve(LkTypeScale.technical);

  /// Small technical values.
  TextStyle get technicalSm => _resolve(LkTypeScale.technicalSm);
}

/// Convenience access to the locale-aware type scale.
extension LkTypeContext on BuildContext {
  /// The type styles for the locale in scope.
  LkTypeStyles get lkType => LkTypeStyles.of(this);
}
