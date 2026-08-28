import 'package:go_router/go_router.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/features/foundation/presentation/foundation_page.dart';

/// Builds the application router.
///
/// Phase 01 registers only the foundation showcase. Product routes arrive with
/// their features, each owning its own route definition rather than growing a
/// single global list.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.foundation,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.foundation,
        name: AppRoutes.foundationName,
        builder: (context, state) => const FoundationPage(),
      ),
    ],
  );
}
