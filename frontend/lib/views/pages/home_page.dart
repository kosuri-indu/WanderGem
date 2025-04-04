import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Correct way to set camera center
    final camera = CameraOptions(
      center: Point(coordinates: Position(-98.0, 39.5)), // USA center roughly
      zoom: 3.5,
    );

    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: MapWidget(
            key: const ValueKey('mapWidget'),
            cameraOptions: camera,
          ),
        ),
      ),
    );
  }
}
