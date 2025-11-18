import 'package:social_media_clone/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailPassword(String email, String password);

  // register now requires usernameRaw (the raw username input)
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password, {
    required String usernameRaw,
  });

  Future<void> logout();
  Future<AppUser?> getCurrentUser();

  // helper utilities (optional but exposed for cubit/ui)
  Future<bool> isUsernameAvailable(String usernameRaw);
  Future<void> changeUsername({
    required String uid,
    required String currentUsername,
    required String newUsernameRaw,
  });
}
