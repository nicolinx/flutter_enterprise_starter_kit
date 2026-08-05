import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_form_state.freezed.dart';

@freezed
sealed class PostFormState with _$PostFormState {
  const factory PostFormState.initial() = PostFormInitial;
  const factory PostFormState.submitting() = PostFormSubmitting;
  const factory PostFormState.success(Post post) = PostFormSuccess;
  const factory PostFormState.failure(String message) = PostFormFailure;
}
