import 'package:flutter_enterprise_starter_kit/core/error/exceptions.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/network/network_info.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/datasources/post_local_data_source.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/models/post_model.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/repositories/post_repository_impl.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteDataSource extends Mock implements PostRemoteDataSource {}

class _MockLocalDataSource extends Mock implements PostLocalDataSource {}

class _MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const PostModel(id: 0, userId: 0, title: '', body: ''),
    );
  });

  late _MockRemoteDataSource remoteDataSource;
  late _MockLocalDataSource localDataSource;
  late _MockNetworkInfo networkInfo;
  late PostRepositoryImpl repository;

  const postModel = PostModel(id: 1, userId: 1, title: 'Title', body: 'Body');
  const post = Post(id: 1, userId: 1, title: 'Title', body: 'Body');

  setUp(() {
    remoteDataSource = _MockRemoteDataSource();
    localDataSource = _MockLocalDataSource();
    networkInfo = _MockNetworkInfo();
    repository = PostRepositoryImpl(
      remoteDataSource,
      localDataSource,
      networkInfo,
    );
  });

  group('getPosts', () {
    test('online: fetches remote, caches it, returns domain posts', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.getPosts(),
      ).thenAnswer((_) async => [postModel]);
      when(() => localDataSource.cachePosts(any())).thenAnswer((_) async {});

      final result = await repository.getPosts();

      // A List has identity-based `==` by default, so comparing two
      // `Right(List<Post>)` instances directly would fail even when their
      // elements are equal; unwrap first and let `equals()` do deep list
      // comparison instead.
      result.match(
        (failure) => fail('expected Right, got Left($failure)'),
        (posts) => expect(posts, equals(const [post])),
      );
      verify(() => localDataSource.cachePosts([postModel])).called(1);
    });

    test('online: remote failure returns Left(Failure)', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.getPosts(),
      ).thenThrow(const ServerException('boom'));

      final result = await repository.getPosts();

      expect(
        result,
        equals(const Left<Failure, List<Post>>(Failure.server('boom'))),
      );
      verifyNever(() => localDataSource.cachePosts(any()));
    });

    test('offline: returns cached posts when available', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => localDataSource.getLastPosts(),
      ).thenAnswer((_) async => [postModel]);

      final result = await repository.getPosts();

      result.match(
        (failure) => fail('expected Right, got Left($failure)'),
        (posts) => expect(posts, equals(const [post])),
      );
      verifyNever(() => remoteDataSource.getPosts());
    });

    test('offline: returns Left(cache failure) when nothing cached', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => localDataSource.getLastPosts(),
      ).thenThrow(const CacheException('No cached posts available.'));

      final result = await repository.getPosts();

      expect(
        result,
        equals(
          const Left<Failure, List<Post>>(
            Failure.cache('No cached posts available.'),
          ),
        ),
      );
    });
  });

  group('getPost', () {
    test('returns Right(Post) on success', () async {
      when(
        () => remoteDataSource.getPost(1),
      ).thenAnswer((_) async => postModel);

      final result = await repository.getPost(1);

      expect(result, equals(const Right<Failure, Post>(post)));
    });

    test('returns Left(Failure) on exception', () async {
      when(
        () => remoteDataSource.getPost(1),
      ).thenThrow(const ServerException('not found'));

      final result = await repository.getPost(1);

      expect(
        result,
        equals(const Left<Failure, Post>(Failure.server('not found'))),
      );
    });
  });

  group('createPost', () {
    test('returns Right(Post) on success', () async {
      when(
        () => remoteDataSource.createPost(any()),
      ).thenAnswer((_) async => postModel);

      final result = await repository.createPost(post);

      expect(result, equals(const Right<Failure, Post>(post)));
    });
  });

  group('deletePost', () {
    test('returns Right(unit) on success', () async {
      when(() => remoteDataSource.deletePost(1)).thenAnswer((_) async {});

      final result = await repository.deletePost(1);

      expect(result, equals(const Right<Failure, Unit>(unit)));
    });

    test('returns Left(Failure) on exception', () async {
      when(
        () => remoteDataSource.deletePost(1),
      ).thenThrow(const NetworkException());

      final result = await repository.deletePost(1);

      expect(
        result,
        isA<Left<Failure, Unit>>().having(
          (l) => l.value,
          'failure',
          isA<NetworkFailure>(),
        ),
      );
    });
  });
}
