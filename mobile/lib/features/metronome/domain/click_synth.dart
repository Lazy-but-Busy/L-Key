/// Turning a voice into samples.
///
/// Contains no Flutter and reads no clock. See docs/adr/0016.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:l_key/core/audio/biquad.dart';
import 'package:l_key/features/metronome/domain/click_sound.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';

/// Renders click voices to reusable one-shot buffers.
///
/// **Every click is rendered once**, when the sound or the sample rate
/// changes, and the audio path then only copies. Synthesising per beat would
/// put a few thousand transcendental functions in the callback that must not
/// miss its deadline (mobile CLAUDE.md §15).
///
/// The result is a pure function of the voice and the rate: the same spec
/// always yields the same samples, which is what lets a test assert a
/// waveform instead of trusting one.
final class ClickSynth {
  /// Creates a synth for [sampleRate].
  factory ClickSynth({
    required int sampleRate,
    ClickSound sound = ClickSound.woodblock,
  }) => ClickSynth._(sampleRate, sound).._rebuild();

  ClickSynth._(this.sampleRate, this._sound);

  /// The rate the one-shots are rendered at.
  final int sampleRate;

  ClickSound _sound;
  final Map<AccentLevel, Int16List> _voices = <AccentLevel, Int16List>{};

  /// Which sound is loaded.
  ClickSound get sound => _sound;

  /// Loads a different sound, re-rendering its voices.
  set sound(ClickSound value) {
    if (value == _sound) return;
    _sound = value;
    _rebuild();
  }

  /// The samples for [level], or null when that level sounds nothing.
  ///
  /// The buffer is owned by the synth and must not be modified. It is handed
  /// out rather than copied because the renderer reads it thousands of times
  /// a minute and never writes to it.
  Int16List? voice(AccentLevel level) => _voices[level];

  /// The longest voice, in samples.
  ///
  /// The renderer needs it to know how far back a click may still be ringing
  /// when a block begins.
  int get longestVoice => _voices.values.fold(
    0,
    (longest, samples) => samples.length > longest ? samples.length : longest,
  );

  void _rebuild() {
    _voices.clear();
    for (final level in AccentLevel.values) {
      final spec = _sound.voiceFor(level);
      if (spec == null) continue;
      _voices[level] = render(spec, sampleRate);
    }
  }

  /// Renders one voice to signed 16-bit samples.
  static Int16List render(ClickVoiceSpec spec, int sampleRate) {
    final length = math.max(
      2,
      (spec.decayMs / 1000 * sampleRate).round(),
    );
    final buffer = Float64List(length);

    // The noise burst, band-passed so it has a pitch without having a tone.
    // The filter is stateful across samples but not across calls: a click is
    // rendered once from silence, so there is no discontinuity for its memory
    // to carry, which is why it can be built and discarded here.
    if (spec.noiseMix > 0) {
      final random = math.Random(spec.seed);
      final filter = Biquad.bandPass(
        sampleRate: sampleRate.toDouble(),
        centreHz: spec.centreHz,
        q: spec.q,
      );
      for (var i = 0; i < length; i++) {
        buffer[i] = filter.process(random.nextDouble() * 2 - 1) * spec.noiseMix;
      }
    }

    // The body under it, which is what a listener hears as the click's pitch.
    final bodyGain = 1 - spec.noiseMix;
    if (bodyGain > 0) {
      final step = 2 * math.pi * spec.bodyHz / sampleRate;
      for (var i = 0; i < length; i++) {
        buffer[i] += math.sin(step * i) * bodyGain;
      }
    }

    // One envelope over both: a raised-cosine attack, then an exponential
    // decay reaching -60 dB exactly at decayMs.
    final attack = math.max(1, (spec.attackMs / 1000 * sampleRate).round());
    final tau = length / math.log(1000);
    for (var i = 0; i < length; i++) {
      final rise = i >= attack
          ? 1.0
          : 0.5 - 0.5 * math.cos(math.pi * i / attack);
      buffer[i] *= rise * math.exp(-i / tau);
    }

    // Normalise to the requested peak. The band-pass costs a great deal of
    // amplitude and how much depends on Q, so a voice's loudness has to be
    // measured rather than predicted, or the accent levels would not keep
    // their intended distance from one another.
    var loudest = 0.0;
    for (final sample in buffer) {
      final magnitude = sample.abs();
      if (magnitude > loudest) loudest = magnitude;
    }
    final scale = loudest == 0 ? 0.0 : spec.peak / loudest;

    final samples = Int16List(length);
    for (var i = 0; i < length; i++) {
      samples[i] = (buffer[i] * scale * 32767).round().clamp(-32768, 32767);
    }
    // A click that ends mid-swing leaves a step in the silence after it,
    // which is a quiet pop on every beat.
    samples[length - 1] = 0;
    return samples;
  }
}
