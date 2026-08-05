import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:fpdart/fpdart.dart';

abstract class PostRepository {
  /// Cache-aside: fetches from the network and refreshes the local cache
  /// when online; falls back to the last cached list when offline.
  Future<Either<Failure, List<Post>>> getPosts();

  Future<Either<Failure, Post>> getPost(int id);

  /// `post.id` is ignored; JSONPlaceholder assigns the id on create.
  Future<Either<Failure, Post>> createPost(Post post);

  Future<Either<Failure, Post>> updatePost(Post post);

  Future<Either<Failure, Unit>> deletePost(int id);
}
