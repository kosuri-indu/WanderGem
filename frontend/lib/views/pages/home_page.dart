import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = CameraOptions(
      center: Point(coordinates: Position(78.9629, 20.5937)),
      zoom: 3.0, // Zoom out a bit for a broader view
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
