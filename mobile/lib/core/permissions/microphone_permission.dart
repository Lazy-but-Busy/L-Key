/// The microphone permission seam.
///
/// Contains no Flutter. See docs/adr/0012.
library;

/// What the operating system currently says about the microphone.
///
/// Four outcomes rather than a boolean, because they need four different
/// things from the player and CLAUDE.md §37 wants every one of them to carry
/// a next step.
enum MicrophoneAccess {
  /// The tuner may listen.
  granted,

  /// Refused, but asking again is allowed.
  denied,

  /// Refused for good. Only the operating system's own settings can undo it,
  /// so the interface has to offer a way there rather than a retry button.
  permanentlyDenied,

  /// Blocked by something the player does not control — parental controls, a
  /// managed device. There is nowhere useful to send them, and pretending
  /// otherwise wastes their time.
  restricted,
}

/// Reads and requests microphone access.
///
/// Behind an interface so the plugin is replaceable and so every permission
/// state can be exercised in a test, none of which a real device would let
/// happen on demand.
abstract interface class MicrophonePermission {
  /// What the system says right now, without prompting.
  Future<MicrophoneAccess> status();

  /// Prompts if prompting is still possible, then reports the outcome.
  Future<MicrophoneAccess> request();

  /// Opens the operating system's settings page for this app.
  ///
  /// Returns whether the page could be opened at all.
  Future<bool> openSettings();
}
