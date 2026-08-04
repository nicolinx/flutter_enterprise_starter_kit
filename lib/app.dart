import 'package:flutter/material.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/router/app_router.dart';
import 'package:flutter_enterprise_starter_kit/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: FlavorConfig.instance.appName,
      debugShowCheckedModeBanner: FlavorConfig.isDevelopment,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
