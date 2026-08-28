import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keys in an ARB file, excluding `@`-prefixed metadata.
Set<String> _keys(File f) {
  final map = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  return map.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  final en = File('lib/app/localization/app_en.arb');
  final my = File('lib/app/localization/app_my.arb');

  group('localisation', () {
    test('both ARB files exist', () {
      expect(en.existsSync(), isTrue);
      expect(my.existsSync(), isTrue);
    });

    test('Myanmar defines every English key', () {
      // CLAUDE.md §33 — a missing translation must fail the build rather than
      // silently ship an English string into a Myanmar-first product.
      final missing = _keys(en).difference(_keys(my));
      expect(
        missing,
        isEmpty,
        reason: 'app_my.arb is missing: ${missing.join(", ")}',
      );
    });

    test('Myanmar defines no keys English lacks', () {
      final extra = _keys(my).difference(_keys(en));
      expect(
        extra,
        isEmpty,
        reason: 'app_my.arb has orphaned keys: ${extra.join(", ")}',
      );
    });

    test('every English string carries a description', () {
      final map = jsonDecode(en.readAsStringSync()) as Map<String, dynamic>;
      for (final key in map.keys.where((k) => !k.startsWith('@'))) {
        final meta = map['@$key'];
        expect(
          meta,
          isNotNull,
          reason: '"$key" has no @$key metadata for translators',
        );
        expect((meta! as Map)['description'], isNotEmpty);
      }
    });

    test('Myanmar strings actually contain Burmese script', () {
      // Guards against a placeholder copy-paste of the English file.
      final map = jsonDecode(my.readAsStringSync()) as Map<String, dynamic>;
      final burmese = RegExp('[က-႟]');
      final translated = map.entries
          .where((e) => !e.key.startsWith('@') && e.key != 'appName')
          .where((e) => burmese.hasMatch(e.value.toString()));
      expect(
        translated.length,
        greaterThan(5),
        reason: 'app_my.arb looks untranslated',
      );
    });
  });
}
