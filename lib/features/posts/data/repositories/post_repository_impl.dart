import 'package:flutter_enterprise_starter_kit/core/error/exceptions.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/network/network_info.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/datasources/post_local_data_source.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/models/post_model.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/repositories/post_repository.dart';
import 'package:fpdart/fpdart.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final PostRemoteDataSource _remoteDataSource;
  final PostLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    if (await _networkInfo.isConnected) {
      try {
        final posts = await _remoteDataSource.getPosts();
        await _localDataSource.cachePosts(posts);
        return Right(posts.map((post) => post.toDomain()).toList());
      } on ServerException catch (e) {
        return Left(Failure.server(e.message));
      } on NetworkException catch (e) {
        return Left(Failure.network(e.message));
      }
    }

    try {
      final posts = await _localDataSource.getLastPosts();
      return Right(posts.map((post) => post.toDomain()).toList());
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    }
  }

  @override
  Future<Either<Failure, Post>> getPost(int id) => _guard(
    () async => (await _remoteDataSource.getPost(id)).toDomain(),
  );

  @override
  Future<Either<Failure, Post>> createPost(Post post) => _guard(() async {
    final created = await _remoteDataSource.createPost(
      PostModel.fromDomain(post),
    );
    return created.toDomain();
  });

  @override
  Future<Either<Failure, Post>> updatePost(Post post) => _guard(() async {
    final updated = await _remoteDataSource.updatePost(
      PostModel.fromDomain(post),
    );
    return updated.toDomain();
  });

  @override
  Future<Either<Failure, Unit>> deletePost(int id) => _guard(() async {
    await _remoteDataSource.deletePost(id);
    return unit;
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } on NetworkException catch (e) {
      return Left(Failure.network(e.message));
    }
  }
}
