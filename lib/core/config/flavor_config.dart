enum Flavor { development, production }

/// Holds the environment the app was launched with, set once by the
/// `main_*.dart` entrypoint before `bootstrap()` runs. Everything
/// flavor-dependent (API base URL, app name, Firebase project) reads from
/// this single source of truth instead of scattering `--dart-define` reads
/// throughout the codebase.
class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
  });

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError(
        'FlavorConfig has not been initialized. Call FlavorConfig.initialize() '
        'from a main_*.dart entrypoint before running the app.',
      );
    }
    return instance;
  }

  final Flavor flavor;
  final String appName;
  final String apiBaseUrl;

  static bool get isDevelopment => instance.flavor == Flavor.development;
  static bool get isProduction => instance.flavor == Flavor.production;

  static void initialize({
    required Flavor flavor,
    required String appName,
    required String apiBaseUrl,
  }) {
    _instance = FlavorConfig._(
      flavor: flavor,
      appName: appName,
      apiBaseUrl: apiBaseUrl,
    );
  }
}
