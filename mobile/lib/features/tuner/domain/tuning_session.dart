/// The tuner's state machine: analysed windows in, screen states out.
///
/// Contains no Flutter. See docs/adr/0013.
library;

import 'package:l_key/core/audio/audio_pipeline.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/core/permissions/microphone_permission.dart';
import 'package:l_key/features/tuner/domain/tuner_reading.dart';
import 'package:l_key/features/tuner/domain/tuner_state.dart';
import 'package:l_key/features/tuner/domain/tuner_thresholds.dart';
import 'package:l_key/features/tuner/domain/tuning_engine.dart';
import 'package:l_key/features/tuner/domain/tuning_target.dart';

/// Decides what the tuner shows, one analysed window at a time.
///
/// **Every method is `(state, input) -> state`.** There is no clock, no timer
/// and no stream in this file: time arrives as [AnalysisFrame.timestamp],
/// which the assembler counts from samples rather than reading from
/// `DateTime.now()`. A test that feeds forty-three frames advances the session
/// by exactly one second, identically on every machine and every run
/// (docs/adr/0013). A layer test asserts that no clock appears here.
final class TuningSession {
  /// Creates a session over [tuning].
  TuningSession({
    this.thresholds = TunerThresholds.defaults,
    Tuning tuning = Tuning.standard,
    double referenceHz = 440,
    this.collectDiagnostics = false,
  }) : _state = TunerState(tuning: tuning, referenceHz: referenceHz),
       _engine = TuningEngine(
         selector: StringTargetSelector(tuning),
         referenceHz: referenceHz,
       );

  /// The numbers this session's behaviour turns on.
  final TunerThresholds thresholds;

  /// Whether to populate [TunerState.diagnostics], which the debug view reads.
  final bool collectDiagnostics;

  TunerState _state;
  TuningEngine _engine;

  final List<double> _recent = <double>[];
  int _quietFrames = 0;
  int _loudFrames = 0;
  Duration? _inTuneSince;
  Duration? _lastHaptic;
  int? _pendingStringIndex;
  Duration? _pendingStringSince;

  /// What the screen should show right now.
  TunerState get state => _state;

  /// Whether the tuning-lock haptic should fire on this transition.
  ///
  /// Read once by the controller after each [onFrame] and cleared. The session
  /// stays pure — it never touches the platform — and the controller does not
  /// have to work out the edge for itself.
  bool takeHapticCue() {
    final cue = _hapticCue;
    _hapticCue = false;
    return cue;
  }

  bool _hapticCue = false;

  /// The player granted, refused or was denied microphone access.
  TunerState onPermission(MicrophoneAccess access) => _state = switch (access) {
    MicrophoneAccess.granted => _state.copyWith(
      status: TunerStatus.starting,
      failure: null,
    ),
    MicrophoneAccess.denied => _state.copyWith(
      status: TunerStatus.permissionRequired,
      canOpenSettings: false,
      reading: null,
    ),
    MicrophoneAccess.permanentlyDenied => _state.copyWith(
      status: TunerStatus.permissionBlocked,
      canOpenSettings: true,
      reading: null,
    ),
    // Nothing in the system settings will help a managed or parentally
    // restricted device, so no button is offered (CLAUDE.md §37).
    MicrophoneAccess.restricted => _state.copyWith(
      status: TunerStatus.permissionBlocked,
      canOpenSettings: false,
      reading: null,
    ),
  };

  /// The microphone opened.
  TunerState onStarted() {
    _clearSignal();
    return _state = _state.copyWith(
      status: TunerStatus.listening,
      failure: null,
      reading: null,
    );
  }

  /// The player, the route or the lifecycle stopped listening.
  TunerState onStopped() {
    _clearSignal();
    return _state = _state.copyWith(
      status: TunerStatus.idle,
      reading: null,
      diagnostics: null,
    );
  }

  /// Capture ended without being asked to — a call, an alarm, another app.
  ///
  /// Not an error, and must not show an error. The player pressed nothing
  /// wrong; the tuner simply stopped and can be started again.
  TunerState onInterrupted() => onStopped();

  /// Something genuinely failed.
  TunerState onError(Failure failure) {
    _clearSignal();
    return _state = _state.copyWith(
      status: TunerStatus.failed,
      failure: failure,
      reading: null,
    );
  }

  /// One analysed window.
  TunerState onFrame(AnalysisFrame frame) {
    if (!_state.isListening) return _state;

    final level = frame.features.rmsDbfs;

    if (level < thresholds.silenceFloorDbfs) {
      _loudFrames = 0;
      _quietFrames++;
      if (_quietFrames >= thresholds.silenceHoldFrames) {
        _clearSignal();
        return _state = _state.copyWith(
          status: TunerStatus.listening,
          reading: null,
          diagnostics: _diagnosticsFor(frame, null, 0),
        );
      }
      return _state = _state.copyWith(
        diagnostics: _diagnosticsFor(frame, null, 0),
      );
    }

    _quietFrames = 0;
    if (level >= thresholds.signalOnsetDbfs) {
      _loudFrames++;
    }
    // Between the two thresholds a signal already being tracked carries on,
    // but a new one does not start. This is the hysteresis that stops a
    // decaying note flickering.
    if (_state.status == TunerStatus.listening &&
        _loudFrames < thresholds.onsetFrames) {
      return _state = _state.copyWith(
        diagnostics: _diagnosticsFor(frame, null, 0),
      );
    }

    final pitch = frame.pitch;
    final confidence = pitch == null
        ? 0.0
        : _confidenceFor(pitch.clarity, frame);

    if (pitch == null || confidence < thresholds.leaveTrackingConfidence) {
      _clearSignal();
      return _state = _state.copyWith(
        status: TunerStatus.noisy,
        reading: null,
        diagnostics: _diagnosticsFor(frame, pitch?.frequencyHz, confidence),
      );
    }

    // A period has to be found before more than one note can be claimed:
    // saying "two strings" when none could be identified would be inventing
    // one (CLAUDE.md §47).
    final evidence = frame.features.explainWith(pitch.frequencyHz);
    if (evidence.isPolyphonic) {
      _clearSignal();
      return _state = _state.copyWith(
        status: TunerStatus.imperfectInput,
        reading: null,
        diagnostics: _diagnosticsFor(
          frame,
          pitch.frequencyHz,
          confidence,
          evidence.residualRatio,
          evidence.residualPartialCount,
        ),
      );
    }

    if (_state.status != TunerStatus.tracking &&
        confidence < thresholds.enterTrackingConfidence) {
      return _state = _state.copyWith(
        status: TunerStatus.noisy,
        reading: null,
        diagnostics: _diagnosticsFor(frame, pitch.frequencyHz, confidence),
      );
    }

    _recent.add(pitch.frequencyHz);
    if (_recent.length > thresholds.medianWindow) _recent.removeAt(0);
    final frequency = _median(_recent);

    final mode = _resolveMode(frequency, frame.timestamp);
    final reading = _engine.read(
      frequencyHz: frequency,
      confidence: confidence,
      mode: mode,
    );
    if (reading == null) {
      return _state = _state.copyWith(
        status: TunerStatus.noisy,
        reading: null,
        diagnostics: _diagnosticsFor(frame, pitch.frequencyHz, confidence),
      );
    }

    return _state = _state.copyWith(
      status: TunerStatus.tracking,
      reading: _settle(reading, frame.timestamp),
      diagnostics: _diagnosticsFor(
        frame,
        pitch.frequencyHz,
        confidence,
        evidence.residualRatio,
        evidence.residualPartialCount,
      ),
    );
  }

  /// The player picked a string.
  TunerState selectString(int index) {
    _resetSettling();
    return _state = _state.copyWith(mode: TargetMode.string(index));
  }

  /// The player handed the choice back to the tuner.
  ///
  /// The reading is cleared as well as the mode. Without that, the string the
  /// player had locked would count as the current one, and the switch guard
  /// would hold the target there for another third of a second — which reads
  /// as the button not having worked.
  TunerState selectAuto() {
    _resetSettling();
    return _state = _state.copyWith(
      mode: const TargetMode.auto(),
      reading: null,
    );
  }

  /// The player changed tuning.
  TunerState selectTuning(Tuning tuning) {
    _clearSignal();
    _engine = _engine.copyWith(selector: StringTargetSelector(tuning));
    return _state = _state.copyWith(
      tuning: tuning,
      isChromatic: false,
      mode: const TargetMode.auto(),
      reading: null,
    );
  }

  /// The player switched to naming any note rather than a string.
  TunerState selectChromatic() {
    _clearSignal();
    _engine = _engine.copyWith(selector: const ChromaticTargetSelector());
    return _state = _state.copyWith(
      isChromatic: true,
      mode: const TargetMode.auto(),
      reading: null,
    );
  }

  /// The player changed what A4 means.
  TunerState setReferencePitch(double hz) {
    _resetSettling();
    _engine = _engine.copyWith(referenceHz: hz);
    return _state = _state.copyWith(referenceHz: hz, reading: null);
  }

  /// The detector's raw periodicity, gated by how tone-like the window was.
  ///
  /// Two independent factors, each in 0…1 and each testable on its own. A
  /// period can be perfectly clear and belong to a fan, which is what the
  /// tonality gate is for (CLAUDE.md §16).
  ///
  /// Loudness deliberately plays no part. Whether anything is happening is
  /// already decided by the silence thresholds, and how loudly it happens says
  /// nothing about whether it is a note — a quietly plucked string is exactly
  /// as measurable as a hard one.
  double _confidenceFor(double clarity, AnalysisFrame frame) {
    final tonality = _ramp(
      1 - frame.features.spectralFlatness,
      thresholds.tonalityGateFloor,
      thresholds.tonalityGateCeiling,
    );
    return (clarity * tonality).clamp(0.0, 1.0);
  }

  /// Which target to measure against, holding a string until another is
  /// clearly nearer for long enough.
  TargetMode _resolveMode(double frequency, Duration now) {
    final mode = _state.mode;
    if (mode is StringTargetMode || _state.isChromatic) return mode;

    final nearest = _engine.selector.nearestTo(
      frequency,
      referenceHz: _state.referenceHz,
    );
    final index = nearest.stringIndex;
    if (index == null) return mode;

    final current = _state.reading?.targetStringIndex;
    if (current == null || current == index) {
      _pendingStringIndex = null;
      _pendingStringSince = null;
      return mode;
    }

    // A different string is nearer. It has to stay nearer for a moment before
    // the target moves, or a note sitting between two strings flaps.
    if (_pendingStringIndex != index) {
      _pendingStringIndex = index;
      _pendingStringSince = now;
    }
    final since = _pendingStringSince;
    if (since != null && now - since >= thresholds.targetSwitchGuard) {
      _pendingStringIndex = null;
      _pendingStringSince = null;
      return mode;
    }
    return TargetMode.string(current);
  }

  /// Marks a reading settled once it has held in tune long enough.
  TunerReading _settle(TunerReading reading, Duration now) {
    final wasSettled = _state.reading?.isSettled ?? false;
    // A settled reading is released only well outside the tolerance, so one
    // resting on the boundary does not flicker the lock.
    final holds = wasSettled
        ? reading.cents.abs() <= thresholds.settleReleaseCents
        : reading.isInTune;

    if (!holds) {
      _inTuneSince = null;
      return reading;
    }

    final since = _inTuneSince ??= now;
    final settled = wasSettled || now - since >= thresholds.settleDuration;
    if (settled && !wasSettled) {
      final last = _lastHaptic;
      if (last == null || now - last >= thresholds.hapticRearmDuration) {
        _hapticCue = true;
        _lastHaptic = now;
      }
    }
    return reading.copyWith(isSettled: settled);
  }

  void _clearSignal() {
    _recent.clear();
    _quietFrames = 0;
    _loudFrames = 0;
    _resetSettling();
  }

  void _resetSettling() {
    _inTuneSince = null;
    _pendingStringIndex = null;
    _pendingStringSince = null;
  }

  TunerDiagnostics? _diagnosticsFor(
    AnalysisFrame frame,
    double? rawFrequencyHz,
    double confidence, [
    double residualRatio = 0,
    int residualPartialCount = 0,
  ]) {
    if (!collectDiagnostics) return null;
    return TunerDiagnostics(
      rmsDbfs: frame.features.rmsDbfs,
      clarity: frame.pitch?.clarity ?? 0,
      confidence: confidence,
      spectralFlatness: frame.features.spectralFlatness,
      clippedRatio: frame.features.clippedRatio,
      residualRatio: residualRatio,
      residualPartialCount: residualPartialCount,
      peakCount: frame.features.peaks.length,
      rawFrequencyHz: rawFrequencyHz,
      sampleRate: _pipelineSampleRate,
      windowSize: _pipelineWindowSize,
      hopSize: _pipelineHopSize,
      framesPerSecond: _pipelineFramesPerSecond,
    );
  }

  int _pipelineSampleRate = 0;
  int _pipelineWindowSize = 0;
  int _pipelineHopSize = 0;
  double _pipelineFramesPerSecond = 0;

  /// Records the audio settings actually in use, for the diagnostics view.
  void describePipeline(AudioPipeline pipeline) {
    _pipelineSampleRate = pipeline.sampleRate;
    _pipelineWindowSize = pipeline.windowSize;
    _pipelineHopSize = pipeline.hopSize;
    _pipelineFramesPerSecond = pipeline.framesPerSecond;
  }

  static double _ramp(double value, double from, double to) =>
      ((value - from) / (to - from)).clamp(0.0, 1.0);

  static double _median(List<double> values) {
    final sorted = List<double>.of(values)..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }
}
