import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a `Stream` (here, `AuthCubit.stream`) to `Listenable`, so
/// `GoRouter`'s `refreshListenable` re-evaluates `redirect` whenever auth
/// state changes. This is the standard go_router recipe for driving
/// redirects off a Cubit/Bloc instead of a `ChangeNotifier`.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
