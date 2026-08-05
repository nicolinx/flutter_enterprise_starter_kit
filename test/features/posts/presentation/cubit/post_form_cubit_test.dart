import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/create_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/update_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_form_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_form_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockCreatePost extends Mock implements CreatePost {}

class _MockUpdatePost extends Mock implements UpdatePost {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CreatePostParams(userId: 0, title: '', body: ''),
    );
    registerFallbackValue(
      const UpdatePostParams(
        post: Post(id: 0, userId: 0, title: '', body: ''),
      ),
    );
  });

  late _MockCreatePost createPost;
  late _MockUpdatePost updatePost;

  const created = Post(id: 101, userId: 1, title: 'New', body: 'New body');
  const existing = Post(id: 1, userId: 1, title: 'Old', body: 'Old body');
  const updated = Post(id: 1, userId: 1, title: 'New', body: 'New body');

  setUp(() {
    createPost = _MockCreatePost();
    updatePost = _MockUpdatePost();
  });

  blocTest<PostFormCubit, PostFormState>(
    'create mode: emits [submitting, success] and calls CreatePost',
    build: () => PostFormCubit(createPost, updatePost),
    setUp: () {
      when(
        () => createPost(any()),
      ).thenAnswer((_) async => const Right(created));
    },
    act: (cubit) => cubit.submit(title: 'New', body: 'New body'),
    expect: () => const [
      PostFormState.submitting(),
      PostFormState.success(created),
    ],
    verify: (_) {
      verify(() => createPost(any())).called(1);
      verifyNever(() => updatePost(any()));
    },
  );

  blocTest<PostFormCubit, PostFormState>(
    'edit mode: emits [submitting, success] and calls UpdatePost',
    build: () => PostFormCubit(createPost, updatePost),
    setUp: () {
      when(
        () => updatePost(any()),
      ).thenAnswer((_) async => const Right(updated));
    },
    act: (cubit) =>
        cubit.submit(title: 'New', body: 'New body', editing: existing),
    expect: () => const [
      PostFormState.submitting(),
      PostFormState.success(updated),
    ],
    verify: (_) {
      verify(() => updatePost(any())).called(1);
      verifyNever(() => createPost(any()));
    },
  );

  blocTest<PostFormCubit, PostFormState>(
    'emits [submitting, failure] when the use case fails',
    build: () => PostFormCubit(createPost, updatePost),
    setUp: () {
      when(() => createPost(any())).thenAnswer(
        (_) async => const Left(Failure.server('validation failed')),
      );
    },
    act: (cubit) => cubit.submit(title: '', body: ''),
    expect: () => const [
      PostFormState.submitting(),
      PostFormState.failure('validation failed'),
    ],
  );
}
