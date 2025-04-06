import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LandmarkPage extends StatefulWidget {
  const LandmarkPage({super.key});

  @override
  State<LandmarkPage> createState() => _LandmarkPageState();
}

class _LandmarkPageState extends State<LandmarkPage> {
  MapboxMap? mapboxMap;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _searchHistory = [];
  String? _selectedPlace;
  String? _placeDescription;

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;

    final configs = {
      "lightPreset": "night",
      "theme": "default",
      "buildingHighlightColor": "hsl(214, 94%, 59%)",
    };
    mapboxMap.style.setStyleImportConfigProperties("basemap", configs);

    final tapInteractionPOI = TapInteraction(StandardPOIs(), (feature, _) {
      mapboxMap.setFeatureStateForFeaturesetFeature(
          feature, StandardPOIsState(hide: true));
      log("POI feature name: ${feature.name}");
    }, radius: 10, stopPropagation: false);
    mapboxMap.addInteraction(tapInteractionPOI, interactionID: "tap_poi");

    final tapInteractionBuildings =
        TapInteraction(StandardBuildings(), (feature, _) {
      mapboxMap.setFeatureStateForFeaturesetFeature(
          feature, StandardBuildingsState(highlight: true));
      log("Building group: ${feature.group}");
    });
    mapboxMap.addInteraction(tapInteractionBuildings);

    final tapInteractionPlaceLabel =
        TapInteraction(StandardPlaceLabels(), (feature, _) {
      mapboxMap.setFeatureStateForFeaturesetFeature(
          feature, StandardPlaceLabelsState(select: true));
      log("Place label: ${feature.name}");
    });
    mapboxMap.addInteraction(tapInteractionPlaceLabel);

    final longTapInteraction = LongTapInteraction.onMap((context) {
      log("Long tap at: ${context.touchPosition.x}, ${context.touchPosition.y}");
      mapboxMap.resetFeatureStatesForFeatureset(StandardPOIs());
      mapboxMap.resetFeatureStatesForFeatureset(StandardBuildings());
      mapboxMap.resetFeatureStatesForFeatureset(StandardPlaceLabels());
    });
    mapboxMap.addInteraction(longTapInteraction);
  }

  Future<void> _searchLocation(String query) async {
    final accessToken =
        "pk.eyJ1IjoiNjYxOWtrIiwiYSI6ImNtOTM0N3JybzBpYzAya3F2OGZsMHE1cnMifQ.jtEBUc5e3Bs8Q2dQxJyUBA";
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json'
        '?access_token=$accessToken&limit=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final features = data['features'];

      if (features.isNotEmpty) {
        final coords = features[0]['center'];
        final lon = coords[0];
        final lat = coords[1];

        setState(() {
          _searchHistory.insert(0, query);
          _selectedPlace = query;
          _placeDescription = null;
        });

        mapboxMap?.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(lon, lat)),
            zoom: 18.5,
            pitch: 80.0,
          ),
          MapAnimationOptions(duration: 1000),
        );

        final description = await _fetchPlaceHistory(query);
        setState(() {
          _placeDescription = description;
        });
      } else {
        log("No results found for $query");
      }
    } else {
      log("Geocoding error: ${response.statusCode}");
    }
  }

  Future<String?> _fetchPlaceHistory(String query) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final payload = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Give me a brief and captivating historical background or interesting facts about the place or monument: $query. Keep it concise and engaging."
            }
          ]
        }
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
      return text ?? "No information found.";
    } else {
      log("Gemini API error: ${response.body}");
      return "Could not fetch information.";
    }
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Search for a place, monument, or location...",
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
        onSubmitted: _searchLocation,
      ),
    );
  }

  Widget _buildPlaceInfoAndHistory() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedPlace != null && _placeDescription != null) ...[
              Text(
                "Explore: $_selectedPlace",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                _placeDescription!,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Divider(thickness: 1.5),
            ],
            const Text(
              'Recent Searches',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_searchHistory.isEmpty)
              const Text("You haven't searched for any place yet.")
            else
              ListView.builder(
                itemCount: _searchHistory.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final query = _searchHistory[index];
                  return ListTile(
                    dense: true,
                    title: Text(query),
                    leading: const Icon(Icons.history),
                    onTap: () => _searchLocation(query),
                  );
                },
              ),
            const SizedBox(height: 100), // 👈 Extra space at bottom
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardVisible = viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            MapWidget(
              key: const ValueKey("mapWidget"),
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(80.1538, 12.8406)),
                bearing: 49.92,
                zoom: 17,
                pitch: 40,
              ),
              styleUri: MapboxStyles.STANDARD_EXPERIMENTAL,
              textureView: true,
              onMapCreated: _onMapCreated,
            ),
            Positioned(
              top: 20,
              left: 10,
              right: 10,
              child: _buildSearchBox(),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              bottom: isKeyboardVisible ? viewInsets.bottom : 10,
              left: 10,
              right: 10,
              height: isKeyboardVisible
                  ? screenHeight * 0.3
                  : screenHeight * 0.35, // Smaller overall height
              child: _buildPlaceInfoAndHistory(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
