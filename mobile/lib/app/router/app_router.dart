import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/shell/app_shell.dart';
import 'package:l_key/core/config/environment.dart';
import 'package:l_key/features/chords/presentation/chord_analyzer_page.dart';
import 'package:l_key/features/chords/presentation/chord_detail_page.dart';
import 'package:l_key/features/chords/presentation/chords_page.dart';
import 'package:l_key/features/foundation/presentation/foundation_page.dart';
import 'package:l_key/features/fretboard/presentation/fretboard_page.dart';
import 'package:l_key/features/home/presentation/home_page.dart';
import 'package:l_key/features/metronome/presentation/metronome_page.dart';
import 'package:l_key/features/profile/presentation/profile_page.dart';
import 'package:l_key/features/scales/presentation/scales_page.dart';
import 'package:l_key/features/settings/presentation/settings_page.dart';
import 'package:l_key/features/songs/presentation/song_detail_page.dart';
import 'package:l_key/features/songs/presentation/songs_page.dart';
import 'package:l_key/features/tools/presentation/tools_page.dart';
import 'package:l_key/features/tuner/presentation/tuner_page.dart';

/// Builds the application router.
///
/// Every key and route is constructed inside this function rather than at the
/// top level. `StatefulShellRoute` owns a private `GlobalKey`, so a hoisted
/// route tree would make two live routers collide — which shows up only in
/// tests, never in the running app.
///
/// Every detail screen pushes on the **root** navigator, so it takes the whole
/// screen with a back control and no bottom bar. Their paths still sit under
/// the section that owns them, which is what makes a deep link to
/// `/tools/tuner` build Tools underneath the tuner and land there on back.
/// See ADR-0014, which supersedes ADR-0007's chrome table.
GoRouter createRouter({Environment environment = Environment.local}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.homeName,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.tools,
                name: AppRoutes.toolsName,
                builder: (context, state) => const ToolsPage(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'tuner',
                    name: AppRoutes.tunerName,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const TunerPage(),
                  ),
                  GoRoute(
                    path: 'metronome',
                    name: AppRoutes.metronomeName,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const MetronomePage(),
                  ),
                  GoRoute(
                    path: 'chords',
                    name: AppRoutes.chordsName,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ChordsPage(),
                    routes: <RouteBase>[
                      // Declared before ':chordId', which would otherwise
                      // swallow it.
                      GoRoute(
                        path: 'analyzer',
                        name: AppRoutes.chordAnalyzerName,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => const ChordAnalyzerPage(),
                      ),
                      GoRoute(
                        path: ':chordId',
                        name: AppRoutes.chordDetailName,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => ChordDetailPage(
                          chordId: state.pathParameters['chordId'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'fretboard',
                    name: AppRoutes.fretboardName,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const FretboardPage(),
                  ),
                  GoRoute(
                    path: 'scales',
                    name: AppRoutes.scalesName,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ScalesPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.songs,
                name: AppRoutes.songsName,
                builder: (context, state) => const SongsPage(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':songId',
                    name: AppRoutes.songDetailName,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => SongDetailPage(
                      songId: state.pathParameters['songId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.profileName,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        builder: (context, state) => const SettingsPage(),
      ),

      // The design-token showcase is a developer surface, not a product one.
      // Environment.allowsDeveloperTools exists for exactly this and was
      // previously documented but never actually applied.
      if (environment.allowsDeveloperTools)
        GoRoute(
          path: AppRoutes.foundation,
          name: AppRoutes.foundationName,
          builder: (context, state) => const FoundationPage(),
        ),
    ],
  );
}
