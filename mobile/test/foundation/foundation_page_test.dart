import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/foundation/presentation/foundation_page.dart';

Widget _host({required ThemeData theme, Locale locale = const Locale('en')}) {
  return MaterialApp(
    theme: theme,
    locale: locale,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const FoundationPage(),
  );
}

void main() {
  group('FoundationPage', () {
    testWidgets('renders in the light theme', (tester) async {
      await tester.pumpWidget(_host(theme: AppTheme.light));
      await tester.pumpAndSettle();

      expect(find.text('Foundation'), findsOneWidget);
      expect(find.text('TYPOGRAPHY'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in the dark theme', (tester) async {
      await tester.pumpWidget(_host(theme: AppTheme.dark));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, LkPalette.darkBackground);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Burmese through the Myanmar fallback', (tester) async {
      await tester.pumpWidget(
        _host(theme: AppTheme.light, locale: const Locale('my')),
      );
      await tester.pumpAndSettle();

      // The Myanmar title must be present...
      expect(find.text('အခြေခံ'), findsOneWidget);

      // ...and the style resolving it must offer a Burmese-capable face,
      // otherwise every glyph renders as a tofu box.
      final title = tester.widget<Text>(find.text('အခြေခံ'));
      final resolved =
          title.style ??
          DefaultTextStyle.of(tester.element(find.text('အခြေခံ'))).style;
      expect(
        resolved.fontFamilyFallback,
        contains(LkFonts.myanmar),
        reason: 'Burmese text has no Myanmar-capable font in its fallback',
      );
    });

    testWidgets('the press target meets the minimum tap size', (tester) async {
      await tester.pumpWidget(_host(theme: AppTheme.light));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('PRESS'), 200);
      final size = tester.getSize(
        find.ancestor(
          of: find.text('PRESS'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(size.height, greaterThanOrEqualTo(LkDimens.tapTarget));
      expect(size.width, greaterThanOrEqualTo(LkDimens.tapTarget));
    });
  });
}
