import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class ModelRewards extends StatefulWidget {
  const ModelRewards({super.key});

  @override
  State<StatefulWidget> createState() => _ModelRewardsState();
}

class _ModelRewardsState extends State<ModelRewards> {
  MapboxMap? mapboxMap;
  final TextEditingController _controller = TextEditingController();

  var position = Position(80.155213, 12.839933);
  var modelPosition = Position(80.155213, 12.839933);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapWidget(
          cameraOptions: CameraOptions(
            center: Point(coordinates: position),
            zoom: 18.5,
            bearing: 98.82,
            pitch: 85,
          ),
          key: const ValueKey<String>('mapWidget'),
          onMapCreated: _onMapCreated,
          onStyleLoadedListener: _onStyleLoaded,
        ),
        Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter wallet address',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final value = _controller.text;
                    if (value.length == 66) { // Standard Aptos address length
                      try {
                        final response = await http.post(
                          Uri.parse('/api/claim-reward'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({
                            'walletAddress': value,
                            'landmarkId': '1' // Replace with actual landmark ID
                          }),
                        );

                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reward claimed successfully!')),
                          );
                          Navigator.pushNamed(context, '/leaderboard');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to claim reward')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid wallet address')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
  }

  _onStyleLoaded(StyleLoadedEventData data) async {
    addModelLayer();
  }

  addModelLayer() async {
    var value = Point(coordinates: modelPosition);
    if (mapboxMap == null) {
      throw Exception("MapboxMap is not ready yet");
    }

    final buggyModelId = "model-test-id";
    final buggyModelUri =
        "https://github.com/KhronosGroup/glTF-Sample-Models/raw/d7a3cc8e51d7c573771ae77a57f16b0662a905c6/2.0/Buggy/glTF/Buggy.gltf";
    await mapboxMap?.style.addStyleModel(buggyModelId, buggyModelUri);

    final carModelId = "model-car-id";
    final carModelUri = "asset://assets/sportcar.glb";
    await mapboxMap?.style.addStyleModel(carModelId, carModelUri);

    await mapboxMap?.style
        .addSource(GeoJsonSource(id: "sourceId", data: json.encode(value)));

    var modelLayer = ModelLayer(id: "modelLayer-buggy", sourceId: "sourceId");
    modelLayer.modelId = buggyModelId;
    modelLayer.modelScale = [0.15, 0.15, 0.15];
    modelLayer.modelRotation = [0, 0, 90];
    modelLayer.modelType = ModelType.COMMON_3D;
    mapboxMap?.style.addLayer(modelLayer);

    var modelLayer1 = ModelLayer(id: "modelLayer-car", sourceId: "sourceId");
    modelLayer1.modelId = carModelId;
    modelLayer1.modelScale = [0.15, 0.15, 0.15];
    modelLayer1.modelRotation = [0, 0, 90];
    modelLayer1.modelType = ModelType.COMMON_3D;
    mapboxMap?.style.addLayer(modelLayer1);
  }
}
