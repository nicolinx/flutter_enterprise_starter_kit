import 'package:flutter/material.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/presentation/pages/root_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    FlavorConfig.initialize(
      flavor: Flavor.development,
      appName: 'Starter Kit (Test)',
      apiBaseUrl: 'https://example.com',
    );
  });

  testWidgets('shows the app name and current flavor', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RootPage()));

    expect(find.text('Starter Kit (Test)'), findsOneWidget);
    expect(find.text('Flavor: development'), findsOneWidget);
  });
}
