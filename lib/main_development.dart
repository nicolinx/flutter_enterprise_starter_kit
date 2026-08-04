import 'package:flutter_enterprise_starter_kit/bootstrap.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';

Future<void> main() async {
  FlavorConfig.initialize(
    flavor: Flavor.development,
    appName: 'Starter Kit (Dev)',
    // Placeholder REST backend for the `posts` feature; swap for a real
    // API when that feature is implemented.
    apiBaseUrl: 'https://jsonplaceholder.typicode.com',
  );

  await bootstrap();
}
