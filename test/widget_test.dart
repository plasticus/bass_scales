// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures, and read the values of widget properties.

import 'package:flutter_test/flutter_test.dart';

import 'package:bass_scales/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const BassScalesApp());

    // Verify the main fretboard page is present.
    expect(find.text('E'), findsWidgets);
  });
}
