import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetPosts extends UseCase<List<Post>, NoParams> {
  const GetPosts(this._repository);

  final PostRepository _repository;

  @override
  Future<Either<Failure, List<Post>>> call(NoParams params) {
    return _repository.getPosts();
  }
}
