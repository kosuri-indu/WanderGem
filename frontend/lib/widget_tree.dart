import 'package:flutter/material.dart';
import 'package:frontend/views/pages/splash_screen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);
  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WanderGem',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(), 
    );
  }
}