// import 'package:firebase_core/firebase_core.dart';
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'home.dart';
// import 'package:innowave24_audio_apk/Home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(color: Colors.cyanAccent),
        elevatedButtonTheme:
            const ElevatedButtonThemeData(style: ButtonStyle()),
        textTheme: const TextTheme(
            titleLarge: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
            bodyLarge: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w600)),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: SimpleRecorder(),
    );
  }
}
