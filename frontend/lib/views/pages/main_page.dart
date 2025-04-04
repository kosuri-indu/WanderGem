import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/navigation_provider.dart';
import 'home_page.dart';
import 'itinerary_page.dart';
import 'add_page.dart';
import 'landmark_page.dart';
import 'leaderboard_page.dart';
import 'profile_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  final List<Widget> _pages = const [
    HomePage(),
    ItineraryPage(),
    AddPage(),
    LandmarkPage(),
    LeaderboardPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1C1E),
        title: const Text('WanderGem', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () => ref.read(navigationProvider.notifier).state = 5,
              child: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: selectedIndex < 5
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF1B1C1E),
              selectedItemColor: Colors.amber,
              unselectedItemColor: Colors.white54,
              currentIndex: selectedIndex,
              onTap: (index) {
                ref.read(navigationProvider.notifier).state = index;
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.event), label: 'Itinerary'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle, size: 35), label: ''),
                BottomNavigationBarItem(
                    icon: Icon(Icons.camera_alt), label: 'Landmarks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
              ],
            )
          : null,
    );
  }
}
