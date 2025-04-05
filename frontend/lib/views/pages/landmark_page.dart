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

  String lightPreset = 'day';
  String theme = 'default';
  String buildingHighlightColor = 'hsl(214, 94%, 59%)';

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;

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

  void _updateMapStyle() {
    final configs = {
      "lightPreset": lightPreset,
      "theme": theme,
      "buildingHighlightColor": buildingHighlightColor,
    };
    mapboxMap?.style.setStyleImportConfigProperties("basemap", configs);
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

        mapboxMap?.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(lon, lat)),
            zoom: 18.5,
            pitch: 80.0,
          ),
          MapAnimationOptions(duration: 1000),
        );
      } else {
        log("No results found for $query");
      }
    } else {
      log("Geocoding error: ${response.statusCode}");
    }
  }

  Widget _buildDebugPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Building Color'),
          DropdownButton<String>(
            value: buildingHighlightColor,
            items: const [
              DropdownMenuItem(
                  value: 'hsl(214, 94%, 59%)', child: Text('Blue')),
              DropdownMenuItem(value: 'yellow', child: Text('Yellow')),
              DropdownMenuItem(value: 'red', child: Text('Red')),
            ],
            onChanged: (value) {
              setState(() {
                buildingHighlightColor = value!;
                _updateMapStyle();
              });
            },
          ),
          const SizedBox(height: 10),
          const Text('Light'),
          DropdownButton<String>(
            value: lightPreset,
            items: const [
              DropdownMenuItem(value: 'dawn', child: Text('Dawn')),
              DropdownMenuItem(value: 'day', child: Text('Day')),
              DropdownMenuItem(value: 'dusk', child: Text('Dusk')),
              DropdownMenuItem(value: 'night', child: Text('Night')),
            ],
            onChanged: (value) {
              setState(() {
                lightPreset = value!;
                _updateMapStyle();
              });
            },
          ),
          const SizedBox(height: 10),
          const Text('Theme'),
          DropdownButton<String>(
            value: theme,
            items: const [
              DropdownMenuItem(value: 'default', child: Text('Default')),
              DropdownMenuItem(value: 'faded', child: Text('Faded')),
              DropdownMenuItem(value: 'monochrome', child: Text('Monochrome')),
            ],
            onChanged: (value) {
              setState(() {
                theme = value!;
                _updateMapStyle();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Search place...",
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
        onSubmitted: _searchLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(24.9453, 60.1718)),
              bearing: 49.92,
              zoom: 15,
              pitch: 40,
            ),
            styleUri: MapboxStyles.STANDARD_EXPERIMENTAL,
            textureView: true,
            onMapCreated: _onMapCreated,
          ),
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: _buildSearchBox(),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: _buildDebugPanel(),
          ),
        ],
      ),
    );
  }
}
