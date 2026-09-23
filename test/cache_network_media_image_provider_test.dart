import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cache_network_media/cache_network_media.dart';
import 'package:cache_network_media/src/core/disk_cache_manager.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// A valid 1x1 transparent PNG.
final _transparentPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
);

Future<ImageInfo> _resolve(ImageProvider provider) {
  final completer = Completer<ImageInfo>();
  final stream = provider.resolve(ImageConfiguration.empty);
  stream.addListener(
    ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) completer.complete(info);
      },
      onError: (error, stackTrace) {
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      },
    ),
  );
  return completer.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cnm_provider_test_');
    PaintingBinding.instance.imageCache.clear();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('CacheNetworkMediaImageProvider', () {
    test('equality is based on url, scale and cache directory path', () {
      const url = 'https://example.com/a.png';
      final a = CacheNetworkMediaImageProvider(url, cacheDirectory: tempDir);
      final b = CacheNetworkMediaImageProvider(
        url,
        cacheDirectory: Directory(tempDir.path),
      );
      final scaled = CacheNetworkMediaImageProvider(
        url,
        scale: 2.0,
        cacheDirectory: tempDir,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(scaled)));
      expect(a, isNot(equals(const CacheNetworkMediaImageProvider(url))));
    });

    testWidgets('decodes an image from the disk cache', (tester) async {
      const url = 'https://example.com/cached.png';

      await tester.runAsync(() async {
        await DiskCacheManager(tempDir).putImage(url, _transparentPng);

        final info = await _resolve(
          CacheNetworkMediaImageProvider(url, cacheDirectory: tempDir),
        );

        expect(info.image.width, 1);
        expect(info.image.height, 1);
        info.dispose();
      });
    });

    testWidgets('reports errors and evicts itself', (tester) async {
      // Not in the disk cache, and the test binding answers every HTTP
      // request with status 400, so the download fails.
      final provider = CacheNetworkMediaImageProvider(
        'https://example.com/missing.png',
        cacheDirectory: tempDir,
      );

      await tester.runAsync(() async {
        await expectLater(_resolve(provider), throwsA(isA<Exception>()));
        // Let the scheduled eviction run.
        await Future<void>.delayed(Duration.zero);
      });

      expect(
        PaintingBinding.instance.imageCache.containsKey(provider),
        isFalse,
      );
    });
  });
}
