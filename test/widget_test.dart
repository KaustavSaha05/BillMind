import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billmind/main.dart';

void main() {
  testWidgets('BillMind app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BillMindApp());

    // Verify that the app title is displayed
    expect(find.text('BillMind'), findsOneWidget);
    
    // Verify that the main elements are present
    expect(find.text('Never miss a bill again'), findsOneWidget);
    expect(find.text('Add Bill'), findsOneWidget);
  });
}
