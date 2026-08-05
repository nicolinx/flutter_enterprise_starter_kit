import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

/// Domain representation of a post. Mirrors JSONPlaceholder's `/posts`
/// resource shape, but this class itself knows nothing about JSON or Dio,
/// that's `PostModel`'s job (see data/models/post_model.dart).
@freezed
sealed class Post with _$Post {
  const factory Post({
    required int id,
    required int userId,
    required String title,
    required String body,
  }) = _Post;
}
