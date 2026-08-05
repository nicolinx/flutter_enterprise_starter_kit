import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetPost extends UseCase<Post, GetPostParams> {
  const GetPost(this._repository);

  final PostRepository _repository;

  @override
  Future<Either<Failure, Post>> call(GetPostParams params) {
    return _repository.getPost(params.id);
  }
}

class GetPostParams {
  const GetPostParams({required this.id});

  final int id;
}
