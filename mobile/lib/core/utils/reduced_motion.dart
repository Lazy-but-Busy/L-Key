import 'package:flutter/material.dart';

/// Accessibility helpers for motion.
///
/// DESIGN.md §42 requires every component to support reduced motion, and
/// §41 warns against animating merely because animation is possible. Reading
/// the platform setting through here keeps that a single decision rather than
/// one each widget has to remember.
extension LkMotionContext on BuildContext {
  /// Whether the operating system has asked for reduced motion.
  ///
  /// Defaults to `false` when no [MediaQuery] is in scope, which happens only
  /// in a bare test host.
  bool get reducedMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  /// [duration], collapsed to zero when the user has asked for reduced motion.
  ///
  /// The state change still happens — instantly — so meaning is never carried
  /// by the animation alone.
  Duration motion(Duration duration) =>
      reducedMotion ? Duration.zero : duration;
}
