import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/shared/widgets/lk_bottom_nav_bar.dart';
import 'package:l_key/shared/widgets/lk_icon_button.dart';
import 'package:l_key/shared/widgets/lk_top_app_bar.dart';

/// The five branch roots. Only these carry the top bar; anything pushed above
/// one of them is a full-screen surface.
const Set<String> _branchRoots = <String>{
  AppRoutes.home,
  AppRoutes.tools,
  AppRoutes.learn,
  AppRoutes.songs,
  AppRoutes.profile,
};

/// The persistent frame around the five primary sections.
///
/// Holds the bottom navigation and the top app bar so neither is rebuilt on a
/// tab switch, and keeps each section's navigation stack alive through
/// [StatefulNavigationShell].
class AppShell extends StatelessWidget {
  /// Creates the shell around [navigationShell].
  const AppShell({required this.navigationShell, super.key});

  /// The branch container supplied by `StatefulShellRoute`.
  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    // Tapping the active tab again returns it to its own root, which is what
    // a bottom bar is expected to do.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // The wordmark belongs to the five sections. A screen pushed inside a
    // branch -- a tool, a practice session -- takes the full height instead,
    // and returns to its section through the bar below or the system back
    // gesture.
    final isBranchRoot = _branchRoots.contains(
      GoRouterState.of(context).matchedLocation,
    );

    final destinations = <LkNavDestination>[
      LkNavDestination(icon: Icons.home_outlined, label: l10n.navHome),
      LkNavDestination(icon: Icons.tune, label: l10n.navTools),
      LkNavDestination(icon: Icons.school_outlined, label: l10n.navLearn),
      LkNavDestination(
        icon: Icons.library_music_outlined,
        label: l10n.navSongs,
      ),
      LkNavDestination(icon: Icons.person_outline, label: l10n.navProfile),
    ];

    return PopScope(
      // Android's back gesture should return to the first section before it
      // leaves the app. go_router pops within a branch but would otherwise
      // exit from any branch root.
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              if (isBranchRoot)
                LkTopAppBar(
                  title: l10n.appName,
                  trailing: LkIconButton(
                    icon: Icons.settings_outlined,
                    semanticLabel: l10n.commonSettings,
                    variant: LkIconButtonVariant.bare,
                    onPressed: () => context.pushNamed(AppRoutes.settingsName),
                  ),
                ),
              Expanded(child: navigationShell),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: LkBottomNavBar(
            destinations: destinations,
            currentIndex: navigationShell.currentIndex,
            onSelected: _select,
          ),
        ),
      ),
    );
  }
}
