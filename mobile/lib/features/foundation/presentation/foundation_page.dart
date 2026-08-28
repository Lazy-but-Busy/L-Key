import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/config/feature_flags.dart';

/// Developer-only showcase of every design-token category.
///
/// This is not a product surface. It exists so the token pipeline can be
/// verified by eye in both themes and in both locales, and so new features
/// have one worked example of reading tokens through the theme rather than
/// importing the palette. Release builds exclude it via
/// `Environment.allowsDeveloperTools` at the routing layer.
class FoundationPage extends StatelessWidget {
  /// Creates the showcase.
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(LkDimens.screenPadding),
          children: <Widget>[
            Text(l10n.foundationTitle, style: text.headlineLarge),
            const SizedBox(height: LkSpacing.s1),
            Text(
              l10n.foundationSubtitle,
              style: text.labelMedium?.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: LkSpacing.s8),

            _Section(
              label: 'TYPOGRAPHY',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Display 48', style: text.displayMedium),
                  Text('Heading 32', style: text.headlineLarge),
                  Text('Heading 24', style: text.headlineMedium),
                  Text('Heading 20', style: text.headlineSmall),
                  Text('Body 16 — Hanken Grotesk', style: text.bodyMedium),
                  Text(
                    'TECHNICAL 14 — JETBRAINS MONO',
                    style: text.labelMedium,
                  ),
                ],
              ),
            ),

            // Proves Burmese shapes correctly through the Noto fallback.
            // Without it these lines render as tofu boxes (docs/adr/0006).
            _Section(
              label: 'MYANMAR + ENGLISH',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(l10n.foundationMyanmarSample, style: text.headlineSmall),
                  const SizedBox(height: LkSpacing.s1),
                  Text(l10n.appTagline, style: text.bodyMedium),
                ],
              ),
            ),

            _Section(
              label: 'SEMANTIC COLOUR',
              child: Wrap(
                spacing: LkSpacing.s2,
                runSpacing: LkSpacing.s2,
                children: <Widget>[
                  _Swatch('background', colors.background, colors),
                  _Swatch('surface', colors.surface, colors),
                  _Swatch('surfaceSunken', colors.surfaceSunken, colors),
                  _Swatch('accent', colors.accent, colors),
                  _Swatch('danger', colors.danger, colors),
                  _Swatch('success', colors.success, colors),
                ],
              ),
            ),

            _Section(
              label: 'SHADOW · BORDER · RADIUS',
              child: Row(
                children: <Widget>[
                  _ShadowBox('sm', LkShadows.sm(colors.border), colors),
                  const SizedBox(width: LkSpacing.s4),
                  _ShadowBox('4px', LkShadows.regular(colors.border), colors),
                  const SizedBox(width: LkSpacing.s4),
                  _ShadowBox('lg', LkShadows.lg(colors.border), colors),
                ],
              ),
            ),

            _Section(
              label: 'SPACING · 4PX SCALE',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                    <double>[
                          LkSpacing.s1,
                          LkSpacing.s2,
                          LkSpacing.s3,
                          LkSpacing.s4,
                          LkSpacing.s6,
                          LkSpacing.s8,
                        ]
                        .map(
                          (s) => Container(
                            width: s,
                            height: s,
                            margin: const EdgeInsets.only(right: LkSpacing.s2),
                            color: colors.accent,
                          ),
                        )
                        .toList(),
              ),
            ),

            _Section(
              label: 'MOTION · ${LkMotion.durationBase.inMilliseconds}MS',
              child: const _PressDemo(),
            ),

            _Section(
              label: 'FEATURE FLAGS',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: FeatureFlags.all.entries
                    .map(
                      (e) => Text(
                        '${e.key.padRight(20)} ${e.value ? "on" : "off"}',
                        style: text.labelMedium,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled block in the showcase.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: LkSpacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: LkSpacing.s1),
          Container(height: LkBorders.regular, color: colors.divider),
          const SizedBox(height: LkSpacing.s4),
          child,
        ],
      ),
    );
  }
}

/// A colour chip with its semantic name.
class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, this.colors);

  final String name;
  final Color color;
  final LkSemanticColors colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Colour role $name',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 72,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: colors.border,
                width: LkBorders.regular,
              ),
            ),
          ),
          const SizedBox(height: LkSpacing.s1),
          SizedBox(
            width: 72,
            child: Text(
              name,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// A box demonstrating one hard shadow step.
class _ShadowBox extends StatelessWidget {
  const _ShadowBox(this.label, this.shadow, this.colors);

  final String label;
  final BoxShadow shadow;
  final LkSemanticColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: LkBorders.regular),
        boxShadow: <BoxShadow>[shadow],
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

/// The tactile press from DESIGN.md §15: translate toward the shadow and
/// shrink it, over [LkMotion.durationFast].
class _PressDemo extends StatefulWidget {
  const _PressDemo();

  @override
  State<_PressDemo> createState() => _PressDemoState();
}

class _PressDemoState extends State<_PressDemo> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    const t = LkMotion.pressTranslate;

    return Semantics(
      button: true,
      label: 'Press demonstration',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: LkMotion.durationFast,
          curve: LkMotion.easing,
          transform: Matrix4.translationValues(
            _pressed ? t : 0,
            _pressed ? t : 0,
            0,
          ),
          constraints: const BoxConstraints(
            minWidth: LkDimens.tapTarget,
            minHeight: LkDimens.tapTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: LkSpacing.s6,
            vertical: LkSpacing.s3,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.accent,
            border: Border.all(color: colors.border, width: LkBorders.regular),
            boxShadow: <BoxShadow>[
              if (_pressed)
                LkShadows.pressed(colors.border)
              else
                LkShadows.regular(colors.border),
            ],
          ),
          child: Text(
            'PRESS',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: colors.accentOn),
          ),
        ),
      ),
    );
  }
}
