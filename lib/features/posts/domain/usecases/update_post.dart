import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdatePost extends UseCase<Post, UpdatePostParams> {
  const UpdatePost(this._repository);

  final PostRepository _repository;

  @override
  Future<Either<Failure, Post>> call(UpdatePostParams params) {
    return _repository.updatePost(params.post);
  }
}

class UpdatePostParams {
  const UpdatePostParams({required this.post});

  final Post post;
}
