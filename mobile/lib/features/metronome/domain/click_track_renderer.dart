/// Filling a block of audio with the clicks that fall inside it.
///
/// Contains no Flutter and reads no clock. See docs/adr/0016.
library;

import 'dart:typed_data';

import 'package:l_key/features/metronome/domain/click_schedule.dart';
import 'package:l_key/features/metronome/domain/click_synth.dart';

/// Renders the click track into caller-owned buffers.
///
/// A pure function of the schedule and the synth, in the sense that matters:
/// rendering `[a, b)` gives the same samples however the range is divided, and
/// however many times it is asked for. That is what a chunk-invariance test
/// asserts, and it is the property that lets the block size change — or the
/// whole thing move to an isolate — without any of it sounding different.
///
/// It allocates nothing per block. The buffer belongs to the caller and the
/// voices belong to the synth; at ten blocks a second, forever, anything else
/// is garbage an app holding 60fps cannot afford.
final class ClickTrackRenderer {
  /// Creates a renderer over [synth].
  ClickTrackRenderer({required this.synth});

  /// The voices being played.
  final ClickSynth synth;

  /// Fills `out` with `[fromSample, toSample)` of [schedule].
  ///
  /// `out` must be at least `toSample - fromSample` long. Anything already in
  /// it is overwritten, so a reused buffer never leaks the previous block.
  ///
  /// A click whose head fell in an earlier block still contributes its tail
  /// here: the search starts a full voice-length before the window, which is
  /// the difference between a click and a click cut in half at every block
  /// boundary.
  void render(
    Int16List out,
    ClickSchedule schedule,
    int fromSample,
    int toSample,
  ) {
    final length = toSample - fromSample;
    if (length <= 0) return;
    out.fillRange(0, length, 0);

    final reach = synth.longestVoice;
    if (reach == 0) return;

    for (final click in schedule.clicksIn(fromSample - reach + 1, toSample)) {
      final voice = synth.voice(click.level);
      if (voice == null) continue;

      final start = click.sample - fromSample;
      var i = start < 0 ? -start : 0;
      final end = voice.length < length - start ? voice.length : length - start;

      for (; i < end; i++) {
        // Accumulate wider than the output, then clamp on write. Clicks do
        // not normally overlap, but a subdivision at 240 BPM under a long
        // voice can, and a wrap-around is an explosion where a clamp is a
        // slightly loud beat.
        final mixed = out[start + i] + voice[i];
        out[start + i] = mixed > 32767
            ? 32767
            : mixed < -32768
            ? -32768
            : mixed;
      }
    }
  }
}
