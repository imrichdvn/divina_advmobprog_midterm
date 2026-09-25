import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  // ENHANCEMENT #1 - LAB 4
  final List<Map<String, dynamic>> notifications = [
    {
      'name': 'Michael Scott',
      'post': 'World\'s Best Boss',
      'description': 'That\'s what she said!',
      'profileImageUrl': 'michael.jpg',
      'imageUrl': 'michaelnotif.jpg',
      'date': 'December 17, 2025',
      'numOfLikes': 5,
    },
    {
      'name': 'Dwight Schrute',
      'post': 'Beet Farm Update',
      'description': 'Bears. Beets. Battlestar Galactica.',
      'profileImageUrl': 'dwightprofile.jpg',
      'imageUrl': 'dwight.jpeg',
      'date': 'December 17, 2025',
      'numOfLikes': 7,
    },
    {
      'name': 'Jim Halpert',
      'post': 'Office Pranks',
      'description': 'Stapler in Jell-O, again.',
      'profileImageUrl': 'jimhalpertprofile.jpg',
      'imageUrl': 'stapler.jpg',
      'date': 'December 17, 2025',
      'numOfLikes': 12,
    },
    {
      'name': 'Pam Beesly',
      'post': 'Art Exhibit',
      'description': 'Hope you can all stop by the gallery!',
      'profileImageUrl': 'pambeeslyprofile.jpg',
      'imageUrl': 'pampainting.jpg',
      'date': 'December 17, 2025',
      'numOfLikes': 9,
    },
    {
      'name': 'Kevin Malone',
      'post': 'Chili Accident',
      'description': 'Don\'t ask... it spilled everywhere.',
      'profileImageUrl': 'kevinmaloneprofile.jpg',
      'imageUrl': 'kevinchili.webp',
      'date': 'December 17, 2025',
      'numOfLikes': 15,
    },
    {
      'name': 'Angela Martin',
      'post': 'Cat Fundraiser',
      'description': 'NO, the cats are NOT for adoption.',
      'profileImageUrl': 'angelaprofile.jpg',
      'imageUrl': 'angelacats.webp',
      'date': 'December 17, 2025',
      'numOfLikes': 6,
    },
    {
      'name': 'Stanley Hudson',
      'post': 'Pretzel Day',
      'description': 'The highlight of the year.',
      'profileImageUrl': 'stanleyprofile.jpg',
      'imageUrl': 'stanleypretzel.jpg',
      'date': 'December 17, 2025',
      'numOfLikes': 11,
    },
    {
      'name': 'Creed Bratton',
      'post': 'Identity Question',
      'description': 'Have you ever noticed your ID expires?',
      'profileImageUrl': 'creedprofile.webp',
      'imageUrl': '',
      'date': 'December 17, 2025',
      'numOfLikes': 4,
    },
    {
      'name': 'Oscar Martinez',
      'post': 'Budget Review',
      'description': 'These numbers are concerning.',
      'profileImageUrl': 'oscarprofile.webp',
      'imageUrl': '',
      'date': 'December 17, 2025',
      'numOfLikes': 8,
    },
    {
      'name': 'Toby Flenderson',
      'post': 'HR Reminder',
      'description': 'Please submit your paperwork on time.',
      'profileImageUrl': 'tobyprofile.jpg',
      'imageUrl': '',
      'date': 'December 17, 2025',
      'numOfLikes': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // GENERAL ENHEANCEMENT lab 2
      // ENHANCEMENT #1 lab 4
      color: Colors.white,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final post = Post(
            id: 1000 + index,
            postId: 1000 + index,
            userId: 0,
            body: '${notification['post']}\n\n${notification['description']}',
            likes: notification['numOfLikes'],
            dislikes: 0,
            createdAt: notification['date'],
            updatedAt: notification['date'],
          );
          return Column(
            children: [
              PostCard(
                post: post,
                userName: notification['name'],
                profileImageUrl: notification['profileImageUrl'],
                date: notification['date'],
                imageUrl: notification['imageUrl'],
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
