import 'package:flutter_enterprise_starter_kit/core/feature_flags/feature_flag.dart';

/// Lets app code check feature flags without knowing they come from Firebase
/// Remote Config — so the backend could be swapped out later.
abstract class FeatureFlags {
  /// Fetches the latest flag values. Call this once, during `bootstrap()`,
  /// before checking any flag.
  Future<void> initialize();

  bool isEnabled(FeatureFlag flag);

  /// The current local override for [flag], or `null` if none is set (the
  /// flag is following its remote/default value).
  bool? overrideFor(FeatureFlag flag);

  /// Forces a flag to a value on this device, ignoring the remote value.
  /// Pass `null` to remove the override and go back to using the remote
  /// (or default) value.
  Future<void> setOverride(FeatureFlag flag, {required bool? value});
}
