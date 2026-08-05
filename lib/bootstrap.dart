import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_enterprise_starter_kit/app.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/di/injection.dart';
import 'package:flutter_enterprise_starter_kit/firebase_options_development.dart'
    as dev;
import 'package:flutter_enterprise_starter_kit/firebase_options_production.dart'
    as prod;

/// Shared entrypoint every `main_*.dart` calls after configuring
/// `FlavorConfig`. Keeping this separate from `main()` means the only thing
/// that differs between flavors is the flavor configuration itself.
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(options: _firebaseOptionsForFlavor());
      await configureDependencies();
      runApp(App());
    },
    (error, stackTrace) {
      debugPrint('Uncaught error: $error\n$stackTrace');
    },
  );
}

FirebaseOptions _firebaseOptionsForFlavor() {
  return switch (FlavorConfig.instance.flavor) {
    Flavor.development => dev.DefaultFirebaseOptions.currentPlatform,
    Flavor.production => prod.DefaultFirebaseOptions.currentPlatform,
  };
}
