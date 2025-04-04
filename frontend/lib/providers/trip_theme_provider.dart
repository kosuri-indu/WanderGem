import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        "You are a creative travel guide. Based on a given theme, generate 10 unique trip ideas. Keep them short, catchy, and inspirational. Don't number them.",
      )
    ]);
  }

  Future<void> fetchTripIdeas(String location, String theme) async {
    try {
      state = [];

      final prompt =
          "Create a detailed travel plan for someone near $location with a theme of $theme. "
          "Include at least 5 specific, real places nearby that match the theme, like cafes, parks, gardens, or viewpoints or any other places. "
          "Mention the name of the place, a short reason to visit, and the ideal time of day. "
          "Organize it as a suggested route from one place to another, forming a 1-day itinerary.";

      final response = await _chatSession.sendMessage(Content.text(prompt));

      final ideas = (response.text ?? "Explore the unknown in $location.")
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      state = ideas;
    } catch (e) {
      state = ["Couldn't fetch trip ideas. Please try again later."];
    }
  }
}
