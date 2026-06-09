// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added import

import 'package:exam_paper/app.dart'; // Changed import

void main() {
  testWidgets('ExamApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        // Added ProviderScope
        child: ExamApp(), // Changed MyApp to ExamApp
      ),
    );

    // Since ExamApp is a complex app with routing and async operations,
    // a simple counter test is not appropriate here.
    // This test merely ensures the app can be pumped without immediate errors.
    // Further tests would involve mocking navigation and providers.
    expect(find.byType(MaterialApp), findsOneWidget); // Basic check
  });
}
