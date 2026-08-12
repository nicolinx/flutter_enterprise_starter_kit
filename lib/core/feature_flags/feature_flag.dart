/// Single typed registry of every feature flag in the app. App code always
/// references a flag through this enum, never a raw Remote Config string key.
enum FeatureFlag {
  homeBanner('home_banner', defaultValue: false);

  const FeatureFlag(this.remoteConfigKey, {required this.defaultValue});

  /// The parameter key configured in the Firebase Remote Config console.
  final String remoteConfigKey;

  final bool defaultValue;
}
