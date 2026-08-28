import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/shell/app_shell.dart';
import 'package:l_key/core/config/environment.dart';
import 'package:l_key/features/chords/presentation/chord_detail_page.dart';
import 'package:l_key/features/chords/presentation/chords_page.dart';
import 'package:l_key/features/foundation/presentation/foundation_page.dart';
import 'package:l_key/features/home/presentation/home_page.dart';
import 'package:l_key/features/learning/presentation/learn_page.dart';
import 'package:l_key/features/metronome/presentation/metronome_page.dart';
import 'package:l_key/features/practice/presentation/practice_page.dart';
import 'package:l_key/features/profile/presentation/profile_page.dart';
import 'package:l_key/features/scales/presentation/scales_page.dart';
import 'package:l_key/features/settings/presentation/settings_page.dart';
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
/// Detail screens sit under the section that owns them so a deep link
/// restores the right tab. `/settings` is the exception: it is reachable from
/// every section's top bar, so it is a sibling of the shell and pushes above
/// it. See ADR-0007.
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
                    builder: (context, state) => const TunerPage(),
                  ),
                  GoRoute(
                    path: 'metronome',
                    name: AppRoutes.metronomeName,
                    builder: (context, state) => const MetronomePage(),
                  ),
                  GoRoute(
                    path: 'chords',
                    name: AppRoutes.chordsName,
                    builder: (context, state) => const ChordsPage(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: ':chordId',
                        name: AppRoutes.chordDetailName,
                        builder: (context, state) => ChordDetailPage(
                          chordId: state.pathParameters['chordId'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'scales',
                    name: AppRoutes.scalesName,
                    builder: (context, state) => const ScalesPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.learn,
                name: AppRoutes.learnName,
                builder: (context, state) => const LearnPage(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'practice',
                    name: AppRoutes.practiceName,
                    builder: (context, state) => const PracticePage(),
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
