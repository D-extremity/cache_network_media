import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cache_network_media/cache_network_media.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Image caching test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CacheNetworkMediaWidget.img(
            url: 'https://picsum.photos/200',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(CacheNetworkMediaWidget), findsOneWidget);
  });

  testWidgets('SVG caching test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CacheNetworkMediaWidget.svg(
            url: 'https://www.svgrepo.com/show/13664/heart.svg',
            width: 100,
            height: 100,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(CacheNetworkMediaWidget), findsOneWidget);
  });

  testWidgets('Lottie caching test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CacheNetworkMediaWidget.lottie(
            url:
                'https://lottie.host/2480c7b2-c4ee-4069-b65a-0f28c0ba9a64/SYXSWpC1Hv.json',
            width: 150,
            height: 150,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(CacheNetworkMediaWidget), findsOneWidget);
  });
}
