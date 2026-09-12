import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  const UserAvatar({super.key, required this.imageUrl, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.person, size: size * 0.7);
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: imageUrl.isEmpty || imageUrl == 'N/A'
            ? fallback
            : imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) => fallback,
              )
            : Image.asset(
                imageUrl.startsWith('assets/')
                    ? imageUrl
                    : 'assets/images/$imageUrl',
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) => fallback,
              ),
      ),
    );
  }
}
