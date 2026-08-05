import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/delete_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/get_posts.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  PostsCubit(this._getPosts, this._deletePost)
    : super(const PostsState.initial());

  final GetPosts _getPosts;
  final DeletePost _deletePost;

  Future<void> load() async {
    emit(const PostsState.loading());
    final result = await _getPosts(const NoParams());
    result.match(
      (failure) => emit(PostsState.error(_messageFor(failure))),
      (posts) => emit(PostsState.loaded(posts)),
    );
  }

  Future<void> delete(int id) async {
    final result = await _deletePost(DeletePostParams(id: id));
    result.match((failure) => emit(PostsState.error(_messageFor(failure))), (
      _,
    ) {
      final current = state;
      if (current is PostsLoaded) {
        emit(
          PostsState.loaded(
            current.posts.where((post) => post.id != id).toList(),
          ),
        );
      }
    });
  }

  String _messageFor(Failure failure) => failure.map(
    server: (f) => f.message,
    network: (f) => f.message,
    cache: (f) => f.message,
    unexpected: (f) => f.message,
  );
}
