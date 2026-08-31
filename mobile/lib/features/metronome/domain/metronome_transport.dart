/// Speaker to screen, in one place.
///
/// Contains no Flutter and reads no clock. See docs/adr/0016.
library;

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:l_key/core/audio/audio_output.dart';
import 'package:l_key/core/audio/background_audio_service.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/features/metronome/domain/click_schedule.dart';
import 'package:l_key/features/metronome/domain/click_synth.dart';
import 'package:l_key/features/metronome/domain/click_track_renderer.dart';
import 'package:l_key/features/metronome/domain/metronome_settings.dart';
import 'package:l_key/features/metronome/domain/metronome_state.dart';
import 'package:l_key/features/metronome/domain/metronome_thresholds.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';

/// Keeps time over an [AudioOutput].
///
/// The last link before Riverpod, and the metronome's answer to
/// `TunerPipeline`: it opens the speaker, renders blocks when the device asks
/// for them, and publishes the states that come out. It holds no widgets and
/// no Flutter, so the whole thing can be driven in a test from a fake output.
///
/// **The device's playback position is the only clock in here.** Blocks are
/// rendered ahead, but a beat is not published until the device reports it has
/// played the samples that beat sits in — so the indicator on screen can lag
/// the click by a block at worst and can never lead it.
///
/// **It releases the speaker on every path out** — stop, interruption, error
/// and dispose alike. A metronome left playing behind a closed screen is
/// exactly the battery cost CLAUDE.md §50 is about.
final class MetronomeTransport {
  /// Creates a transport over [output].
  MetronomeTransport({
    required AudioOutput output,
    MetronomeSettings? settings,
    BackgroundAudioService background = const NoBackgroundAudioService(),
    this.thresholds = MetronomeThresholds.defaults,
    // Background audio is asked for by default: a metronome is expected to
    // keep time while the player looks at a chart or locks the phone, which
    // is the one audio feature in this app where carrying on is correct.
    this.config = const AudioOutputConfig(allowBackgroundAudio: true),
  }) : _settings = settings ?? MetronomeSettings() {
    _output = output;
    _background = background;
    _state = MetronomeState(settings: _settings);
  }

  late final AudioOutput _output;
  late final BackgroundAudioService _background;

  /// What the background notification should say, when there is one.
  ///
  /// Supplied by the controller from a context that has localisations,
  /// because the platform side hardcodes no user-facing text.
  BackgroundAudioNotification? notification;

  /// The numbers this transport's behaviour turns on.
  final MetronomeThresholds thresholds;

  /// What is asked of the platform when playback starts.
  final AudioOutputConfig config;

  // Synchronous, unlike the tuner's. A tuner's state arrives from the
  // microphone and nobody is waiting on a particular frame; a metronome's
  // transport button is pressed by a finger, and the label must change on the
  // next frame rather than whenever the platform finishes releasing the
  // speaker. The listener only assigns state and fires a haptic, so there is
  // nothing here for re-entrancy to break.
  final StreamController<MetronomeState> _states =
      StreamController<MetronomeState>.broadcast(sync: true);

  MetronomeSettings _settings;
  late MetronomeState _state;

  ClickSynth? _synth;
  ClickTrackRenderer? _renderer;
  ClickSchedule? _schedule;
  Int16List? _block;
  StreamSubscription<AudioOutputStop>? _stops;
  StreamSubscription<void>? _backgroundStops;

  /// Frames handed to the device.
  int _fedFrames = 0;

  /// Frames the device says it has played.
  int _playedFrames = 0;

  final Queue<ScheduledClick> _pending = Queue<ScheduledClick>();
  final List<int> _recentDropouts = <int>[];

  MetronomeSettings? _pendingSettings;
  bool _starting = false;
  bool _hapticCue = false;

  /// The states the screen renders from.
  Stream<MetronomeState> get states => _states.stream;

  /// The latest state, for anything that needs it without subscribing.
  MetronomeState get state => _state;

  /// What is being played.
  MetronomeSettings get settings => _settings;

  /// Whether a beat's haptic is due.
  ///
  /// Read once by the controller after each state and cleared, so the
  /// transport stays free of the platform and the controller does not have to
  /// work out the edge itself. The same contract `TuningSession` uses.
  bool takeHapticCue() {
    final cue = _hapticCue;
    _hapticCue = false;
    return cue;
  }

  /// Opens the speaker and starts keeping time.
  ///
  /// Safe to call twice: the second call does nothing rather than opening a
  /// second player.
  Future<void> start() async {
    if (_starting || _output.isRunning) return;
    if (!_output.isAvailable) {
      // A fact about the device, not a fault, and not an error screen
      // (CLAUDE.md §47).
      _publish(_state.copyWith(status: MetronomeStatus.unavailable));
      _starting = false;
      return;
    }

    _starting = true;
    try {
      _publish(_state.copyWith(status: MetronomeStatus.starting));

      final synth = ClickSynth(
        sampleRate: config.sampleRate,
        sound: _settings.sound,
      );
      _synth = synth;
      _renderer = ClickTrackRenderer(synth: synth);
      _block = Int16List(config.blockFrames);

      // The first pulse of the timeline — the first count-in beat when there
      // is one — sits at sample zero, so playback and the music share an
      // origin and there is no gap between pressing start and hearing it.
      final countIn = _settings.countIn.bars * _settings.pulsesPerBar;
      _schedule = ClickSchedule(
        settings: _settings,
        sampleRate: config.sampleRate,
        originPulse: -countIn,
      );
      _fedFrames = 0;
      _playedFrames = 0;
      _pending.clear();
      _recentDropouts.clear();

      _stops = _output.interruptions.listen(_onInterrupted);
      // Pressing Stop in the notification shade must release the audio, not
      // merely dismiss a notification over a click that carries on.
      _backgroundStops = _background.stopRequests.listen(
        (_) => unawaited(stop()),
      );
      await _output.start(config, onFeed: _onFeed);
      await _startBackground();

      _publish(
        _state.copyWith(
          status: countIn > 0
              ? MetronomeStatus.countingIn
              : MetronomeStatus.running,
          bar: 0,
          beat: 0,
          level: AccentLevel.strong,
          countInBeatsRemaining: countIn ~/ _settings.subdivision.pulsesPerBeat,
          dropouts: 0,
          isStruggling: false,
          failure: null,
        ),
      );
    } on Failure catch (failure) {
      await _release();
      _publish(
        _state.copyWith(status: MetronomeStatus.failed, failure: failure),
      );
    } on Object catch (error) {
      await _release();
      _publish(
        _state.copyWith(
          status: MetronomeStatus.failed,
          failure: UnexpectedFailure(technicalDetail: '$error'),
        ),
      );
    } finally {
      _starting = false;
    }
  }

  /// Stops keeping time and releases the speaker.
  Future<void> stop() async {
    // Published before the speaker is released, not after. Stopping cannot
    // meaningfully fail, and a transport button that waited for the platform
    // would sit on STOP after the player had already pressed it.
    _publish(
      _state.copyWith(
        status: MetronomeStatus.idle,
        bar: 0,
        beat: 0,
        countInBeatsRemaining: 0,
        failure: null,
      ),
    );
    await _release();
  }

  /// Changes what is played.
  ///
  /// While stopped the change is immediate. While running it is staged and
  /// adopted at the next boundary that keeps the music intact: a tempo change
  /// at the next pulse, a change of meter or subdivision at the next bar. A
  /// meter that changed mid-bar would be heard as a mistake.
  void apply(MetronomeSettings next) {
    _settings = next;
    if (!_output.isRunning) {
      _schedule = null;
      _publish(_state.copyWith(settings: next));
      return;
    }
    _pendingSettings = next;
    _publish(_state.copyWith(settings: next));
    unawaited(_updateBackground());
  }

  /// Releases the speaker and closes the state stream for good.
  Future<void> dispose() async {
    await _release();
    await _background.dispose();
    await _output.dispose();
    await _states.close();
  }

  Future<void> _startBackground() async {
    final copy = notification;
    if (!_background.isSupported || copy == null) return;
    // A refused notification permission hides the notification; it does not
    // stop the click, and it must not be allowed to (docs/adr/0016).
    await _background.start(copy);
  }

  Future<void> _updateBackground() async {
    final copy = notification;
    if (!_background.isSupported || copy == null || !_output.isRunning) return;
    await _background.update(copy);
  }

  /// The device wants more samples.
  void _onFeed(int remainingFrames) {
    final schedule = _schedule;
    final renderer = _renderer;
    final block = _block;
    if (schedule == null || renderer == null || block == null) return;

    // What the device has actually played. This, and nothing else, is what
    // moves the beat on screen.
    _playedFrames = _fedFrames - remainingFrames;
    if (remainingFrames == 0 && _fedFrames > 0) _recordDropout();
    _advanceTo(_playedFrames);

    while (_fedFrames - _playedFrames < config.targetBufferFrames) {
      final end = _fedFrames + config.blockFrames;
      _adoptPendingBefore(end);

      final current = _schedule!;
      renderer.render(block, current, _fedFrames, end);
      _pending.addAll(current.clicksIn(_fedFrames, end));
      unawaited(_output.feed(block));
      _fedFrames = end;
    }

    // Again, now that the blocks around the playhead exist. The very first
    // click sits on sample zero and is only queued by the loop above, so
    // without this the downbeat would wait a block to appear on screen.
    _advanceTo(_playedFrames);
  }

  /// Publishes every beat the device has now reached.
  void _advanceTo(int playedFrames) {
    ScheduledClick? reached;
    while (_pending.isNotEmpty && _pending.first.sample <= playedFrames) {
      reached = _pending.removeFirst();
    }
    if (reached == null) return;

    // A subdivision is not a beat and must not move the indicator or fire a
    // haptic; sixteen buzzes a second is the overuse DESIGN.md §40 warns of.
    if (reached.level == AccentLevel.subdivision) return;

    final countInLeft = reached.isCountIn
        ? -reached.pulse ~/ _settings.subdivision.pulsesPerBeat
        : 0;

    if (reached.level == AccentLevel.strong ||
        reached.level == AccentLevel.accent) {
      _hapticCue = true;
    }

    _publish(
      _state.copyWith(
        status: reached.isCountIn
            ? MetronomeStatus.countingIn
            : MetronomeStatus.running,
        bar: reached.bar,
        beat: reached.beat,
        level: reached.level,
        countInBeatsRemaining: countInLeft,
      ),
    );
  }

  /// Adopts a staged settings change if its boundary falls before [end].
  void _adoptPendingBefore(int end) {
    final next = _pendingSettings;
    final current = _schedule;
    if (next == null || current == null) return;

    final metreChanged =
        next.signature != current.settings.signature ||
        next.subdivision != current.settings.subdivision;

    final boundary = metreChanged
        ? _nextBarPulse(current, _fedFrames)
        : current.firstPulseAtOrAfter(_fedFrames);

    if (current.sampleOf(boundary) >= end) return;

    _schedule = current.rebasedAt(boundary, next);
    _pendingSettings = null;
    _synth?.sound = next.sound;
  }

  /// The first pulse at or after [sample] that begins a bar.
  int _nextBarPulse(ClickSchedule schedule, int sample) {
    final perBar = schedule.settings.pulsesPerBar;
    final from = schedule.firstPulseAtOrAfter(sample);
    final offset = from - schedule.barOriginPulse;
    final remainder = offset % perBar;
    return remainder == 0 ? from : from + (perBar - remainder);
  }

  void _recordDropout() {
    _recentDropouts.add(_playedFrames);
    final window =
        thresholds.dropoutWindow.inMilliseconds * config.sampleRate ~/ 1000;
    _recentDropouts.removeWhere((at) => at < _playedFrames - window);
    _publish(
      _state.copyWith(
        dropouts: _state.dropouts + 1,
        isStruggling:
            _recentDropouts.length >= thresholds.dropoutsBeforeWarning,
      ),
    );
  }

  void _onInterrupted(AudioOutputStop reason) {
    // A call or an alarm is not something the player did wrong, and must not
    // show an error.
    unawaited(_release());
    _publish(
      _state.copyWith(
        status: MetronomeStatus.idle,
        bar: 0,
        beat: 0,
        countInBeatsRemaining: 0,
        failure: null,
      ),
    );
  }

  Future<void> _release() async {
    await _stops?.cancel();
    _stops = null;
    await _backgroundStops?.cancel();
    _backgroundStops = null;
    await _background.stop();
    _schedule = null;
    _renderer = null;
    _synth = null;
    _block = null;
    _pending.clear();
    _fedFrames = 0;
    _playedFrames = 0;
    _pendingSettings = null;
    _hapticCue = false;
    await _output.stop();
  }

  void _publish(MetronomeState state) {
    _state = state;
    if (!_states.isClosed) _states.add(state);
  }
}
