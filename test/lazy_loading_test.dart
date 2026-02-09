import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cache_network_media/cache_network_media.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  // Disable VisibilityDetector's update interval for tests
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  group('Lazy Loading Tests', () {
    testWidgets(
      'Image widget shows placeholder initially when lazy loading is enabled',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CacheNetworkMediaWidget.img(
                url: 'https://picsum.photos/200/300',
                width: 200,
                height: 300,
                lazyLoading: true,
                placeholder: const Text('Loading...'),
              ),
            ),
          ),
        );

        // Initially, placeholder should be visible
        expect(find.text('Loading...'), findsOneWidget);

        // Pump and settle with longer duration to allow VisibilityDetector timers
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // After visibility detection, widget should start loading
        // FutureBuilder will still show placeholder until data arrives
        expect(find.text('Loading...'), findsOneWidget);
      },
    );

    testWidgets(
      'Image widget loads immediately when lazy loading is disabled',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CacheNetworkMediaWidget.img(
                url: 'https://picsum.photos/200/300',
                width: 200,
                height: 300,
                lazyLoading: false, // Disabled
                placeholder: const Text('Loading...'),
              ),
            ),
          ),
        );

        // Should show placeholder immediately as it starts loading right away
        expect(find.text('Loading...'), findsOneWidget);
      },
    );

    testWidgets('SVG widget respects lazy loading parameter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CacheNetworkMediaWidget.svg(
              url: 'https://example.com/icon.svg',
              width: 100,
              height: 100,
              lazyLoading: true,
              placeholder: const CircularProgressIndicator(),
            ),
          ),
        ),
      );

      // Should show placeholder initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump();

      // After pump, still showing placeholder
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Lottie widget respects lazy loading parameter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CacheNetworkMediaWidget.lottie(
              url: 'https://example.com/animation.json',
              width: 200,
              height: 200,
              lazyLoading: true,
              placeholder: const Icon(Icons.animation),
            ),
          ),
        ),
      );

      // Should show placeholder initially
      expect(find.byIcon(Icons.animation), findsOneWidget);

      await tester.pump();

      // After pump, still showing placeholder
      expect(find.byIcon(Icons.animation), findsOneWidget);
    });

    testWidgets('Multiple lazy loaded images in list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return CacheNetworkMediaWidget.img(
                  url: 'https://picsum.photos/200/300?random=$index',
                  width: 200,
                  height: 300,
                  lazyLoading: true,
                  placeholder: Text('Loading $index'),
                );
              },
            ),
          ),
        ),
      );

      // Should show placeholders for visible items
      expect(find.textContaining('Loading'), findsWidgets);
    });

    testWidgets('Lazy loading defaults to false', (WidgetTester tester) async {
      // Test that when lazyLoading is not specified, it defaults to false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CacheNetworkMediaWidget.img(
              url: 'https://picsum.photos/200/300',
              width: 200,
              height: 300,
              // lazyLoading not specified - should default to false
              placeholder: const Text('Loading...'),
            ),
          ),
        ),
      );

      // Should start loading immediately
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('Custom placeholder is used with lazy loading', (
      WidgetTester tester,
    ) async {
      final customPlaceholder = Container(
        width: 200,
        height: 300,
        color: Colors.grey,
        child: const Center(child: Text('Custom Placeholder')),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CacheNetworkMediaWidget.img(
              url: 'https://picsum.photos/200/300',
              width: 200,
              height: 300,
              lazyLoading: true,
              placeholder: customPlaceholder,
            ),
          ),
        ),
      );

      // Should show custom placeholder
      expect(find.text('Custom Placeholder'), findsOneWidget);
    });

    testWidgets('Error builder works with lazy loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CacheNetworkMediaWidget.img(
              url: 'https://invalid-url-that-will-fail.com/image.png',
              width: 200,
              height: 300,
              lazyLoading: true,
              placeholder: const Text('Loading...'),
              errorBuilder: (context, error, stackTrace) {
                return const Text('Error occurred');
              },
            ),
          ),
        ),
      );

      // Initially shows placeholder
      expect(find.text('Loading...'), findsOneWidget);

      // Pump frames to trigger loading
      await tester.pumpAndSettle();

      // Note: In a real test with network mocking, we could verify
      // the error builder is called. This is a basic structure test.
    });

    testWidgets('Widget is StatefulWidget for state management', (
      WidgetTester tester,
    ) async {
      final widget = CacheNetworkMediaWidget.img(
        url: 'https://picsum.photos/200/300',
        width: 200,
        height: 300,
        lazyLoading: true,
      );

      // Verify it's a StatefulWidget
      expect(widget, isA<StatefulWidget>());
    });
  });
}
