import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/trip_theme_provider.dart';

class ItineraryPage extends ConsumerStatefulWidget {
  const ItineraryPage({super.key});

  @override
  ConsumerState<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends ConsumerState<ItineraryPage> {
  final TextEditingController _locationController = TextEditingController();
  String selectedTheme = "Adventure"; // default selected

  @override
  Widget build(BuildContext context) {
    final tripIdeas = ref.watch(tripThemeProvider);
    final tripNotifier = ref.read(tripThemeProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1B1C1E),
      appBar: AppBar(
        title: const Text("AI Trip Planner"),
        backgroundColor: const Color(0xFF1B1C1E),
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter a Location:",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "e.g., Paris, Tokyo, Goa",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[850],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Choose a Theme:",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                for (var theme in [
                  "Adventure",
                  "Foodie",
                  "Relaxation",
                  "Cultural",
                  "Nature",
                  "Romantic"
                ])
                  ChoiceChip(
                    label: Text(theme),
                    selected: selectedTheme == theme,
                    onSelected: (val) {
                      setState(() {
                        selectedTheme = theme;
                      });
                    },
                    selectedColor: Colors.amber,
                    backgroundColor: Colors.grey[800],
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.travel_explore),
                label: const Text("Generate Plan"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black),
                onPressed: () {
                  final location = _locationController.text.trim();
                  if (location.isNotEmpty) {
                    tripNotifier.fetchTripIdeas(location, selectedTheme);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a location!")),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: tripIdeas.isNotEmpty
                  ? ListView(
                      children: tripIdeas
                          .map((idea) => Card(
                                color: Colors.amber.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    idea,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ))
                          .toList(),
                    )
                  : const Center(
                      child: Text(
                        "Enter a location & choose a theme to generate your trip!",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
