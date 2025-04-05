import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

final holidayPlannerProvider =
    StateNotifierProvider<HolidayPlannerNotifier, List<String>>((ref) {
  return HolidayPlannerNotifier();
});

class HolidayPlannerNotifier extends StateNotifier<List<String>> {
  late GenerativeModel _model;
  late ChatSession _chatSession;

  HolidayPlannerNotifier() : super([]) {
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    await dotenv.load(fileName: "assets/.env");
    String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) throw Exception("GEMINI_API_KEY missing in .env file");

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
          "You are a creative travel guide. Based on a given theme and travel dates, generate exciting, real-world itineraries, and call out any weekend events, special local festivals, or discounts if relevant."),
    ]);
  }

  Future<void> fetchTripIdeas(
      String location, String theme, int days, DateTime startDate) async {
    state = [];

    final formatter = DateFormat('MMM dd, yyyy (EEEE)');
    final endDate = startDate.add(Duration(days: days - 1));
    final dateRange =
        "${formatter.format(startDate)} to ${formatter.format(endDate)}";

    final prompt =
        "Create a $days-day travel itinerary for $location with a $theme theme, between $dateRange. "
        "Mention at least 5 real places/activities per day. Include details like ideal time to visit, why it's recommended, and any special events, weekend activities, or offers available during that day if applicable. "
        "Format each day clearly as 'Day 1', 'Day 2', etc.";

    final response = await _chatSession.sendMessage(Content.text(prompt));
    final fullText = response.text?.trim() ?? "";

    if (fullText.isEmpty) {
      state = ["Sorry, I couldn't generate a trip itinerary."];
    } else {
      state = [fullText];
    }
  }
}
