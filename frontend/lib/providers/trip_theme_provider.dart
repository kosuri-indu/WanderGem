import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final tripThemeProvider =
    StateNotifierProvider<TripThemeNotifier, List<String>>((ref) {
  return TripThemeNotifier();
});

class TripThemeNotifier extends StateNotifier<List<String>> {
  late GenerativeModel _model;
  late ChatSession _chatSession;

  TripThemeNotifier() : super([]) {
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    await dotenv.load(fileName: "assets/.env");
    String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception("GEMINI_API_KEY missing in .env file");
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );

    _chatSession = _model.startChat(history: [
      Content.text(
          "You are a creative travel guide. Based on a given theme, generate 10 unique trip ideas which can be combined to form a complete plan. Keep them short, catchy, and inspirational. The plan should fit within the time left until the user's transport arrives. Each activity must include its duration and also consider the time it would take to travel from the previous location. Format like this: 'Activity - (duration in mins including travel)'.")
    ]);
  }

  Future<void> fetchTripIdeas(
    String location,
    String theme,
    String transport,
    String departureTimeStr,
  ) async {
    final now = DateTime.now();
    final parsedDepartureTime = _parseTime(departureTimeStr, now);

    if (parsedDepartureTime.isBefore(now)) {
      state = ["Departure time already passed!"];
      return;
    }

    final safeArrivalTime =
        parsedDepartureTime.subtract(const Duration(minutes: 45));
    final totalAvailableDuration = safeArrivalTime.difference(now);

    if (totalAvailableDuration.inMinutes <= 0) {
      state = ["Not enough time to plan anything before transport!"];
      return;
    }

    try {
      final prompt =
          "I'm at $location with a '$theme' mood. I have around ${totalAvailableDuration.inMinutes} minutes before I need to leave for the $transport. Suggest 10 creative, short, and fun activities I can do before that, preferably forming a meaningful mini-trip. Each activity should include the time to do it *plus* the travel time from the previous one. Format each like this: 'Activity - (duration in mins including travel)'. Keep the total under ${totalAvailableDuration.inMinutes} minutes.";

      final response = await _chatSession.sendMessage(Content.text(prompt));

      final ideas = _filterIdeasFromResponse(
          response.text, totalAvailableDuration, safeArrivalTime, transport);

      if (ideas.isNotEmpty) {
        state = ideas;
      } else {
        state = await _fallbackIdeas(location, theme, transport,
            safeArrivalTime, totalAvailableDuration, now);
      }
    } catch (e) {
      state = await _fallbackIdeas(location, theme, transport, safeArrivalTime,
          totalAvailableDuration, now);
    }
  }

  List<String> _filterIdeasFromResponse(
    String? responseText,
    Duration totalAvailableDuration,
    DateTime safeArrivalTime,
    String transport,
  ) {
    if (responseText == null || responseText.trim().isEmpty) {
      return [];
    }

    final List<String> allIdeas = responseText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final List<String> finalIdeas = [];
    Duration timeUsed = Duration.zero;

    for (final idea in allIdeas) {
      final match = RegExp(r'.-\s\((\d+)\s*mins?\)').firstMatch(idea);
      if (match != null) {
        final duration = Duration(minutes: int.parse(match.group(1)!));
        if (timeUsed + duration <= totalAvailableDuration) {
          finalIdeas.add(idea);
          timeUsed += duration;
        } else {
          break;
        }
      }
    }

    if (finalIdeas.isNotEmpty) {
      finalIdeas.add(
          "Leave by ${_formatTime(safeArrivalTime)} to catch your $transport on time.");
    }

    return finalIdeas;
  }

  Future<List<String>> _fallbackIdeas(
    String location,
    String theme,
    String transport,
    DateTime safeArrivalTime,
    Duration totalAvailableDuration,
    DateTime now,
  ) async {
    final prompt = '''
Suggest 10 short and creative things to do in $location based on the theme "$theme".
Each idea should include an estimated time in minutes *including travel time* from the previous location, and be formatted like this:
"Activity name - (duration in mins including travel)". Make sure the entire plan fits within ${totalAvailableDuration.inMinutes} minutes. Try to arrange activities so travel is efficient.

Current time: ${_formatTime(now)}
I have around ${totalAvailableDuration.inMinutes} minutes before I must leave to catch a $transport.
''';

    final response = await _chatSession.sendMessage(Content.text(prompt));

    final fallbackIdeas = _filterIdeasFromResponse(
        response.text, totalAvailableDuration, safeArrivalTime, transport);

    if (fallbackIdeas.isEmpty) {
      return [
        "Could not fetch trip ideas or not enough time for any activity.",
        "Make sure to leave early for your $transport!"
      ];
    }

    return fallbackIdeas;
  }

  DateTime _parseTime(String timeStr, DateTime baseDate) {
    final cleaned = timeStr
        .replaceAll(RegExp(r'\u202F|\u00A0'), ' ')
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), ' ');

    final match = RegExp(r'^(\d{1,2}):(\d{2})\s?(AM|PM)$').firstMatch(cleaned);

    if (match == null) {
      throw FormatException("Invalid time format. Please select a valid time.");
    }

    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    final period = match.group(3)!;

    if (period == "PM" && hour < 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  String _formatTime(DateTime time) {
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? "PM" : "AM";
    return "$h:$m $period";
  }

  void clearTripIdeas() {
    state = []; // Reset to an empty list or your initial state
  }
}