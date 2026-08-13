import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/di/injection.dart';
import 'package:flutter_enterprise_starter_kit/core/feature_flags/feature_flags.dart';
import 'package:flutter_enterprise_starter_kit/core/router/route_paths.dart';
import 'package:flutter_enterprise_starter_kit/core/theme/app_text_styles.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_enterprise_starter_kit/features/home/presentation/cubit/home_banner_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/home/presentation/cubit/home_banner_state.dart';
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

/// Demonstrates `core/feature_flags/`: shows a banner when the flag is
/// enabled, plus (dev flavor only) a local override control so it can be
/// forced on/off, or reset to follow Remote Config, without any Firebase
/// console setup.
class _FeatureFlagBanner extends StatelessWidget {
  const _FeatureFlagBanner();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBannerCubit(getIt<FeatureFlags>()),
      child: const _FeatureFlagBannerView(),
    );
  }
}

class _FeatureFlagBannerView extends StatelessWidget {
  const _FeatureFlagBannerView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBannerCubit, HomeBannerState>(
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.isEnabled) ...[
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
          if (FlavorConfig.isDevelopment) ...[
            Text(
              'home_banner override (dev only)',
              style: AppTextStyles.caption(context),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool?>(
              segments: const [
                ButtonSegment(value: null, label: Text('Remote')),
                ButtonSegment(value: true, label: Text('Force on')),
                ButtonSegment(value: false, label: Text('Force off')),
              ],
              selected: {state.overrideValue},
              onSelectionChanged: (selection) =>
                  context.read<HomeBannerCubit>().setOverride(
                    value: selection.first,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
