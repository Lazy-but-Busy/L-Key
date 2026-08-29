/// Synthetic signals for the audio tests.
///
/// docs/adr/0012 generates fixtures rather than committing WAV files. The
/// sweeps below cover a couple of hundred frequencies across five waveform
/// shapes and five noise levels, which no practical set of recordings covers,
/// and a failing test reads as "a sawtooth at 82.41 Hz with 10 dB of noise,
/// seed 7" rather than pointing at an opaque binary.
///
/// What they cannot do is prove anything about a real guitar through a real
/// microphone. That is what docs/DEVICE-TESTING.md is for.
library;

import 'dart:math' as math;
import 'dart:typed_data';

/// A pure sine — the signal with no excuse for any error at all.
Float64List sine({
  required double frequencyHz,
  required int sampleRate,
  required int length,
  double amplitude = 0.5,
  double phase = 0,
}) {
  final samples = Float64List(length);
  for (var i = 0; i < length; i++) {
    samples[i] =
        amplitude *
        math.sin(2 * math.pi * frequencyHz * i / sampleRate + phase);
  }
  return samples;
}

/// A tone built from chosen harmonics, which is what a string actually sounds.
///
/// [harmonicGains] is indexed from the fundamental: `[1, 0.5, 0.33]` is a
/// fundamental with a half-strength second harmonic and a third at a third.
/// A zero drops that harmonic entirely, which is how the missing-fundamental
/// case is built.
///
/// [inharmonicity] is the stiffness coefficient B in the standard string
/// model, where partial k sounds at `k·f0·sqrt(1 + B·k²)` rather than at a
/// perfect multiple. Roughly 1e-4 for a wound low E and 3e-5 for a plain high
/// E. It is why every tuner reads a wound string a few cents differently.
Float64List harmonicTone({
  required double frequencyHz,
  required int sampleRate,
  required int length,
  List<double>? harmonicGains,
  double amplitude = 0.5,
  double inharmonicity = 0,
}) {
  final gains = harmonicGains ?? <double>[for (var k = 1; k <= 8; k++) 1 / k];
  final samples = Float64List(length);
  final nyquist = sampleRate / 2;

  for (var index = 0; index < gains.length; index++) {
    final gain = gains[index];
    if (gain == 0) continue;
    final k = index + 1;
    final partial = k * frequencyHz * math.sqrt(1 + inharmonicity * k * k);
    if (partial >= nyquist) break;
    for (var i = 0; i < length; i++) {
      samples[i] += gain * math.sin(2 * math.pi * partial * i / sampleRate);
    }
  }

  return _normalise(samples, amplitude);
}

/// A sawtooth: every harmonic, at 1/k. The richest ordinary test signal.
Float64List sawtooth({
  required double frequencyHz,
  required int sampleRate,
  required int length,
  double amplitude = 0.5,
  int harmonics = 20,
}) => harmonicTone(
  frequencyHz: frequencyHz,
  sampleRate: sampleRate,
  length: length,
  amplitude: amplitude,
  harmonicGains: <double>[for (var k = 1; k <= harmonics; k++) 1 / k],
);

/// A square wave: odd harmonics only, at 1/k.
Float64List square({
  required double frequencyHz,
  required int sampleRate,
  required int length,
  double amplitude = 0.5,
  int harmonics = 20,
}) => harmonicTone(
  frequencyHz: frequencyHz,
  sampleRate: sampleRate,
  length: length,
  amplitude: amplitude,
  harmonicGains: <double>[
    for (var k = 1; k <= harmonics; k++)
      if (k.isOdd) 1 / k else 0,
  ],
);

/// Adds white noise at a given signal-to-noise ratio in decibels.
///
/// Seeded, so a failure in CI reproduces exactly.
Float64List withNoise(
  Float64List signal, {
  required double snrDb,
  required int seed,
}) {
  final random = math.Random(seed);
  var power = 0.0;
  for (final sample in signal) {
    power += sample * sample;
  }
  power /= signal.length;

  final noisePower = power / math.pow(10, snrDb / 10);
  final noiseAmplitude = math.sqrt(noisePower * 3); // uniform noise variance

  final out = Float64List(signal.length);
  for (var i = 0; i < signal.length; i++) {
    out[i] = signal[i] + (random.nextDouble() * 2 - 1) * noiseAmplitude;
  }
  return out;
}

/// Uniform white noise at a chosen amplitude, with no tone in it at all.
Float64List noise({
  required int length,
  required int seed,
  double amplitude = 0.5,
}) {
  final random = math.Random(seed);
  final out = Float64List(length);
  for (var i = 0; i < length; i++) {
    out[i] = (random.nextDouble() * 2 - 1) * amplitude;
  }
  return out;
}

/// A tone whose pitch wobbles, as a finger's vibrato makes it.
Float64List vibrato({
  required double frequencyHz,
  required int sampleRate,
  required int length,
  required double rateHz,
  required double depthCents,
  double amplitude = 0.5,
}) {
  final samples = Float64List(length);
  var phase = 0.0;
  for (var i = 0; i < length; i++) {
    final cents = depthCents * math.sin(2 * math.pi * rateHz * i / sampleRate);
    final instant = frequencyHz * math.pow(2, cents / 1200);
    phase += 2 * math.pi * instant / sampleRate;
    samples[i] = amplitude * math.sin(phase);
  }
  return samples;
}

/// Applies an exponential decay, as a plucked string has.
Float64List withDecay(
  Float64List signal, {
  required int sampleRate,
  required double t60Seconds,
}) {
  final out = Float64List(signal.length);
  final tau = t60Seconds / 6.908; // ln(1000), the 60 dB point
  for (var i = 0; i < signal.length; i++) {
    out[i] = signal[i] * math.exp(-(i / sampleRate) / tau);
  }
  return out;
}

/// Sums several signals, as several strings ringing together do.
Float64List mix(List<Float64List> parts) {
  final length = parts.map((p) => p.length).reduce(math.min);
  final out = Float64List(length);
  for (final part in parts) {
    for (var i = 0; i < length; i++) {
      out[i] += part[i];
    }
  }
  return out;
}

/// Shifts the whole signal off zero, as a microphone with a DC bias does.
Float64List withDcOffset(Float64List signal, double offset) {
  final out = Float64List(signal.length);
  for (var i = 0; i < signal.length; i++) {
    out[i] = signal[i] + offset;
  }
  return out;
}

/// Flattens anything beyond [ceiling], as an overloaded input does.
Float64List hardClip(Float64List signal, double ceiling) {
  final out = Float64List(signal.length);
  for (var i = 0; i < signal.length; i++) {
    out[i] = signal[i].clamp(-ceiling, ceiling);
  }
  return out;
}

/// Encodes to the signed 16-bit little-endian mono the platforms stream.
Uint8List toPcm16(Float64List signal) {
  final bytes = ByteData(signal.length * 2);
  for (var i = 0; i < signal.length; i++) {
    final clamped = signal[i].clamp(-1.0, 1.0);
    bytes.setInt16(i * 2, (clamped * 32767).round(), Endian.little);
  }
  return bytes.buffer.asUint8List();
}

/// The root-mean-square level of a signal, in decibels relative to full scale.
double rmsDbfs(Float64List signal) {
  var sum = 0.0;
  for (final sample in signal) {
    sum += sample * sample;
  }
  final rms = math.sqrt(sum / signal.length);
  return rms <= 0 ? -120 : 20 * (math.log(rms) / math.ln10);
}

Float64List _normalise(Float64List samples, double amplitude) {
  var peak = 0.0;
  for (final sample in samples) {
    peak = math.max(peak, sample.abs());
  }
  if (peak == 0) return samples;
  final scale = amplitude / peak;
  for (var i = 0; i < samples.length; i++) {
    samples[i] *= scale;
  }
  return samples;
}
