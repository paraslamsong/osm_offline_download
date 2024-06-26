import 'package:flutter/material.dart';
import 'map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSM Offline Download Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MapScreen(),
    );
  }
}
