import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const HidrolinkApp());
}

class HidrolinkApp extends StatelessWidget {
  const HidrolinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
              title: 'HIDROLINK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
