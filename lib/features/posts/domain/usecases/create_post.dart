import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreatePost extends UseCase<Post, CreatePostParams> {
  const CreatePost(this._repository);

  final PostRepository _repository;

  @override
  Future<Either<Failure, Post>> call(CreatePostParams params) {
    return _repository.createPost(
      Post(
        id: 0,
        userId: params.userId,
        title: params.title,
        body: params.body,
      ),
    );
  }
}

class CreatePostParams {
  const CreatePostParams({
    required this.userId,
    required this.title,
    required this.body,
  });

  final int userId;
  final String title;
  final String body;
}
