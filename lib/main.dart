import 'package:flutter/material.dart';
import 'screens/connection_screen.dart';

void main() {
  runApp(const HidrologgerApp());
}

class HidrologgerApp extends StatelessWidget {
  const HidrologgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HIDROLOGGER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ConnectionScreen(),
    );
  }
}
