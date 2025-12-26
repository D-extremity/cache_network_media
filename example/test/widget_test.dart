import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cache_network_media_example/main.dart';
import 'package:cache_network_media/cache_network_media.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Cache Network Media'), findsOneWidget);
  });

  testWidgets('Image widget is present', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Image Example'), findsOneWidget);
    expect(find.byType(CacheNetworkMediaWidget), findsWidgets);
  });

  testWidgets('SVG widgets are present', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('SVG Example'), findsOneWidget);
  });

  testWidgets('Lottie widget is present', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Lottie Animation'), findsOneWidget);
  });

  testWidgets('All sections are scrollable', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
