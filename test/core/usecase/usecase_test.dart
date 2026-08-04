import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _FakeUseCase extends Mock implements UseCase<String, NoParams> {}

void main() {
  group('UseCase', () {
    late _FakeUseCase useCase;

    setUp(() {
      useCase = _FakeUseCase();
    });

    test('returns Right on success', () async {
      when(
        () => useCase.call(const NoParams()),
      ).thenAnswer((_) async => const Right('ok'));

      final result = await useCase.call(const NoParams());

      expect(result, const Right<Failure, String>('ok'));
    });

    test('returns Left on failure', () async {
      when(
        () => useCase.call(const NoParams()),
      ).thenAnswer((_) async => const Left(Failure.server('boom')));

      final result = await useCase.call(const NoParams());

      expect(result, const Left<Failure, String>(Failure.server('boom')));
    });
  });
}
