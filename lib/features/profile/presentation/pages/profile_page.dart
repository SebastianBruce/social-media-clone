import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_clone/features/auth/domain/entities/app_user.dart';
import 'package:social_media_clone/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_clone/features/post/components/post_tile.dart';
import 'package:social_media_clone/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_clone/features/post/presentation/cubits/post_states.dart';
import 'package:social_media_clone/features/profile/presentation/components/bio_box.dart';
import 'package:social_media_clone/features/profile/presentation/components/follow_button.dart';
import 'package:social_media_clone/features/profile/presentation/components/profile_stats.dart';
import 'package:social_media_clone/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_clone/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media_clone/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:social_media_clone/features/profile/presentation/pages/follower_page.dart';
import 'package:social_media_clone/responsive/constrained_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  // current user
  late AppUser? currentUser = authCubit.currentUser;

  @override
  void initState() {
    super.initState();
    profileCubit.fetchUserProfile(widget.uid);
  }

  /* FOLLOW / UNFOLLOW */
  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) return;

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // optimistic update
    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    // actual toggle
    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((_) {
      // revert on failure
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        } else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnProfile = widget.uid == currentUser!.uid;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // profile loading...
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // no profile found
        if (state is! ProfileLoaded) {
          return const Scaffold(
            body: Center(child: Text("No profile found..")),
          );
        }

        // profile loaded
        final user = state.profileUser;

        // SCAFFOLD
        return ConstrainedScaffold(
          //APP BAR
          appBar: AppBar(
            title: Text(user.name),
            foregroundColor: Theme.of(context).colorScheme.primary,
            actions: [
              if (isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: user),
                    ),
                  ),
                ),
            ],
          ),

          // BODY
          body: BlocBuilder<PostCubit, PostState>(
            builder: (context, postState) {
              List userPosts = [];

              if (postState is PostsLoaded) {
                userPosts = postState.posts
                    .where((post) => post.userId == widget.uid)
                    .toList();
              }

              return ListView(
                children: [
                  // email
                  Center(
                    child: Text(
                      user.email,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // profile picture
                  CachedNetworkImage(
                    imageUrl: user.profileImageUrl,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    imageBuilder: (context, imageProvider) => Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // stats
                  ProfileStats(
                    postCount: userPosts.length,
                    followerCount: user.followers.length,
                    followingCount: user.following.length,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FollowerPage(
                            followers: user.followers,
                            following: user.following,
                          ),
                        ),
                      ).then((_) {
                        // REFRESH when returning from follower page
                        profileCubit.fetchUserProfile(widget.uid);
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  // follow button
                  if (!isOwnProfile)
                    FollowButton(
                      onPressed: followButtonPressed,
                      isFollowing: user.followers.contains(currentUser!.uid),
                    ),

                  const SizedBox(height: 25),

                  // bio
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "Bio",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  BioBox(text: user.bio),

                  const SizedBox(height: 25),

                  // posts header
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "Posts",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // posts list
                  if (postState is PostsLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (userPosts.isEmpty)
                    const Center(child: Text("No posts..."))
                  else
                    ListView.builder(
                      itemCount: userPosts.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final post = userPosts[index];
                        return PostTile(
                          post: post,
                          onDeletePressed: () =>
                              context.read<PostCubit>().deletePost(post.id),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
