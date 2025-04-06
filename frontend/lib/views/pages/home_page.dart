import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:frontend/views/pages/journal_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    implements OnPointAnnotationClickListener {
  late MapboxMap mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  final Map<String, String> annotationIdToCity = {};

  final List<Map<String, dynamic>> cities = [
    {"name": "Hyderabad", "lat": 17.3850, "lng": 78.4867},
    {"name": "IIT Madras", "lat": 12.9916, "lng": 80.2335},
    {"name": "Pune", "lat": 18.5204, "lng": 73.8567},
    {"name": "Noida", "lat": 28.5355, "lng": 77.3910},
    {"name": "Paris", "lat": 48.8566, "lng": 2.3522},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    const String accessToken =
        "pk.eyJ1IjoiNjYxOWtrIiwiYSI6ImNtOTM0N3JybzBpYzAya3F2OGZsMHE1cnMifQ.jtEBUc5e3Bs8Q2dQxJyUBA";
    MapboxOptions.setAccessToken(accessToken);
  }

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    final annotationId = annotation.id;
    final city = annotationIdToCity[annotationId] ?? "Unknown";
    debugPrint("📍 Tapped on: $city");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalListPage(location: city),
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    pointAnnotationManager?.addOnPointAnnotationClickListener(this);

    final ByteData bytes = await rootBundle.load('assets/redpin.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    for (var city in cities) {
      final annotation =
          await pointAnnotationManager?.create(PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(city["lng"], city["lat"]),
        ),
        image: imageData,
        iconSize: 0.5,
      ));

      if (annotation != null) {
        annotationIdToCity[annotation.id] = city["name"];
      }
    }

    debugPrint("📍 Pins added.");
  }

  @override
  Widget build(BuildContext context) {
    CameraOptions camera = CameraOptions(
      center: Point(coordinates: Position(78.9629, 20.5937)),
      zoom: 3.5,
    );

    return Scaffold(
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: camera,
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
