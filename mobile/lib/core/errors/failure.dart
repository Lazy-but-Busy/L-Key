/// A recoverable, user-presentable error.
///
/// CLAUDE.md §37 requires that users see a plain explanation while technical
/// detail goes to logs. Every failure therefore carries two things: a
/// [messageKey] the UI resolves through localisation, and an optional
/// [technicalDetail] that must only ever be logged — never rendered.
sealed class Failure implements Exception {
  /// Creates a failure.
  const Failure({required this.messageKey, this.technicalDetail});

  /// Localisation key for the message shown to the user.
  final String messageKey;

  /// Engineer-facing detail. Log this; never put it on screen.
  final String? technicalDetail;

  /// Stable identifier for logs and analytics.
  ///
  /// Declared rather than derived from `runtimeType`, which is not reliable
  /// once the release build is minified.
  String get kind;

  @override
  String toString() => '$kind($messageKey)';
}

/// The device could not reach the network.
final class NetworkFailure extends Failure {
  /// Creates a network failure.
  const NetworkFailure({super.technicalDetail})
    : super(messageKey: 'errorNoConnection');

  @override
  String get kind => 'network';
}

/// The server responded with an error status.
final class ServerFailure extends Failure {
  /// Creates a server failure carrying the HTTP [statusCode].
  const ServerFailure({required this.statusCode, super.technicalDetail})
    : super(messageKey: 'errorUnexpected');

  /// HTTP status returned by the backend.
  final int statusCode;

  @override
  String get kind => 'server';
}

/// A response could not be decoded into the expected shape.
final class DecodingFailure extends Failure {
  /// Creates a decoding failure.
  const DecodingFailure({super.technicalDetail})
    : super(messageKey: 'errorUnexpected');

  @override
  String get kind => 'decoding';
}

/// The user declined a required OS permission, such as the microphone.
final class PermissionFailure extends Failure {
  /// Creates a permission failure for the named [permission].
  const PermissionFailure({required this.permission, super.technicalDetail})
    : super(messageKey: 'errorUnexpected');

  /// Which permission was refused.
  final String permission;

  @override
  String get kind => 'permission';
}

/// Anything not covered by a more specific case.
final class UnexpectedFailure extends Failure {
  /// Creates an unexpected failure.
  const UnexpectedFailure({super.technicalDetail})
    : super(messageKey: 'errorUnexpected');

  @override
  String get kind => 'unexpected';
}
