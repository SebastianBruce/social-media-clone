import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProfileAvatar({super.key, required this.imageUrl, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      placeholder: (context, url) => SizedBox(
        height: size,
        width: size,
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
          image: const DecorationImage(
            image: AssetImage('assets/images/default-profile-icon.jpg'),
            fit: BoxFit.contain,
          ),
        ),
      ),
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
