import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/user.dart';
import '../widgets/post_list.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  static const _photos = [
    '$host/image/600x600/008080/ffffff?text=Profile+Photo+1',
    '$host/image/600x600/ff6f61/ffffff?text=Profile+Photo+2',
    '$host/image/600x600/6b5b95/ffffff?text=Profile+Photo+3',
    '$host/image/600x600/88b04b/ffffff?text=Profile+Photo+4',
    '$host/image/600x600/f7cac9/1f2937?text=Profile+Photo+5',
    '$host/image/600x600/92a8d1/ffffff?text=Profile+Photo+6',
  ];

  void _showPhoto(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, error, stack) =>
                    const Icon(Icons.broken_image_outlined, size: 48),
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton.filled(
                tooltip: 'Close photo',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: NestedScrollView(
      headerSliverBuilder: (context, innerScrolled) => [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/cover.webp',
                height: 140,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    UserAvatar(imageUrl: user.profileImageUrl, size: 72),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text('@${user.userName}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Posts'),
                  Tab(text: 'About'),
                  Tab(text: 'Photos'),
                ],
              ),
            ],
          ),
        ),
      ],
      body: TabBarView(
        children: [
          PostList(userId: user.id),
          ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Name'),
                subtitle: Text(user.fullName),
              ),
              ListTile(
                leading: const Icon(Icons.alternate_email),
                title: const Text('Username'),
                subtitle: Text(user.userName),
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user.email),
              ),
            ],
          ),
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              final imageUrl = _photos[index];
              return InkWell(
                onTap: () => _showPhoto(context, imageUrl),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stack) =>
                      const Icon(Icons.broken_image_outlined),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
