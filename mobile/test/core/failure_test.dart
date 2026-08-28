import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/errors/failure.dart';

void main() {
  group('Failure', () {
    test('exposes a localisation key, never raw technical text', () {
      const f = NetworkFailure(technicalDetail: 'SocketException: refused');
      // CLAUDE.md §37 — the user sees the resolved key; the detail is log-only.
      expect(f.messageKey, 'errorNoConnection');
      expect(f.toString(), isNot(contains('SocketException')));
    });

    test('kind is stable and does not rely on runtimeType', () {
      expect(const NetworkFailure().kind, 'network');
      expect(const ServerFailure(statusCode: 500).kind, 'server');
      expect(const DecodingFailure().kind, 'decoding');
      expect(
        const PermissionFailure(permission: 'microphone').kind,
        'permission',
      );
      expect(const UnexpectedFailure().kind, 'unexpected');
    });

    test('the hierarchy is exhaustively switchable', () {
      const failures = <Failure>[
        NetworkFailure(),
        ServerFailure(statusCode: 503),
        DecodingFailure(),
        PermissionFailure(permission: 'microphone'),
        UnexpectedFailure(),
      ];
      for (final f in failures) {
        final label = switch (f) {
          NetworkFailure() => 'network',
          ServerFailure() => 'server',
          DecodingFailure() => 'decoding',
          PermissionFailure() => 'permission',
          UnexpectedFailure() => 'unexpected',
        };
        expect(label, f.kind);
      }
    });
  });
}
