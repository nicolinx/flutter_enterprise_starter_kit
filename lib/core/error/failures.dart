import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Domain/presentation-facing representation of anything that can go wrong.
///
/// Data-layer code throws typed [Exception]s (see exceptions.dart);
/// repositories catch those and map them to a [Failure] before returning
/// `Either<Failure, T>` up to use cases and cubits, so nothing above the
/// data layer ever needs to know about Dio, sockets, or storage APIs.
@freezed
sealed class Failure with _$Failure {
  const factory Failure.server([
    @Default('A server error occurred') String message,
  ]) = ServerFailure;

  const factory Failure.network([
    @Default('No network connection') String message,
  ]) = NetworkFailure;

  const factory Failure.cache([
    @Default('A cache error occurred') String message,
  ]) = CacheFailure;

  const factory Failure.unexpected([
    @Default('An unexpected error occurred') String message,
  ]) = UnexpectedFailure;
}
