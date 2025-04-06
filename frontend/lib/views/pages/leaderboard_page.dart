import 'package:flutter/material.dart';
import 'package:frontend/views/pages/model_reward.dart'; // Add this import

class LeaderboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> topUsers = [
    {'name': 'AlphaWolf', 'score': 980},
    {'name': 'CodeMaster', 'score': 870},
    {'name': 'BugHunter', 'score': 820},
    {'name': 'PixelNinja', 'score': 790},
    {'name': 'LogicLord', 'score': 760},
  ];

  final Color primaryColor = Colors.black;
  final Color secondaryColor = Colors.amber;

  LeaderboardPage({super.key});

  Widget _buildMedalIcon(int rank) {
    switch (rank) {
      case 1:
        return const Icon(Icons.emoji_events, color: Colors.white, size: 30);
      case 2:
        return const Icon(Icons.emoji_events, color: Colors.white70, size: 28);
      case 3:
        return const Icon(Icons.emoji_events, color: Colors.brown, size: 26);
      default:
        return Text(
          '$rank',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.card_giftcard, color: secondaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ModelRewards()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.separated(
            itemCount: topUsers.length,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final user = topUsers[index];
              final rank = index + 1;

              return Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 25,
                    child: _buildMedalIcon(rank),
                  ),
                  title: Text(
                    user['name'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  trailing: Text(
                    '${user['score']} pts',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              backgroundColor: secondaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ModelRewards()),
                );
              },
              icon: const Icon(Icons.redeem, color: Colors.black),
              label: const Text(
                'Rewards',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
