/// Turns the platform's PCM chunks into the overlapping windows the analyzers
/// expect.
///
/// Contains no Flutter. See docs/adr/0012.
library;

import 'dart:typed_data';

import 'package:l_key/core/audio/audio_frame.dart';
import 'package:l_key/core/audio/biquad.dart';

/// Re-chunks a stream of PCM bytes into fixed, overlapping [AudioFrame]s.
///
/// The microphone hands over buffers of whatever size the platform feels like;
/// pitch detection needs a constant window. This sits between the two, which
/// is what lets `AudioInput` stay a dumb transport and lets every analyzer
/// downstream assume a fixed length (mobile CLAUDE.md §14).
///
/// Input is signed 16-bit little-endian mono, the one encoding every platform
/// streams. Samples are read through a [ByteData] view rather than an
/// [Int16List] view because a buffer arriving from a platform channel is not
/// guaranteed to start on an even byte, and an `Int16List.view` onto an odd
/// offset throws.
final class AudioFrameAssembler {
  /// Emits a [windowSize] window every [hopSize] samples.
  ///
  /// The optional pre-filter runs on the sample stream before framing — on
  /// the stream, so that its memory carries across window boundaries rather
  /// than restarting at each one.
  AudioFrameAssembler({
    required this.sampleRate,
    required this.windowSize,
    required this.hopSize,
    this._preFilter,
  }) : _ring = Float64List(windowSize),
       _window = Float64List(windowSize) {
    if (sampleRate <= 0) {
      throw ArgumentError.value(sampleRate, 'sampleRate', 'must be positive');
    }
    if (windowSize <= 0) {
      throw ArgumentError.value(windowSize, 'windowSize', 'must be positive');
    }
    if (hopSize <= 0 || hopSize > windowSize) {
      throw ArgumentError.value(
        hopSize,
        'hopSize',
        'must be positive and no larger than windowSize',
      );
    }
  }

  /// Samples per second, as granted by the device.
  final int sampleRate;

  /// How many samples each emitted window holds.
  final int windowSize;

  /// How many new samples separate one window from the next.
  final int hopSize;

  final Biquad? _preFilter;
  final Float64List _ring;
  final Float64List _window;

  int _cursor = 0;
  int _received = 0;
  int _sinceHop = 0;
  int _framesEmitted = 0;
  int _carry = 0;
  bool _hasCarry = false;

  /// How many windows have been emitted since the last [reset].
  int get framesEmitted => _framesEmitted;

  /// Feeds one platform chunk in, calling [onFrame] once per complete window.
  ///
  /// [onFrame] is synchronous and the frame it receives is only valid for the
  /// duration of the call — see [AudioFrame.samples].
  void addPcm16(Uint8List chunk, void Function(AudioFrame frame) onFrame) {
    final bytes = ByteData.view(
      chunk.buffer,
      chunk.offsetInBytes,
      chunk.lengthInBytes,
    );
    var offset = 0;

    // A chunk boundary can fall between the two bytes of one sample, so the
    // odd byte waits here for its partner rather than being dropped or
    // read against the wrong neighbour.
    if (_hasCarry && chunk.lengthInBytes > 0) {
      _push((_carry | (bytes.getUint8(0) << 8)).toSigned(16), onFrame);
      offset = 1;
      _hasCarry = false;
    }

    final usable = chunk.lengthInBytes - offset;
    final wholeSamples = usable ~/ 2;
    for (var i = 0; i < wholeSamples; i++) {
      _push(bytes.getInt16(offset + i * 2, Endian.little), onFrame);
    }

    if (usable.isOdd) {
      _carry = bytes.getUint8(chunk.lengthInBytes - 1);
      _hasCarry = true;
    }
  }

  void _push(int sample, void Function(AudioFrame frame) onFrame) {
    // 32768 rather than 32767: it makes the scale symmetric and puts full
    // negative scale at exactly −1.0.
    var value = sample / 32768.0;
    final filter = _preFilter;
    if (filter != null) value = filter.process(value);

    _ring[_cursor] = value;
    _cursor = (_cursor + 1) % windowSize;
    _received++;
    _sinceHop++;

    if (_received < windowSize || _sinceHop < hopSize) return;
    _sinceHop = 0;
    _emit(onFrame);
  }

  void _emit(void Function(AudioFrame frame) onFrame) {
    // The ring is full, so the oldest sample is the one the cursor is about
    // to overwrite.
    final head = windowSize - _cursor;
    _window.setRange(0, head, _ring, _cursor);
    _window.setRange(head, windowSize, _ring);

    // The window's first sample, counted from the stream's start. Derived
    // from the sample count rather than a clock so the whole tuning session
    // replays identically in a test.
    final startSample = _received - windowSize;
    final frame = AudioFrame(
      samples: _window,
      sampleRate: sampleRate,
      timestamp: Duration(microseconds: startSample * 1000000 ~/ sampleRate),
    );

    _framesEmitted++;
    onFrame(frame);
  }

  /// Forgets every buffered sample, as when listening stops and restarts.
  void reset() {
    _ring.fillRange(0, windowSize, 0);
    _cursor = 0;
    _received = 0;
    _sinceHop = 0;
    _framesEmitted = 0;
    _hasCarry = false;
    _preFilter?.reset();
  }
}
