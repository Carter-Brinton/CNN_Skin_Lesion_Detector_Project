import 'package:cs334_final_project/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CS334 - Final Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const CameraApp(title: 'CS334 - Final Project: Skin Lesion Detector (CNN)'),
      debugShowCheckedModeBanner: false,
    );
  }
}
