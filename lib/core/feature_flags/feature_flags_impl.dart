import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/feature_flags/feature_flag.dart';
import 'package:flutter_enterprise_starter_kit/core/feature_flags/feature_flags.dart';
import 'package:hive_ce/hive.dart';

class FeatureFlagsImpl implements FeatureFlags {
  FeatureFlagsImpl(this._remoteConfig, this._overridesBox);

  final FirebaseRemoteConfig _remoteConfig;

  /// Hive stores primitives natively, so each override is just `flag.name`
  /// -> `bool`, no generated `TypeAdapter` needed.
  final Box<bool> _overridesBox;

  @override
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: FlavorConfig.isDevelopment
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );
    await _remoteConfig.setDefaults({
      for (final flag in FeatureFlag.values)
        flag.remoteConfigKey: flag.defaultValue,
    });

    // Runs in the background so a slow/offline network never delays
    // `runApp()` — `isEnabled()` already has the defaults set above to fall
    // back on until this completes.
    unawaited(_fetchAndActivate());
  }

  Future<void> _fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } on Object catch (error, stackTrace) {
      debugPrint('Feature flags fetch failed: $error\n$stackTrace');
    }
  }

  @override
  bool isEnabled(FeatureFlag flag) =>
      _overridesBox.get(flag.name) ??
      _remoteConfig.getBool(flag.remoteConfigKey);

  @override
  bool? overrideFor(FeatureFlag flag) => _overridesBox.get(flag.name);

  @override
  Future<void> setOverride(FeatureFlag flag, {required bool? value}) async {
    if (value == null) {
      await _overridesBox.delete(flag.name);
    } else {
      await _overridesBox.put(flag.name, value);
    }
  }
}
