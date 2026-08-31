/// Where the metronome's choices live between launches.
library;

import 'package:l_key/features/metronome/domain/click_sound.dart';
import 'package:l_key/features/metronome/domain/metronome_settings.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes `MetronomeSettings` through `shared_preferences`.
///
/// Its own store rather than fields on `Settings`, which the theme, the locale
/// and the tuner all watch: a tempo nudge should not rebuild any of them.
///
/// The discipline is `SettingsController`s. Dotted keys, writes are
/// fire-and-forget so the interface never waits on disk, and **everything is
/// validated on the way in** — a preferences file is not a trusted input, and
/// an unrecognised or impossible value falls back to the default rather than
/// throwing (docs/adr/0008).
final class MetronomeSettingsStore {
  /// Creates a store over the supplied preferences.
  const MetronomeSettingsStore(this._preferences);

  static const String _bpmKey = 'metronome.bpm';
  static const String _beatsKey = 'metronome.beats';
  static const String _unitKey = 'metronome.unit';
  static const String _subdivisionKey = 'metronome.subdivision';
  static const String _soundKey = 'metronome.sound';
  static const String _countInKey = 'metronome.countIn';
  static const String _hapticsKey = 'metronome.haptics';
  static const String _accentsKey = 'metronome.accents';

  final SharedPreferences _preferences;

  /// What was last chosen, repaired where it no longer makes sense.
  MetronomeSettings read() {
    final signature = _readSignature();
    return MetronomeSettings(
      bpm: _preferences.getInt(_bpmKey) ?? MetronomeSettings.defaultBpm,
      signature: signature,
      subdivision: _readEnum(
        _subdivisionKey,
        Subdivision.values,
        Subdivision.none,
      ),
      accents: _readAccents(signature),
      sound: _readEnum(_soundKey, ClickSound.values, ClickSound.woodblock),
      countIn: _readEnum(_countInKey, CountIn.values, CountIn.none),
      hapticsEnabled: _preferences.getBool(_hapticsKey) ?? false,
    );
  }

  /// Records [settings], without waiting for the disk.
  void write(MetronomeSettings settings) {
    _preferences
      ..setInt(_bpmKey, settings.bpm).ignore()
      ..setInt(_beatsKey, settings.signature.beats).ignore()
      ..setInt(_unitKey, settings.signature.unit).ignore()
      ..setString(_subdivisionKey, settings.subdivision.name).ignore()
      ..setString(_soundKey, settings.sound.name).ignore()
      ..setString(_countInKey, settings.countIn.name).ignore()
      ..setBool(_hapticsKey, settings.hapticsEnabled).ignore()
      ..setString(
        _accentsKey,
        settings.accents.map((level) => level.index).join(','),
      ).ignore();
  }

  TimeSignature _readSignature() {
    final beats = _preferences.getInt(_beatsKey);
    final unit = _preferences.getInt(_unitKey);
    if (beats == null || unit == null) return TimeSignature.fourFour;
    // Written by a future build, or corrupted. A meter nothing can play is
    // not a preference worth honouring.
    return TimeSignature.tryOf(beats, unit) ?? TimeSignature.fourFour;
  }

  /// The stored pattern, or null when it does not fit the meter.
  ///
  /// Returning null hands the repair to [MetronomeSettings], which already
  /// owns the rule, rather than duplicating it here.
  List<AccentLevel>? _readAccents(TimeSignature signature) {
    final stored = _preferences.getString(_accentsKey);
    if (stored == null || stored.isEmpty) return null;

    final levels = <AccentLevel>[];
    for (final part in stored.split(',')) {
      final index = int.tryParse(part);
      if (index == null || index < 0 || index >= AccentLevel.values.length) {
        return null;
      }
      levels.add(AccentLevel.values[index]);
    }
    return levels.length == signature.beats ? levels : null;
  }

  T _readEnum<T extends Enum>(String key, List<T> values, T fallback) {
    final stored = _preferences.getString(key);
    return values.firstWhere(
      (value) => value.name == stored,
      orElse: () => fallback,
    );
  }
}
