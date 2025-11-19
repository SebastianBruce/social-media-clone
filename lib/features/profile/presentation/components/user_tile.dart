import 'package:flutter/material.dart';
import 'package:social_media_clone/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_clone/features/profile/presentation/components/profile_avatar.dart';
import 'package:social_media_clone/features/profile/presentation/pages/profile_page.dart';

class UserTile extends StatelessWidget {
  final ProfileUser user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text("@${user.username}"),
      subtitleTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
      leading: // profile picture
      SizedBox(
        width: 40,
        height: 40,
        child: ProfileAvatar(imageUrl: user.profileImageUrl),
      ),

      trailing: Icon(
        Icons.arrow_forward,
        color: Theme.of(context).colorScheme.primary,
      ),

      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(uid: user.uid)),
      ),
    );
  }
}
