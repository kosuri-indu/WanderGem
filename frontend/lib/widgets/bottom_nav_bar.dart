import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';

class BottomNavBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => ref.read(navigationProvider.notifier).state = index,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'Itinerary'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40), label: ''),
        BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt), label: 'Landmarks'),
        BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
      ],
    );
  }
}
