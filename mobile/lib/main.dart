import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:l_key/app/app.dart';
import 'package:l_key/core/audio/platform/pcm_sound_audio_output.dart';
import 'package:l_key/core/audio/platform/record_audio_input.dart';
import 'package:l_key/core/config/app_config.dart';
import 'package:l_key/features/metronome/presentation/metronome_controller.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/features/tuner/presentation/tuner_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  // Read once before the first frame so settings resolve synchronously
  // afterwards and the app never flashes the wrong theme or language.
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[
        appConfigProvider.overrideWithValue(config),
        sharedPreferencesProvider.overrideWithValue(preferences),
        // The real microphone, installed only here. Everything else — every
        // test, every screen — sees the interface, and the default the
        // provider hands out is the implementation that admits it has none.
        // Constructing this does not open the microphone; nothing does until
        // the player presses listen (CLAUDE.md §50).
        audioInputProvider.overrideWith((ref) {
          final input = RecordAudioInput();
          ref.onDispose(input.dispose);
          return input;
        }),
        // The real speaker, installed only here, on the same terms as the
        // microphone above. Constructing it opens nothing; the metronome does
        // not touch the audio device until the player presses start.
        audioOutputProvider.overrideWith((ref) {
          final output = PcmSoundAudioOutput();
          ref.onDispose(output.dispose);
          return output;
        }),
      ],
      child: const LKeyApp(),
    ),
  );
}
