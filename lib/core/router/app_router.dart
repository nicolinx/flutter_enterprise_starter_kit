import 'package:flutter_enterprise_starter_kit/core/presentation/pages/root_page.dart';
import 'package:flutter_enterprise_starter_kit/core/router/route_paths.dart';
import 'package:go_router/go_router.dart';

/// Single source of truth for app navigation. Feature routes are added here
/// as they land; auth-gated redirects (once the auth feature exists) also
/// belong on this `GoRouter` instance via its `redirect` parameter.
final appRouter = GoRouter(
  initialLocation: RoutePaths.root,
  routes: [
    GoRoute(
      path: RoutePaths.root,
      builder: (context, state) => const RootPage(),
    ),
  ],
);
