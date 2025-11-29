// lib\features\profile\domain\repos\profile_repo.dart

/*

Profile Repository

*/

import 'package:social_media_clone/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchUserProfile(String uid);
  Future<void> updateProfile(ProfileUser updatedProfile);
  Future<void> toggleFollow(String currentUid, String targetUid);
  Future<void> toggleBlockUser(String currentUid, String targetUid);
  Future<bool> isUserBlocked(String currentUid, String targetUid);
}
