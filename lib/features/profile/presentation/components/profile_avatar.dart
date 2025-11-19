import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProfileAvatar({super.key, required this.imageUrl, this.size = 40});

  Widget _defaultAvatar() {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage('assets/images/default-profile-icon.jpg'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _defaultAvatar();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      placeholder: (context, url) => SizedBox(
        height: size,
        width: size,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => _defaultAvatar(),
      imageBuilder: (context, imageProvider) => Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
