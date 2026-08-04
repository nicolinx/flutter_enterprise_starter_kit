import 'package:flutter/material.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/theme/app_text_styles.dart';

/// Temporary landing page proving DI/router/theme are wired end-to-end.
/// Will be replaced by real navigation logic (redirect to auth, etc.) once
/// the auth feature lands.
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(FlavorConfig.instance.appName)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Foundation ready', style: AppTextStyles.title(context)),
            const SizedBox(height: 8),
            Text(
              'Flavor: ${FlavorConfig.instance.flavor.name}',
              style: AppTextStyles.body(context),
            ),
          ],
        ),
      ),
    );
  }
}
