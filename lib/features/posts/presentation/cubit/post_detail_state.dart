import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_detail_state.freezed.dart';

@freezed
sealed class PostDetailState with _$PostDetailState {
  const factory PostDetailState.loading() = PostDetailLoading;
  const factory PostDetailState.loaded(Post post) = PostDetailLoaded;
  const factory PostDetailState.error(String message) = PostDetailError;
}
