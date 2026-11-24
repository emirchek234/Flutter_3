import 'package:flutter/material.dart';

import 'features/explorer_screen.dart';

class AtlasApp extends StatelessWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF17332E);
    return MaterialApp(
      title: 'Atlas — Country explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F4EF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6959),
          primary: const Color(0xFF2F6959),
          onPrimary: Colors.white,
          surface: const Color(0xFFFFFEFA),
          onSurface: ink,
          error: const Color(0xFFB3483F),
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: ink,
            fontSize: 36,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.4,
          ),
          headlineMedium: TextStyle(
            color: ink,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
          titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(color: Color(0xFF65716B), height: 1.45),
          labelLarge: TextStyle(fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F4EF),
          hintStyle: const TextStyle(color: Color(0xFF929A94)),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF2F6959), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const ExplorerScreen(),
    );
  }
}
