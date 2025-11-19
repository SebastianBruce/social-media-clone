/*

FOLLOW BUTTON

This is a follow / unfollow button.

----------------------------------------------------------------------------------------------

To use this widget, you need:

- a function ( e.g. toggleFollow() ) ,
— isFollowing ( e.g. false —> then we will show follow button instead of unfollow button)

*/

import 'package:flutter/material.dart';

class ProfileActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool? isFollowing; // null if it's an edit button

  const ProfileActionButton({
    super.key,
    required this.onPressed,
    this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEdit = isFollowing == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          onPressed: onPressed,
          padding: const EdgeInsets.all(25),
          color: isEdit
              ? Theme.of(context)
                    .colorScheme
                    .primary // Edit button color (can adjust)
              : (isFollowing!
                    ? Theme.of(context).colorScheme.primary
                    : Colors.blue),
          child: Text(
            isEdit ? "Edit Profile" : (isFollowing! ? "Unfollow" : "Follow"),
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
