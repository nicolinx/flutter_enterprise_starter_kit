import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/delete_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/get_posts.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/posts_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPosts extends Mock implements GetPosts {}

class _MockDeletePost extends Mock implements DeletePost {}

void main() {
  setUpAll(() {
    registerFallbackValue(const DeletePostParams(id: 0));
  });

  late _MockGetPosts getPosts;
  late _MockDeletePost deletePost;

  const posts = [
    Post(id: 1, userId: 1, title: 'One', body: 'Body one'),
    Post(id: 2, userId: 1, title: 'Two', body: 'Body two'),
  ];

  setUp(() {
    getPosts = _MockGetPosts();
    deletePost = _MockDeletePost();
  });

  blocTest<PostsCubit, PostsState>(
    'emits [loading, loaded] when load succeeds',
    build: () => PostsCubit(getPosts, deletePost),
    setUp: () {
      when(
        () => getPosts(const NoParams()),
      ).thenAnswer((_) async => const Right(posts));
    },
    act: (cubit) => cubit.load(),
    expect: () => const [PostsState.loading(), PostsState.loaded(posts)],
  );

  blocTest<PostsCubit, PostsState>(
    'emits [loading, error] when load fails',
    build: () => PostsCubit(getPosts, deletePost),
    setUp: () {
      when(() => getPosts(const NoParams())).thenAnswer(
        (_) async => const Left(Failure.network('offline, no cache')),
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => const [
      PostsState.loading(),
      PostsState.error('offline, no cache'),
    ],
  );

  blocTest<PostsCubit, PostsState>(
    'removes the deleted post from the loaded list',
    build: () => PostsCubit(getPosts, deletePost),
    seed: () => const PostsState.loaded(posts),
    setUp: () {
      when(() => deletePost(any())).thenAnswer((_) async => const Right(unit));
    },
    act: (cubit) => cubit.delete(1),
    expect: () => const [
      PostsState.loaded([
        Post(id: 2, userId: 1, title: 'Two', body: 'Body two'),
      ]),
    ],
  );
}
