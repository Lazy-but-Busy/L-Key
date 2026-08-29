/// The permission_handler-backed [MicrophonePermission].
library;

import 'package:l_key/core/permissions/microphone_permission.dart';
import 'package:permission_handler/permission_handler.dart';

/// Reads microphone access through `permission_handler`.
///
/// The only file in the application that imports that package, which a layer
/// test asserts. `record` can answer the same question, but only yes or no —
/// and the difference between "ask again" and "send them to Settings" is the
/// difference between a recoverable state and a dead end (CLAUDE.md §37).
final class PermissionHandlerMicrophonePermission
    implements MicrophonePermission {
  /// Creates the adapter.
  const PermissionHandlerMicrophonePermission();

  @override
  Future<MicrophoneAccess> status() async =>
      _map(await Permission.microphone.status);

  @override
  Future<MicrophoneAccess> request() async =>
      _map(await Permission.microphone.request());

  @override
  Future<bool> openSettings() => openAppSettings();

  static MicrophoneAccess _map(PermissionStatus status) => switch (status) {
    PermissionStatus.granted ||
    // Only ever returned for permissions that can be granted partially, which
    // the microphone is not; treated as access because it is.
    PermissionStatus.limited ||
    PermissionStatus.provisional => MicrophoneAccess.granted,
    PermissionStatus.permanentlyDenied => MicrophoneAccess.permanentlyDenied,
    PermissionStatus.restricted => MicrophoneAccess.restricted,
    PermissionStatus.denied => MicrophoneAccess.denied,
  };
}
