import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Base contract every domain use case implements: takes [Params], returns
/// either a [Failure] or the successful [ResultType], never throws.
abstract class UseCase<ResultType, Params> {
  const UseCase();

  Future<Either<Failure, ResultType>> call(Params params);
}

/// Marker params for use cases that don't need any input.
class NoParams {
  const NoParams();
}
