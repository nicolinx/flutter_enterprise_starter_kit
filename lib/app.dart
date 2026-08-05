import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/di/injection.dart';
import 'package:flutter_enterprise_starter_kit/core/router/app_router.dart';
import 'package:flutter_enterprise_starter_kit/core/theme/app_theme.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_cubit.dart';

class App extends StatelessWidget {
  App({super.key}) : _authCubit = getIt<AuthCubit>();

  final AuthCubit _authCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: MaterialApp.router(
        title: FlavorConfig.instance.appName,
        debugShowCheckedModeBanner: FlavorConfig.isDevelopment,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: buildAppRouter(_authCubit),
      ),
    );
  }
}
