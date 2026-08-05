import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/di/injection.dart';
import 'package:flutter_enterprise_starter_kit/core/router/route_paths.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_detail_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_detail_state.dart';
import 'package:go_router/go_router.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<PostDetailCubit>();
        unawaited(cubit.load(id));
        return cubit;
      },
      child: _PostDetailView(id: id),
    );
  }
}

class _PostDetailView extends StatelessWidget {
  const _PostDetailView({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(RoutePaths.editPostPath(id)),
          ),
        ],
      ),
      body: BlocBuilder<PostDetailCubit, PostDetailState>(
        builder: (context, state) {
          return switch (state) {
            PostDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            PostDetailError(:final message) => Center(child: Text(message)),
            PostDetailLoaded(:final post) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(post.body),
                ],
              ),
            ),
          };
        },
      ),
    );
  }
}
