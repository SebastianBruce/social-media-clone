// lib\features\profile\data\firebase_profile_repo.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_clone/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_clone/features/profile/domain/repos/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final userDoc = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data();
      if (userData == null) return null;

      // Load followers subcollection
      final followersSnap = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('Followers')
          .get();

      // Load following subcollection
      final followingSnap = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('Following')
          .get();

      final followers = followersSnap.docs.map((d) => d.id).toList();
      final following = followingSnap.docs.map((d) => d.id).toList();

      return ProfileUser(
        uid: uid,
        email: userData['email'],
        name: userData['name'],
        username: userData['username'],
        bio: userData['bio'] ?? '',
        profileImageUrl: userData['profileImageUrl'] ?? "",
        followers: followers,
        following: following,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      // convert updated profile to json to store in firestore
      await firebaseFirestore
          .collection('users')
          .doc(updatedProfile.uid)
          .update({
            'bio': updatedProfile.bio,
            'profileImageUrl': updatedProfile.profileImageUrl,
          });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      final currentFollowingRef = firebaseFirestore
          .collection('users')
          .doc(currentUid)
          .collection('Following')
          .doc(targetUid);

      final targetFollowersRef = firebaseFirestore
          .collection('users')
          .doc(targetUid)
          .collection('Followers')
          .doc(currentUid);

      final doc = await currentFollowingRef.get();

      if (doc.exists) {
        // UNFOLLOW
        await currentFollowingRef.delete();
        await targetFollowersRef.delete();
      } else {
        // FOLLOW
        await currentFollowingRef.set({
          'createdAt': FieldValue.serverTimestamp(),
        });

        await targetFollowersRef.set({
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {}
  }

  // Block user
  @override
  Future<void> toggleBlockUser(String currentUid, String targetUid) async {
    try {
      final blockedRef = firebaseFirestore
          .collection('users')
          .doc(currentUid)
          .collection("BlockedUsers")
          .doc(targetUid);

      final doc = await blockedRef.get();

      if (doc.exists) {
        // UNBLOCK: remove from blocked list
        await blockedRef.delete();
      } else {
        // BLOCK: add to blocked list
        await blockedRef.set({'createdAt': FieldValue.serverTimestamp()});

        // remove target from current user's followers/following
        final currentFollowingRef = firebaseFirestore
            .collection('users')
            .doc(currentUid)
            .collection('Following')
            .doc(targetUid);
        final currentFollowersRef = firebaseFirestore
            .collection('users')
            .doc(currentUid)
            .collection('Followers')
            .doc(targetUid);

        await currentFollowingRef.delete();
        await currentFollowersRef.delete();

        // remove current user from target's followers/following
        final targetFollowingRef = firebaseFirestore
            .collection('users')
            .doc(targetUid)
            .collection('Following')
            .doc(currentUid);
        final targetFollowersRef = firebaseFirestore
            .collection('users')
            .doc(targetUid)
            .collection('Followers')
            .doc(currentUid);

        await targetFollowingRef.delete();
        await targetFollowersRef.delete();
      }
    } catch (e) {
      throw Exception("Failed to toggle block: $e");
    }
  }

  @override
  Future<bool> isUserBlocked(String currentUid, String targetUid) async {
    final doc = await firebaseFirestore
        .collection('users')
        .doc(currentUid)
        .collection('BlockedUsers')
        .doc(targetUid)
        .get();
    return doc.exists;
  }
}
