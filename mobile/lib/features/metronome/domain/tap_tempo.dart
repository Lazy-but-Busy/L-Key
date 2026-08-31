/// Turning a sequence of taps into a tempo.
///
/// Contains no Flutter and **reads no clock** — the timestamps arrive as
/// arguments. See docs/adr/0016.
library;

import 'package:l_key/features/metronome/domain/metronome_settings.dart';
import 'package:l_key/features/metronome/domain/metronome_thresholds.dart';
import 'package:meta/meta.dart';

/// What one tap told us.
@immutable
final class TapTempoResult {
  /// Creates a result.
  const TapTempoResult({
    required this.bpm,
    required this.tapCount,
    required this.isNewPhrase,
  });

  /// The tempo the taps imply, or null when there is not yet one.
  ///
  /// Null after the first tap of a phrase. One tap is evidence that a finger
  /// moved, not evidence of a tempo, and a metronome that jumped to some
  /// tempo on a single tap would be inventing it (CLAUDE.md §47).
  final int? bpm;

  /// How many taps are in the current phrase, including this one.
  final int tapCount;

  /// Whether this tap began a new phrase rather than continuing one.
  final bool isNewPhrase;
}

/// Estimates a tempo from when a player tapped.
///
/// **Every timestamp is supplied by the caller**, as a [Duration] measured
/// from some fixed point. The class therefore holds no clock, which is what a
/// layer test enforces over this whole directory and what makes the estimate
/// exactly reproducible: the same list of durations yields the same integer on
/// every machine, every run (docs/adr/0013's rule, applied here).
///
/// The arithmetic is integer throughout for the same reason.
final class TapTempo {
  /// Creates an estimator.
  TapTempo({
    this.thresholds = MetronomeThresholds.defaults,
    this.minimumBpm = MetronomeSettings.minimumBpm,
    this.maximumBpm = MetronomeSettings.maximumBpm,
  });

  /// The numbers this estimator's behaviour turns on.
  final MetronomeThresholds thresholds;

  /// The slowest tempo a tap sequence may produce.
  final int minimumBpm;

  /// The fastest tempo a tap sequence may produce.
  final int maximumBpm;

  final List<int> _intervalsUs = <int>[];
  Duration? _last;
  int _tapCount = 0;

  /// How many taps are in the phrase so far.
  int get tapCount => _tapCount;

  /// Records a tap made at [at] and returns what the phrase now implies.
  TapTempoResult tap(Duration at) {
    final previous = _last;
    // A gap longer than the slowest beat the product offers cannot be part of
    // a tempo, so what follows it is a new phrase. A timestamp that went
    // backwards is a caller resetting its stopwatch, and is treated the same
    // way rather than producing a negative interval.
    final isNewPhrase =
        previous == null ||
        at < previous ||
        at - previous > thresholds.tapResetGap;

    if (isNewPhrase) {
      _intervalsUs.clear();
      _tapCount = 1;
      _last = at;
      return const TapTempoResult(bpm: null, tapCount: 1, isNewPhrase: true);
    }

    _intervalsUs.add((at - previous).inMicroseconds);
    if (_intervalsUs.length > thresholds.tapWindow) _intervalsUs.removeAt(0);
    _tapCount++;
    _last = at;

    return TapTempoResult(
      bpm: _estimate(),
      tapCount: _tapCount,
      isNewPhrase: false,
    );
  }

  /// Forgets the phrase, as when the screen closes.
  void reset() {
    _intervalsUs.clear();
    _last = null;
    _tapCount = 0;
  }

  /// The tempo the kept intervals imply, or null when there are none.
  int? _estimate() {
    final kept = _withoutOutliers();
    if (kept.isEmpty) return null;

    // The mean of the survivors, not their median. The tuner takes a median
    // because it has no way to tell which reading is the wrong one; here the
    // rejection step above has already removed it, so using every remaining
    // interval uses all the evidence instead of discarding four fifths of it.
    var total = 0;
    for (final interval in kept) {
      total += interval;
    }
    if (total <= 0) return maximumBpm;

    // Round half up, in integers, so the answer cannot drift with a platform's
    // floating-point behaviour.
    final bpm = (60000000 * kept.length + total ~/ 2) ~/ total;
    return bpm.clamp(minimumBpm, maximumBpm);
  }

  /// The intervals, minus any that a fumbled tap explains.
  ///
  /// Only engaged once there are three, because a median of two is their mean
  /// and would reject nothing.
  List<int> _withoutOutliers() {
    if (_intervalsUs.length < 3) return _intervalsUs;

    final sorted = List<int>.of(_intervalsUs)..sort();
    final middle = sorted.length ~/ 2;
    final median = sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) ~/ 2;

    final low = median / thresholds.tapOutlierFactor;
    final high = median * thresholds.tapOutlierFactor;
    final kept = <int>[
      for (final interval in _intervalsUs)
        if (interval >= low && interval <= high) interval,
    ];
    return kept.isEmpty ? _intervalsUs : kept;
  }
}
