import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../providers/trip_theme_provider.dart';

class ItineraryPage extends ConsumerStatefulWidget {
  const ItineraryPage({super.key});

  @override
  ConsumerState<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends ConsumerState<ItineraryPage> {
  final TextEditingController _locationController = TextEditingController();
  String selectedTheme = "Adventure";
  String? selectedTransport;
  TimeOfDay? selectedTime;

  // Hold the generated itinerary data
  Map<String, dynamic>? generatedItineraryData;

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
      body: SafeArea(
        child: SingleChildScrollView(
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
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
              const Text("Mode of Transport:",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedTransport,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                hint: const Text("Select Transport",
                    style: TextStyle(color: Colors.white54)),
                items: ["Railways", "Bus", "Flight", "Ship", "Others"]
                    .map((mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(mode),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedTransport = val!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text("Time of Departure:",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedTime != null
                        ? "${selectedTime!.hourOfPeriod}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}"
                        : "Select Time",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.travel_explore),
                  label: const Text("Generate Plan"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black),
                  onPressed: () async {
                    final location = _locationController.text.trim();
                    final transport = selectedTransport ?? '';
                    final time = selectedTime != null
                        ? "${selectedTime!.hourOfPeriod}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}"
                        : '';
                    
                    if (location.isNotEmpty &&
                        transport.isNotEmpty &&
                        time.isNotEmpty) {
                      // Fetch trip ideas from the notifier
                      await tripNotifier.fetchTripIdeas(location, selectedTheme, transport, time);

                      // Read the updated trip ideas from the provider
                      final updatedTripIdeas = ref.read(tripThemeProvider);

                      setState(() {
                        generatedItineraryData = {
                          'location': location,
                          'theme': selectedTheme,
                          'transport': transport,
                          'time': time,
                          'tripIdeas': updatedTripIdeas,
                        };
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please fill all fields before generating!")),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Display itinerary and action buttons if itinerary has been generated
              generatedItineraryData != null
                  ? Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tripIdeas.length,
                          itemBuilder: (context, index) {
                            final parts = tripIdeas[index].split(':');
                            final placeName =
                                parts.isNotEmpty ? parts[0] : "";
                            final description = parts.length > 1
                                ? parts.sublist(1).join(':')
                                : "";
                            return TimelineTile(
                              alignment: TimelineAlign.start,
                              indicatorStyle: IndicatorStyle(
                                width: 30,
                                indicatorXY: 0.5,
                                drawGap: true,
                                indicator: Center(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.amber, width: 3),
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              beforeLineStyle: const LineStyle(
                                  thickness: 2, color: Colors.amber),
                              endChild: Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8),
                                color: Colors.amber.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: "$placeName\n",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        TextSpan(
                                          text: description.trim(),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                // Save the generated itinerary to Firestore
                                await FirebaseFirestore.instance
                                    .collection('itineraries')
                                    .add({
                                  ...generatedItineraryData!,
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Itinerary saved!")),
                                );
                              },
                              child: const Text("Save Itinerary"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Clear the itinerary data using the provider
                                ref
                                    .read(tripThemeProvider.notifier)
                                    .clearTripIdeas();
                                setState(() {
                                  generatedItineraryData = null;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text("Delete Itinerary"),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          "Enter a location & choose a theme to generate your trip!",
                          style: TextStyle(
                              color: Colors.white54, fontSize: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}