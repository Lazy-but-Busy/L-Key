/// The Android-backed [BackgroundAudioService].
library;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:l_key/core/audio/background_audio_service.dart';

/// Drives the Android foreground service that keeps the click sounding.
///
/// The only file in the application that names this channel. Everything above
/// it is plain Dart, so a test gets `NoBackgroundAudioService` and never a
/// platform call.
final class MethodChannelBackgroundAudio implements BackgroundAudioService {
  /// Creates the binding.
  MethodChannelBackgroundAudio({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName) {
    _channel.setMethodCallHandler(_onCall);
  }

  /// The channel `MainActivity` answers on.
  static const String channelName = 'com.lkey.l_key/metronome_service';

  final MethodChannel _channel;
  final StreamController<void> _stopRequests =
      StreamController<void>.broadcast();

  @override
  bool get isSupported => true;

  @override
  Stream<void> get stopRequests => _stopRequests.stream;

  @override
  Future<void> start(BackgroundAudioNotification notification) =>
      _invoke('start', notification);

  @override
  Future<void> update(BackgroundAudioNotification notification) =>
      _invoke('update', notification);

  @override
  Future<void> stop() async {
    // A service that will not stop is not worth failing a stop over: the
    // audio is already released by the time this is called, so the worst case
    // is a notification the system clears on its own.
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  @override
  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
    await _stopRequests.close();
  }

  Future<void> _invoke(
    String method,
    BackgroundAudioNotification notification,
  ) async {
    try {
      await _channel.invokeMethod<void>(method, <String, String>{
        'title': notification.title,
        'body': notification.body,
        'stopLabel': notification.stopLabel,
      });
    } on PlatformException {
      // The player refused the notification permission, or the system
      // declined the service. The click keeps playing either way; this is not
      // a reason to stop it (docs/adr/0016).
      return;
    } on MissingPluginException {
      return;
    }
  }

  Future<void> _onCall(MethodCall call) async {
    if (call.method == 'stopRequested' && !_stopRequests.isClosed) {
      _stopRequests.add(null);
    }
  }
}
