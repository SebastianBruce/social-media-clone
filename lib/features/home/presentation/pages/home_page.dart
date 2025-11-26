import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_clone/features/auth/domain/entities/app_user.dart';
import 'package:social_media_clone/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_clone/features/post/presentation/components/post_tile.dart';
import 'package:social_media_clone/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_clone/features/post/presentation/cubits/post_states.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final authCubit = context.read<AuthCubit>();
  late final postCubit = context.read<PostCubit>();

  // current user
  late AppUser? currentUser = authCubit.currentUser;

  @override
  void initState() {
    super.initState();
    postCubit.fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoading || state is PostsUploading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PostsLoaded) {
          final allPosts = state.posts;
          if (allPosts.isEmpty) {
            return const Center(child: Text("No posts available"));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await postCubit.fetchAllPosts();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), // important
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];
                return PostTile(
                  key: ValueKey(post.id),
                  post: post,
                  onDeletePressed: () => postCubit.deletePost(post.id),
                  onReport: () => postCubit.reportPost(post, currentUser!),
                );
              },
            ),
          );
        } else if (state is PostsError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}
