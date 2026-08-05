import 'package:flutter_enterprise_starter_kit/core/error/exceptions.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/models/post_model.dart';
import 'package:hive_ce/hive.dart';

abstract class PostLocalDataSource {
  /// Throws [CacheException] if nothing has been cached yet.
  Future<List<PostModel>> getLastPosts();

  Future<void> cachePosts(List<PostModel> posts);
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  PostLocalDataSourceImpl(this._box);

  static const _cacheKey = 'cached_posts';

  /// Hive stores `List`/`Map`/primitive values natively, so each post is
  /// kept as its own `toJson()` map, no generated `TypeAdapter` needed.
  final Box<dynamic> _box;

  @override
  Future<List<PostModel>> getLastPosts() async {
    final cached = _box.get(_cacheKey) as List<dynamic>?;
    if (cached == null) {
      throw const CacheException('No cached posts available.');
    }
    return cached
        .cast<Map<dynamic, dynamic>>()
        .map((json) => PostModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    await _box.put(_cacheKey, posts.map((post) => post.toJson()).toList());
  }
}
