import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/get_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit(this._getPost) : super(const PostDetailState.loading());

  final GetPost _getPost;

  Future<void> load(int id) async {
    emit(const PostDetailState.loading());
    final result = await _getPost(GetPostParams(id: id));
    result.match(
      (failure) => emit(PostDetailState.error(_messageFor(failure))),
      (post) => emit(PostDetailState.loaded(post)),
    );
  }

  String _messageFor(Failure failure) => failure.map(
    server: (f) => f.message,
    network: (f) => f.message,
    cache: (f) => f.message,
    unexpected: (f) => f.message,
  );
}
