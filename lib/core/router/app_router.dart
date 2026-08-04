import 'package:flutter_enterprise_starter_kit/core/router/go_router_refresh_stream.dart';
import 'package:flutter_enterprise_starter_kit/core/router/route_paths.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_enterprise_starter_kit/features/home/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';

/// Single source of truth for app navigation. `redirect` reads `authCubit`
/// synchronously and re-runs whenever it emits (via `GoRouterRefreshStream`)
/// to gate `RoutePaths.root` behind sign-in.
GoRouter buildAppRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: RoutePaths.root,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      if (authState is AuthUnknown) return null;

      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthRoute =
          state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register;

      if (!isAuthenticated && !isAuthRoute) return RoutePaths.login;
      if (isAuthenticated && isAuthRoute) return RoutePaths.root;
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.root,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterPage(),
      ),
    ],
  );
}
