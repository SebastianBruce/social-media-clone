import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media_clone/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_clone/features/profile/presentation/pages/profile_page.dart';

class UserTile extends StatelessWidget {
  final ProfileUser user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email),
      subtitleTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
      leading: // profile picture
      CachedNetworkImage(
        imageUrl: user.profileImageUrl,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(
          Icons.person,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        imageBuilder: (context, imageProvider) => Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
          ),
        ),
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
