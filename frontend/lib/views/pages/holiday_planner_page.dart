import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../../providers/holiday_planner_provider.dart';
import 'package:collection/collection.dart';
import 'package:timeline_tile/timeline_tile.dart';

class HolidayPlannerPage extends ConsumerStatefulWidget {
  const HolidayPlannerPage({super.key});

  @override
  ConsumerState<HolidayPlannerPage> createState() => _HolidayPlannerPageState();
}

class _HolidayPlannerPageState extends ConsumerState<HolidayPlannerPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _daysController =
      TextEditingController(text: '1');
  String selectedTheme = "Adventure";
  DateTime? _startDate;
  bool _isItineraryGenerated = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _locationController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  String _markdownifyResponse(String text) {
    String cleaned = text.replaceAll('*', '');
    final dayRegex = RegExp(r'(Day\s*\d+)', caseSensitive: false);
    cleaned = cleaned.replaceAllMapped(dayRegex, (match) {
      return '\n\n### ${match.group(0)}\n\n';
    });

    final subheadings = [
      'Morning',
      'Afternoon',
      'Evening',
      'Night',
      'Optional',
      'Suggestions',
      'Note'
    ];
    for (final heading in subheadings) {
      final regex =
          RegExp(r'(^|\n)\s*' + heading + r'(:)', caseSensitive: false);
      cleaned = cleaned.replaceAllMapped(regex, (match) {
        return '${match.group(1)}**${heading}${match.group(2)}**';
      });
    }

    return cleaned.trim();
  }

  @override
  Widget build(BuildContext context) {
    final tripIdeas = ref.watch(holidayPlannerProvider);
    final tripNotifier = ref.read(holidayPlannerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
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
            const Text("Number of Days:",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Minimum 1 day",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[850],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Start Date:",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Colors.amber,
                          surface: Color(0xFF1B1C1E),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _startDate = picked;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _startDate != null
                      ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
                      : "Select Start Date",
                  style: const TextStyle(color: Colors.white),
                ),
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
                      setState(() => selectedTheme = theme);
                    },
                    selectedColor: Colors.amber,
                    backgroundColor: Colors.grey[800],
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 35),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.travel_explore),
                label: const Text("Generate Plan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: () async {
                  final location = _locationController.text.trim();
                  final days = int.tryParse(_daysController.text.trim());

                  if (location.isEmpty ||
                      days == null ||
                      days < 1 ||
                      _startDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Please enter all details including a valid start date."),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                    _isItineraryGenerated = false;
                  });

                  try {
                    await tripNotifier.fetchTripIdeas(
                        location, selectedTheme, days, _startDate!);

                    setState(() {
                      _isItineraryGenerated = true;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to generate plan: $e")),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              ),
            if (!_isLoading && tripIdeas.isNotEmpty)
              ...tripIdeas.mapIndexed((index, idea) {
                final formattedIdea = _markdownifyResponse(idea);

                return TimelineTile(
                  alignment: TimelineAlign.manual,
                  lineXY: 0.1,
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
                              border:
                                  Border.all(color: Colors.amber, width: 1.5),
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
                  beforeLineStyle:
                      const LineStyle(thickness: 1, color: Colors.amber),
                  endChild: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.amber.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: MarkdownBody(
                        data: formattedIdea,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 16, color: Colors.black),
                          h3: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            if (!_isLoading && tripIdeas.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    "Enter a location, number of days, & theme to generate your trip!",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
