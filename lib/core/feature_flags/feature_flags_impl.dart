import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/feature_flags/feature_flag.dart';
import 'package:flutter_enterprise_starter_kit/core/feature_flags/feature_flags.dart';
import 'package:hive_ce/hive.dart';

class FeatureFlagsImpl implements FeatureFlags {
  FeatureFlagsImpl(this._remoteConfig, this._overridesBox);

  final FirebaseRemoteConfig _remoteConfig;

  /// Hive stores primitives natively, so each override is just `flag.name`
  /// -> `bool`, no generated `TypeAdapter` needed.
  final Box<dynamic> _overridesBox;

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

    try {
      await _remoteConfig.fetchAndActivate();
    } on Exception {
      // If the fetch fails, just keep using the defaults set above instead
      // of blocking app startup.
    }
  }

  @override
  bool isEnabled(FeatureFlag flag) {
    final override = _overridesBox.get(flag.name) as bool?;
    if (override != null) return override;
    return _remoteConfig.getBool(flag.remoteConfigKey);
  }

  @override
  Future<void> setOverride(FeatureFlag flag, {required bool? value}) async {
    if (value == null) {
      await _overridesBox.delete(flag.name);
    } else {
      await _overridesBox.put(flag.name, value);
    }
  }
}
