import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_enterprise_starter_kit/app.dart';
import 'package:flutter_enterprise_starter_kit/core/di/injection.dart';

/// Shared entrypoint every `main_*.dart` calls after configuring
/// `FlavorConfig`. Keeping this separate from `main()` means the only thing
/// that differs between flavors is the flavor configuration itself.
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await configureDependencies();
      runApp(const App());
    },
    (error, stackTrace) {
      debugPrint('Uncaught error: $error\n$stackTrace');
    },
  );
}
