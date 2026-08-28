import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/app.dart';
import 'package:l_key/core/config/app_config.dart';

/// Provides the build-time configuration to the widget tree.
///
/// Overridden in tests to supply a fixture configuration.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider must be overridden'),
);

void main() {
  final config = AppConfig.fromEnvironment();

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const LKeyApp(),
    ),
  );
}
