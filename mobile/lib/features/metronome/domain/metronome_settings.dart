/// What the metronome has been asked to play.
///
/// Contains no Flutter and reads no clock. See docs/adr/0016.
library;

import 'package:l_key/features/metronome/domain/click_sound.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';
import 'package:meta/meta.dart';

/// A tempo, a meter, and everything else the player has chosen.
///
/// **It cannot hold a tempo the metronome will not play.** Every constructor
/// and every `with…` clamps, and an accent pattern that does not match the
/// meter is replaced rather than carried, because these values arrive from a
/// preferences file as often as from a button and a preferences file is not a
/// trusted input.
@immutable
final class MetronomeSettings {
  /// Creates a settings value, clamping and repairing as needed.
  factory MetronomeSettings({
    int bpm = defaultBpm,
    TimeSignature signature = TimeSignature.fourFour,
    Subdivision subdivision = Subdivision.none,
    List<AccentLevel>? accents,
    ClickSound sound = ClickSound.woodblock,
    CountIn countIn = CountIn.none,
    bool hapticsEnabled = false,
  }) => MetronomeSettings._(
    bpm.clamp(minimumBpm, maximumBpm),
    signature,
    subdivision,
    List<AccentLevel>.unmodifiable(_repair(accents, signature)),
    sound,
    countIn,
    hapticsEnabled: hapticsEnabled,
  );

  const MetronomeSettings._(
    this.bpm,
    this.signature,
    this.subdivision,
    this.accents,
    this.sound,
    this.countIn, {
    required this.hapticsEnabled,
  });

  /// The slowest tempo the metronome will play.
  ///
  /// Two seconds a beat. Slower than a Maelzel metronome's 40 because a
  /// player practising a slow passage in subdivisions genuinely wants it.
  static const int minimumBpm = 30;

  /// The fastest tempo the metronome will play.
  ///
  /// At 240 with sixteenths the click is already sixteen pulses a second,
  /// which is the point where a metronome stops being countable.
  static const int maximumBpm = 240;

  /// Where the screen starts.
  static const int defaultBpm = 120;

  /// Beats per minute, counting the note value in [signature]'s denominator.
  final int bpm;

  /// The meter.
  final TimeSignature signature;

  /// How each beat is divided.
  final Subdivision subdivision;

  /// One emphasis level per beat of the bar. Always [TimeSignature.beats] long.
  final List<AccentLevel> accents;

  /// Which click voice sounds.
  final ClickSound sound;

  /// How many bars are counted before the first bar proper.
  final CountIn countIn;

  /// Whether a beat also buzzes.
  ///
  /// Off by default: the click is already the signal, and a haptic motor
  /// running for a whole practice session is a real battery cost
  /// (mobile CLAUDE.md §50, DESIGN.md §40).
  final bool hapticsEnabled;

  /// How many pulses one bar holds.
  int get pulsesPerBar => signature.pulsesPerBar(subdivision);

  /// The emphasis of [pulse], counted from the start of a bar.
  ///
  /// A silenced beat silences its subdivisions with it — a muted beat that
  /// still ticked twice would not be muted.
  AccentLevel accentAt(int pulse) {
    final within = pulse % pulsesPerBar;
    final beat = within ~/ subdivision.pulsesPerBeat;
    final level = accents[beat];
    if (level == AccentLevel.silent) return AccentLevel.silent;
    return within % subdivision.pulsesPerBeat == 0
        ? level
        : AccentLevel.subdivision;
  }

  /// A copy with a different tempo, clamped.
  MetronomeSettings withBpm(int value) => copyWith(bpm: value);

  /// A copy with whatever is supplied replaced.
  ///
  /// Changing [signature] discards an accent pattern that no longer fits,
  /// because a five-beat pattern in a bar of three is not a preference, it is
  /// a crash waiting to be indexed.
  MetronomeSettings copyWith({
    int? bpm,
    TimeSignature? signature,
    Subdivision? subdivision,
    List<AccentLevel>? accents,
    ClickSound? sound,
    CountIn? countIn,
    bool? hapticsEnabled,
  }) {
    final nextSignature = signature ?? this.signature;
    return MetronomeSettings(
      bpm: bpm ?? this.bpm,
      signature: nextSignature,
      subdivision: subdivision ?? this.subdivision,
      accents:
          accents ?? (nextSignature == this.signature ? this.accents : null),
      sound: sound ?? this.sound,
      countIn: countIn ?? this.countIn,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  /// A copy with the emphasis of one beat replaced.
  MetronomeSettings withAccentAt(int beat, AccentLevel level) {
    if (beat < 0 || beat >= accents.length) return this;
    final next = List<AccentLevel>.of(accents)..[beat] = level;
    return copyWith(accents: next);
  }

  static List<AccentLevel> _repair(
    List<AccentLevel>? accents,
    TimeSignature signature,
  ) {
    if (accents == null || accents.length != signature.beats) {
      return signature.defaultAccents;
    }
    // A subdivision level on a beat is not a beat's emphasis; it is what the
    // pulses between beats get, and storing it here would make `accentAt`
    // return it for a downbeat.
    return <AccentLevel>[
      for (final level in accents)
        if (level == AccentLevel.subdivision) AccentLevel.normal else level,
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is MetronomeSettings &&
      other.bpm == bpm &&
      other.signature == signature &&
      other.subdivision == subdivision &&
      other.sound == sound &&
      other.countIn == countIn &&
      other.hapticsEnabled == hapticsEnabled &&
      _sameAccents(other.accents, accents);

  @override
  int get hashCode => Object.hash(
    bpm,
    signature,
    subdivision,
    sound,
    countIn,
    hapticsEnabled,
    Object.hashAll(accents),
  );

  static bool _sameAccents(List<AccentLevel> a, List<AccentLevel> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'MetronomeSettings($bpm BPM, ${signature.label}, ${subdivision.name})';
}
