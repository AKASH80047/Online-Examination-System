import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void runExamApp() {
  runApp(const ProviderScope(child: ExamApp()));
}

class ExamApp extends StatelessWidget {
  const ExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Examination System',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Online Examination System - Phase 1 Initialized'),
        ),
      ),
    );
  }
}
