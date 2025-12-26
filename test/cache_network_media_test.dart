import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cache_network_media/cache_network_media.dart';
import 'package:cache_network_media/src/core/disk_cache_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DiskCacheManager Tests', () {
    late Directory tempDir;
    late DiskCacheManager cacheManager;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cache_test_');
      cacheManager = DiskCacheManager(tempDir);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Cache manager stores and retrieves data', () async {
      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
      await cacheManager.putImage('test_key', testData);

      final retrieved = await cacheManager.getImage('test_key');
      expect(retrieved, equals(testData));
    });

    test('Cache returns null for non-existent key', () async {
      final result = await cacheManager.getImage('non_existent');
      expect(result, isNull);
    });

    test('Cache overwrites existing data', () async {
      await cacheManager.putImage('key', Uint8List.fromList([1, 2, 3]));
      await cacheManager.putImage('key', Uint8List.fromList([4, 5, 6]));

      final result = await cacheManager.getImage('key');
      expect(result, equals(Uint8List.fromList([4, 5, 6])));
    });
  });

  group('CacheNetworkMediaWidget Tests', () {
    testWidgets('Image widget renders placeholder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CacheNetworkMediaWidget.img(
              url: 'https://test.com/image.png',
              width: 100,
              height: 100,
              placeholder: const Text('Loading'),
            ),
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('SVG widget accepts color parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CacheNetworkMediaWidget.svg(
              url: 'https://test.com/icon.svg',
              width: 50,
              height: 50,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(CacheNetworkMediaWidget), findsOneWidget);
    });

    testWidgets('Lottie widget accepts animation parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CacheNetworkMediaWidget.lottie(
              url: 'https://test.com/animation.json',
              width: 200,
              height: 200,
              repeat: true,
              animate: false,
            ),
          ),
        ),
      );

      expect(find.byType(CacheNetworkMediaWidget), findsOneWidget);
    });
  });
}
