// lib\features\profile\presentation\components\follow_button.dart

/*

FOLLOW BUTTON

This is a follow / unfollow button.

----------------------------------------------------------------------------------------------

To use this widget, you need:

- a function ( e.g. toggleFollow() ) ,
— isFollowing ( e.g. false —> then we will show follow button instead of unfollow button)
- optional: isBlocked (true -> show "Unblock" button)

*/

import 'package:flutter/material.dart';

class ProfileActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool? isFollowing; // null if it's an edit button
  final bool isBlocked; // new: true = show "Unblock"

  const ProfileActionButton({
    super.key,
    required this.onPressed,
    this.isFollowing,
    this.isBlocked = false, // default false
  });

  @override
  Widget build(BuildContext context) {
    final bool isEdit = isFollowing == null;

    // determine button text and color based on state
    String buttonText;
    Color buttonColor;

    if (isEdit) {
      // edit profile button
      buttonText = "Edit Profile";
      buttonColor = Theme.of(context).colorScheme.primary;
    } else if (isBlocked) {
      // blocked user -> show "Unblock"
      buttonText = "Unblock";
      buttonColor = Colors.grey;
    } else {
      // follow/unfollow button
      buttonText = isFollowing! ? "Unfollow" : "Follow";
      buttonColor = isFollowing!
          ? Theme.of(context).colorScheme.primary
          : Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          onPressed: onPressed,
          padding: const EdgeInsets.all(25),
          color: buttonColor,
          child: Text(
            buttonText,
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
