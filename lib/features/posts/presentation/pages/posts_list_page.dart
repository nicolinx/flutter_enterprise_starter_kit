import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/di/injection.dart';
import 'package:flutter_enterprise_starter_kit/core/router/route_paths.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/posts_state.dart';
import 'package:go_router/go_router.dart';

class PostsListPage extends StatelessWidget {
  const PostsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<PostsCubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: const _PostsListView(),
    );
  }
}

class _PostsListView extends StatelessWidget {
  const _PostsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.newPost),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<PostsCubit, PostsState>(
        builder: (context, state) {
          return switch (state) {
            PostsInitial() || PostsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            PostsError(:final message) => Center(child: Text(message)),
            PostsLoaded(:final posts) => RefreshIndicator(
              onRefresh: () => context.read<PostsCubit>().load(),
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return ListTile(
                    title: Text(post.title, maxLines: 1),
                    subtitle: Text(post.body, maxLines: 1),
                    onTap: () =>
                        context.push(RoutePaths.postDetailPath(post.id)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          context.read<PostsCubit>().delete(post.id),
                    ),
                  );
                },
              ),
            ),
          };
        },
      ),
    );
  }
}
