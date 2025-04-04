import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class ThreeDViewPage extends StatelessWidget {
  const ThreeDViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D View')),
      body: Cube(
        onSceneCreated: (Scene scene) {
          scene.world.add(Object(
            fileName: 'assets/3d_models/taj_mahal.obj',
          ));
          scene.camera.zoom = 10;
        },
      ),
    );
  }
}
