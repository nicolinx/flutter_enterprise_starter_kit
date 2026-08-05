import 'package:dio/dio.dart';
import 'package:flutter_enterprise_starter_kit/core/di/injection.dart';
import 'package:flutter_enterprise_starter_kit/core/network/network_info.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/datasources/post_local_data_source.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/data/repositories/post_repository_impl.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/create_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/delete_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/get_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/get_posts.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/usecases/update_post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_detail_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_form_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

const postsCacheBoxName = 'posts_cache';

/// Registers everything the `posts` feature needs. Called (async, unlike
/// `configureAuthDependencies`) from `core/di/injection.dart`, since opening
/// the Hive box is itself async.
Future<void> configurePostsDependencies() async {
  await Hive.initFlutter();
  final box = await Hive.openBox<dynamic>(postsCacheBoxName);

  getIt
    ..registerLazySingleton<Box<dynamic>>(() => box)
    ..registerLazySingleton<PostRemoteDataSource>(
      () => PostRemoteDataSourceImpl(getIt<Dio>()),
    )
    ..registerLazySingleton<PostLocalDataSource>(
      () => PostLocalDataSourceImpl(getIt<Box<dynamic>>()),
    )
    ..registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(
        getIt<PostRemoteDataSource>(),
        getIt<PostLocalDataSource>(),
        getIt<NetworkInfo>(),
      ),
    )
    ..registerLazySingleton<GetPosts>(() => GetPosts(getIt<PostRepository>()))
    ..registerLazySingleton<GetPost>(() => GetPost(getIt<PostRepository>()))
    ..registerLazySingleton<CreatePost>(
      () => CreatePost(getIt<PostRepository>()),
    )
    ..registerLazySingleton<UpdatePost>(
      () => UpdatePost(getIt<PostRepository>()),
    )
    ..registerLazySingleton<DeletePost>(
      () => DeletePost(getIt<PostRepository>()),
    )
    ..registerFactory<PostsCubit>(
      () => PostsCubit(getIt<GetPosts>(), getIt<DeletePost>()),
    )
    ..registerFactory<PostDetailCubit>(
      () => PostDetailCubit(getIt<GetPost>()),
    )
    ..registerFactory<PostFormCubit>(
      () => PostFormCubit(getIt<CreatePost>(), getIt<UpdatePost>()),
    );
}
