import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/theme/app_text_styles.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_state.dart';

/// Landing page shown once signed in. Proves DI/router/theme/auth are wired
/// together end-to-end — the `posts` feature will add real content here.
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
          ],
        ),
      ),
    );
  }
}
