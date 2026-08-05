import 'package:dio/dio.dart';
import 'package:flutter_enterprise_starter_kit/core/error/exceptions.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();

  Future<PostModel> getPost(int id);

  Future<PostModel> createPost(PostModel post);

  Future<PostModel> updatePost(PostModel post);

  Future<void> deletePost(int id);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  PostRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<PostModel>> getPosts() => _run(() async {
    final response = await _dio.get<List<dynamic>>('/posts');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(PostModel.fromJson)
        .toList();
  });

  @override
  Future<PostModel> getPost(int id) => _run(() async {
    final response = await _dio.get<Map<String, dynamic>>('/posts/$id');
    return PostModel.fromJson(response.data!);
  });

  @override
  Future<PostModel> createPost(PostModel post) => _run(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/posts',
      data: post.toJson()..remove('id'),
    );
    return PostModel.fromJson(response.data!);
  });

  @override
  Future<PostModel> updatePost(PostModel post) => _run(() async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/posts/${post.id}',
      data: post.toJson(),
    );
    return PostModel.fromJson(response.data!);
  });

  @override
  Future<void> deletePost(int id) => _run(() async {
    await _dio.delete<void>('/posts/$id');
  });

  /// `ErrorInterceptor` (see core/network) rethrows every `DioException` with
  /// our own typed exception stashed in `.error`, rather than throwing that
  /// exception directly. Unwrapping it here is what lets everything above
  /// this data source keep treating "data sources only throw typed
  /// exceptions" as a hard rule.
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      switch (e.error) {
        case final ServerException error:
          throw error;
        case final NetworkException error:
          throw error;
        default:
          throw const ServerException();
      }
    }
  }
}
