import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_clone/features/profile/presentation/components/user_tile.dart';
import 'package:social_media_clone/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_clone/features/settings/data/firebase_settings_repo.dart';
import 'package:social_media_clone/responsive/constrained_scaffold.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TAB CONTROLLER
    return ConstrainedScaffold(
      // App bar
      appBar: AppBar(),

      body: StreamBuilder<List<String>>(
        stream: FirebaseSettingsRepo().streamBlockedUids(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final blockedUsers = snapshot.data!;
          return _buildUserList(blockedUsers, "No Blocked Users", context);
        },
      ),
    );
  }

  // build user list, given a list of profile uids
  Widget _buildUserList(
    List<String> uids,
    String emptyMessage,
    BuildContext context,
  ) {
    return uids.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
            itemCount: uids.length,
            itemBuilder: (context, index) {
              // get each uid
              final uid = uids[index];

              return FutureBuilder(
                future: context.read<ProfileCubit>().getUserProfile(uid),
                builder: (context, snapshot) {
                  // user loaded
                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    return UserTile(user: user);
                  }
                  // loaded..
                  else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(title: Text("Loading.."));
                  }
                  // not found..
                  else {
                    return ListTile(title: Text("User not found.."));
                  }
                },
              );
            },
          );
  }
}
