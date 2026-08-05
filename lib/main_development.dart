import 'package:flutter_enterprise_starter_kit/bootstrap.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';

Future<void> main() async {
  FlavorConfig.initialize(
    flavor: Flavor.development,
    appName: 'Starter Kit (Dev)',
    // JSONPlaceholder: a public fake REST API. Real for reads; writes
    // (POST/PUT/DELETE) succeed but don't persist, see the `posts` feature.
    apiBaseUrl: 'https://jsonplaceholder.typicode.com',
  );

  await bootstrap();
}
