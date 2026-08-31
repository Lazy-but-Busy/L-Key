/// Keeping audio alive when the app is not in front.
///
/// Contains no Flutter. See docs/adr/0016.
library;

import 'dart:async';

import 'package:meta/meta.dart';

/// What the player sees while audio plays in the background.
///
/// **Every string arrives from Dart.** The platform side hardcodes none of
/// them, because Burmese is a first-class language (DESIGN.md §36) and a
/// second translation pipeline in Kotlin string resources is exactly the kind
/// of duplication that goes stale.
@immutable
final class BackgroundAudioNotification {
  /// Creates the notification copy.
  const BackgroundAudioNotification({
    required this.title,
    required this.body,
    required this.stopLabel,
  });

  /// The notification's title.
  final String title;

  /// The line beneath it, conventionally the tempo and meter.
  final String body;

  /// The label on the action that stops playback.
  final String stopLabel;
}

/// Holds the platform's permission to keep playing while backgrounded.
///
/// On Android that is a foreground service with an ongoing notification. On
/// iOS the background audio mode and the playback audio-session category do
/// the whole job, so the implementation there is [NoBackgroundAudioService]
/// and nothing is missing.
///
/// **The notification is what makes this honest rather than a battery leak.**
/// Audio the player cannot see and cannot stop from outside the app is what
/// CLAUDE.md §50 is warning about; audio with a visible, stoppable
/// notification is a tool doing what it was asked to.
abstract interface class BackgroundAudioService {
  /// Whether this platform needs, and has, a background audio holder.
  bool get isSupported;

  /// Begins holding the platform's permission.
  Future<void> start(BackgroundAudioNotification notification);

  /// Revises what the player sees, without restarting anything.
  Future<void> update(BackgroundAudioNotification notification);

  /// Releases it.
  Future<void> stop();

  /// Fires when the player stopped playback from outside the app.
  Stream<void> get stopRequests;

  /// Releases the platform binding for good.
  Future<void> dispose();
}

/// The service for a platform that needs none.
///
/// iOS, and every test. Reports itself unsupported rather than pretending to
/// hold something (CLAUDE.md §47) — and on iOS that is the truth, not a gap:
/// the background mode is declared in `Info.plist` and the audio session does
/// the rest.
final class NoBackgroundAudioService implements BackgroundAudioService {
  /// Creates the no-op service.
  const NoBackgroundAudioService();

  @override
  bool get isSupported => false;

  @override
  Stream<void> get stopRequests => const Stream<void>.empty();

  @override
  Future<void> start(BackgroundAudioNotification notification) async {}

  @override
  Future<void> update(BackgroundAudioNotification notification) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
