import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/di/injection.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/domain/entities/post.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_detail_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_detail_state.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_form_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/posts/presentation/cubit/post_form_state.dart';

/// Handles both create (`id == null`) and edit (`id` provided). For edit,
/// the existing post is fetched by id (via `PostDetailCubit`) rather than
/// relying on data passed through navigation, so a direct/deep link to the
/// edit route works the same as navigating from the detail page.
class PostFormPage extends StatelessWidget {
  const PostFormPage({super.key, this.id});

  final int? id;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<PostFormCubit>()),
        if (id != null)
          BlocProvider(
            create: (_) {
              final cubit = getIt<PostDetailCubit>();
              unawaited(cubit.load(id!));
              return cubit;
            },
          ),
      ],
      child: _PostFormView(id: id),
    );
  }
}

class _PostFormView extends StatefulWidget {
  const _PostFormView({required this.id});

  final int? id;

  @override
  State<_PostFormView> createState() => _PostFormViewState();
}

class _PostFormViewState extends State<_PostFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  Post? _editing;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    unawaited(
      context.read<PostFormCubit>().submit(
        title: _titleController.text,
        body: _bodyController.text,
        editing: _editing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.id != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit post' : 'New post')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PostFormCubit, PostFormState>(
            listener: (context, state) {
              if (state case PostFormSuccess()) {
                Navigator.of(context).pop();
              } else if (state case PostFormFailure(:final message)) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              }
            },
          ),
          if (isEditing)
            BlocListener<PostDetailCubit, PostDetailState>(
              listener: (context, state) {
                if (state case PostDetailLoaded(:final post)) {
                  setState(() {
                    _editing = post;
                    _titleController.text = post.title;
                    _bodyController.text = post.body;
                  });
                }
              },
            ),
        ],
        child: isEditing && _editing == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Title is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bodyController,
                        decoration: const InputDecoration(labelText: 'Body'),
                        minLines: 3,
                        maxLines: 6,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Body is required'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<PostFormCubit, PostFormState>(
                        builder: (context, state) {
                          final isSubmitting = state is PostFormSubmitting;
                          return FilledButton(
                            onPressed: isSubmitting
                                ? null
                                : () => _submit(context),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(isEditing ? 'Save' : 'Create'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
