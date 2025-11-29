// lib\features\profile\presentation\pages\profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_clone/features/auth/domain/entities/app_user.dart';
import 'package:social_media_clone/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_clone/features/post/presentation/components/post_tile.dart';
import 'package:social_media_clone/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_clone/features/post/presentation/cubits/post_states.dart';
import 'package:social_media_clone/features/profile/presentation/components/bio_box.dart';
import 'package:social_media_clone/features/profile/presentation/components/follow_button.dart';
import 'package:social_media_clone/features/profile/presentation/components/profile_avatar.dart';
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

    // Check if this profile has blocked the current user
    return FutureBuilder<bool>(
      future: profileCubit.isUserBlocked(widget.uid, currentUser!.uid),
      builder: (context, blockedSnapshot) {
        final isBlockedByUser = blockedSnapshot.data ?? false;

        if (isBlockedByUser) {
          // HIDE all info if the profile has blocked the current user
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: Center(
              child: Text(
                "This user has blocked you.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        // Otherwise, show the normal profile
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
                      icon: const Icon(Icons.logout),
                      onPressed: () => context.read<AuthCubit>().logout(),
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

                  return RefreshIndicator(
                    onRefresh: () async {
                      await Future.wait([
                        profileCubit.fetchUserProfile(widget.uid),
                        context.read<PostCubit>().fetchAllPosts(),
                      ]);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        // email
                        Center(
                          child: Text(
                            "@${user.username}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // profile picture
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ProfileAvatar(imageUrl: user.profileImageUrl),
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
                              profileCubit.fetchUserProfile(widget.uid);
                            });
                          },
                        ),

                        const SizedBox(height: 25),

                        // FOLLOW / EDIT / UNBLOCK BUTTON
                        isOwnProfile
                            ? ProfileActionButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditProfilePage(user: user),
                                    ),
                                  );
                                },
                              )
                            : FutureBuilder<bool>(
                                // check if current user has blocked this profile
                                future: profileCubit.isUserBlocked(
                                  currentUser!.uid,
                                  user.uid,
                                ),
                                builder: (context, snapshot) {
                                  final isBlocked = snapshot.data ?? false;

                                  return ProfileActionButton(
                                    onPressed: () async {
                                      if (isBlocked) {
                                        // if blocked, unblock (reload profile after)
                                        await profileCubit.toggleBlockUser(
                                          currentUser!.uid,
                                          user.uid,
                                        );
                                        profileCubit.fetchUserProfile(
                                          widget.uid,
                                        );
                                      } else {
                                        // else toggle follow/unfollow (optimistic update)
                                        followButtonPressed();
                                      }
                                    },
                                    // show "Unblock" button if blocked
                                    isBlocked: isBlocked,
                                    isFollowing: user.followers.contains(
                                      currentUser!.uid,
                                    ),
                                  );
                                },
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

                        // posts ListView
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
                                onDeletePressed: () => context
                                    .read<PostCubit>()
                                    .deletePost(post.id),
                                onReport: () => context
                                    .read<PostCubit>()
                                    .reportPost(post, currentUser!),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
