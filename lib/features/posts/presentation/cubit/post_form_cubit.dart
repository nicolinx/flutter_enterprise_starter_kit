import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/create_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/update_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_form_state.dart';

/// Demo user id attached to posts created through this app; JSONPlaceholder
/// requires a `userId` but doesn't have a real concept of "the current user"
/// for writes.
const _demoUserId = 1;

class PostFormCubit extends Cubit<PostFormState> {
  PostFormCubit(this._createPost, this._updatePost)
    : super(const PostFormState.initial());

  final CreatePost _createPost;
  final UpdatePost _updatePost;

  Future<void> submit({
    required String title,
    required String body,
    Post? editing,
  }) async {
    emit(const PostFormState.submitting());

    final result = await switch (editing) {
      null => _createPost(
        CreatePostParams(userId: _demoUserId, title: title, body: body),
      ),
      final post => _updatePost(
        UpdatePostParams(post: post.copyWith(title: title, body: body)),
      ),
    };

    result.match(
      (failure) => emit(PostFormState.failure(_messageFor(failure))),
      (post) => emit(PostFormState.success(post)),
    );
  }

  String _messageFor(Failure failure) => failure.map(
    server: (f) => f.message,
    network: (f) => f.message,
    cache: (f) => f.message,
    unexpected: (f) => f.message,
  );
}
