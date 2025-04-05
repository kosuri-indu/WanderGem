import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/colors.dart';
import 'package:frontend/views/pages/add_page.dart';
import 'package:frontend/views/pages/home_page.dart';
import 'package:frontend/views/pages/itinerary_page.dart';
import 'package:frontend/views/pages/landmark_page.dart';
import 'package:frontend/views/pages/leaderboard_page.dart';

import '../../providers/navigation_provider.dart';

// Dummy Profile Page (replace with actual page if available)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Profile Page", style: TextStyle(color: Colors.white)),
    );
  }
}

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  final List<Widget> _pages = const [
    HomePage(),
    ItineraryPage(),
    AddPage(),
    LandmarkPage(),
    LeaderboardPage(),
    ProfilePage(), // index 5 - Profile page
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'WanderGem',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => ref.read(navigationProvider.notifier).state = 5,
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: secondaryColor,
                child: Icon(Icons.person, color: primaryColor, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: selectedIndex,
            children: _pages,
          ),
          // Always render bottom nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white10, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                      child: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        selectedItemColor: secondaryColor,
                        unselectedItemColor: Colors.white60,
                        currentIndex:
                            selectedIndex > 4 ? 0 : selectedIndex, // fallback
                        showSelectedLabels: true,
                        showUnselectedLabels: true,
                        onTap: (index) {
                          if (index != 2) {
                            ref.read(navigationProvider.notifier).state = index;
                          }
                        },
                        items: List.generate(5, (index) {
                          if (index == 2) {
                            return const BottomNavigationBarItem(
                                icon: SizedBox.shrink(), label: '');
                          }

                          IconData icon;
                          String label;
                          switch (index) {
                            case 0:
                              icon = Icons.home;
                              label = 'Home';
                              break;
                            case 1:
                              icon = Icons.event;
                              label = 'Trips';
                              break;
                            case 3:
                              icon = Icons.camera_alt;
                              label = 'Spots';
                              break;
                            case 4:
                              icon = Icons.leaderboard;
                              label = 'Ranks';
                              break;
                            default:
                              icon = Icons.home;
                              label = '';
                          }

                          final isSelected = selectedIndex == index;

                          return BottomNavigationBarItem(
                            icon: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? secondaryColor.withOpacity(0.15)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                        scale: animation, child: child),
                                child: Icon(
                                  icon,
                                  key: ValueKey<bool>(isSelected),
                                  color: isSelected
                                      ? secondaryColor
                                      : Colors.white60,
                                  size: isSelected ? 26 : 22,
                                ),
                              ),
                            ),
                            label: label,
                          );
                        }),
                        selectedFontSize: 12,
                        unselectedFontSize: 12,
                        enableFeedback: true,
                        mouseCursor: SystemMouseCursors.click,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 9,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(navigationProvider.notifier).state = 2,
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add,
                            color: primaryColor, size: 36),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
