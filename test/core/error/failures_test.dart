import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('same variant with same message are equal', () {
      expect(
        const Failure.server('boom'),
        equals(const Failure.server('boom')),
      );
    });

    test('same variant with different message are not equal', () {
      expect(
        const Failure.server('boom'),
        isNot(equals(const Failure.server('bang'))),
      );
    });

    test('different variants are not equal even with the same message', () {
      expect(
        const Failure.server('boom'),
        isNot(equals(const Failure.network('boom'))),
      );
    });

    test('default messages are non-empty', () {
      const failures = [
        Failure.server(),
        Failure.network(),
        Failure.cache(),
        Failure.unexpected(),
      ];

      for (final failure in failures) {
        failure.map(
          server: (f) => expect(f.message, isNotEmpty),
          network: (f) => expect(f.message, isNotEmpty),
          cache: (f) => expect(f.message, isNotEmpty),
          unexpected: (f) => expect(f.message, isNotEmpty),
        );
      }
    });
  });
}
