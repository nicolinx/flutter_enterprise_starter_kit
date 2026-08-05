import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeletePost extends UseCase<Unit, DeletePostParams> {
  const DeletePost(this._repository);

  final PostRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeletePostParams params) {
    return _repository.deletePost(params.id);
  }
}

class DeletePostParams {
  const DeletePostParams({required this.id});

  final int id;
}
