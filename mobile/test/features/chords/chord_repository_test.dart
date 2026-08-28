import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/features/chords/data/local_chord_repository.dart';
import 'package:l_key/features/chords/domain/chord_audio.dart';
import 'package:l_key/features/chords/domain/chord_repository.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';

void main() {
  group('LocalChordRepository', () {
    const ChordRepository repository = LocalChordRepository();

    test('browses the whole catalogue offline', () async {
      // CLAUDE.md §19 — the chord library must not need a network.
      final entries = await repository.browse();
      expect(entries, isNotEmpty);
      expect(entries.first.chord.symbol, 'C');
    });

    test('returns a chord with its voicings', () async {
      final detail = await repository.detail('c-major');
      expect(detail, isNotNull);
      expect(detail!.chord.symbol, 'C');
      expect(detail.voicings, isNotEmpty);
      expect(detail.voicings.first.voicing.fretString, 'x32010');
    });

    test('an unknown id is a null, not an exception', () async {
      // The screen renders its empty state; nothing throws at the player.
      expect(await repository.detail('h-flat-wobble'), isNull);
      expect(await repository.detail(''), isNull);
    });

    test('the tier label is descriptive and never blocks anything', () async {
      // CLAUDE.md §23 — entitlement is the server's decision. The label here
      // says what a chord is, and the repository still hands over every note.
      final free = await repository.detail('c-major');
      final premium = await repository.detail('c-sharp-m7b5');

      expect(free!.entry.tier, FeatureTier.free);
      expect(premium!.entry.tier, FeatureTier.premium);
      expect(
        premium.voicings,
        isNotEmpty,
        reason: 'a Premium label must not withhold the chord',
      );
    });

    test('the first voicing is never labelled Premium', () async {
      // PRD.md §11 calls *alternative* voicings Premium, so the shape a player
      // opens the screen on is always plain.
      for (final id in <String>['c-sharp-m7b5', 'a-minor', 'g-major']) {
        final detail = await repository.detail(id);
        expect(detail!.voicings.first.tier, FeatureTier.free, reason: id);
      }
    });

    test('every catalogue entry resolves to a detail', () async {
      final entries = await repository.browse();
      for (final entry in entries) {
        final detail = await repository.detail(entry.id);
        expect(detail, isNotNull, reason: '${entry.id} does not resolve');
      }
    });
  });

  group('UnavailableChordAudioPlayer', () {
    const player = UnavailableChordAudioPlayer();
    const voicing = ChordVoicing(
      strings: <FrettedString>[
        FrettedString.muted(0),
        FrettedString.at(1, 3, finger: 3),
        FrettedString.at(2, 2, finger: 2),
        FrettedString.open(3),
        FrettedString.at(4, 1, finger: 1),
        FrettedString.open(5),
      ],
    );

    test('says plainly that it cannot play', () {
      // CLAUDE.md §47 — no fake playback. The screen reads isAvailable and
      // disables the control rather than pretending.
      expect(player.isAvailable, isFalse);
      expect(player.isPlaying, isFalse);
    });

    test('asked to play anyway, it throws rather than silently succeeding', () {
      expect(() => player.play(voicing), throwsUnsupportedError);
    });

    test('stopping nothing is harmless', () async {
      await expectLater(player.stop(), completes);
    });
  });
}
