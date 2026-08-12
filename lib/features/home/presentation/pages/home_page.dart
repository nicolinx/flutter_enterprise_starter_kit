import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/di/injection.dart';
import 'package:flutter_enterprise_starter_kit/core/feature_flags/feature_flag.dart';
import 'package:flutter_enterprise_starter_kit/core/feature_flags/feature_flags.dart';
import 'package:flutter_enterprise_starter_kit/core/router/route_paths.dart';
import 'package:flutter_enterprise_starter_kit/core/theme/app_text_styles.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_state.dart';
import 'package:go_router/go_router.dart';

/// Landing page shown once signed in. Proves DI/router/theme/auth are wired
/// together end-to-end, and links into the `posts` feature.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlavorConfig.instance.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
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
            const SizedBox(height: 8),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) => Text(
                switch (state) {
                  AuthAuthenticated(:final user) =>
                    'Signed in as ${user.email}',
                  _ => 'Not signed in',
                },
                style: AppTextStyles.caption(context),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.push(RoutePaths.posts),
              child: const Text('View posts'),
            ),
            const SizedBox(height: 24),
            const _FeatureFlagBanner(),
          ],
        ),
      ),
    );
  }
}

/// Demonstrates `core/feature_flags/`: shows a banner when
/// [FeatureFlag.homeBanner] is enabled, plus (dev flavor only) a local
/// override switch so the flag can be flipped without any Firebase Remote
/// Config console setup.
class _FeatureFlagBanner extends StatefulWidget {
  const _FeatureFlagBanner();

  @override
  State<_FeatureFlagBanner> createState() => _FeatureFlagBannerState();
}

class _FeatureFlagBannerState extends State<_FeatureFlagBanner> {
  bool _isEnabled = getIt<FeatureFlags>().isEnabled(FeatureFlag.homeBanner);

  Future<void> _toggleOverride(bool value) async {
    await getIt<FeatureFlags>().setOverride(
      FeatureFlag.homeBanner,
      value: value,
    );
    setState(() => _isEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isEnabled) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'This banner is controlled by a feature flag.',
                style: AppTextStyles.body(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (FlavorConfig.isDevelopment)
          SwitchListTile(
            title: const Text('home_banner override (dev only)'),
            value: _isEnabled,
            onChanged: _toggleOverride,
          ),
      ],
    );
  }
}
