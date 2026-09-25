import 'package:flutter/material.dart';
import '../models/user.dart';
import 'newsfeed_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        ['Gossipers', 'Notifications', widget.user.userName][_selectedIndex],
      ),
      actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    ),
    body: PageView(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _selectedIndex = index),
      children: [
        const NewsFeedScreen(),
        const NotificationScreen(),
        ProfileScreen(user: widget.user),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => _pageController.jumpToPage(index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    ),
  );
}
