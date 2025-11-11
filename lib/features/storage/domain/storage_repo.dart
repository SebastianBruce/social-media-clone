import 'dart:typed_data';

abstract class StorageRepo {
  // upload profile images on mobile platforms
  Future<String?> uploadProfileImageMobile(String path, String filename);

  // upload profile images on web platforms
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String filename);
}
