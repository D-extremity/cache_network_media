import 'dart:io';
import 'dart:typed_data';

import 'package:cache_network_media/cache_network_media.dart';
import 'package:cache_network_media/src/core/disk_cache_manager.dart';
import 'package:cache_network_media/src/providers/image_media_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const url = 'https://example.com/image.png';

  late Directory tempDir;
  late DiskCacheManager cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cnm_cache_control_');
    cache = DiskCacheManager(tempDir);
  });

  tearDown(() async {
    CacheNetworkMedia.maxAge = null;
    CacheNetworkMedia.maxCacheSizeBytes = null;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> makeOld(String key) {
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    return cache.fileFor(key).setLastModified(twoDaysAgo);
  }

  group('maxAge', () {
    test('expired entries are misses but still readable as stale', () async {
      await cache.putImage(url, Uint8List(4));
      await makeOld(url);
      CacheNetworkMedia.maxAge = const Duration(days: 1);

      expect(await cache.getImage(url), isNull);
      expect(await cache.getImage(url, allowStale: true), hasLength(4));
    });

    test('serves the expired copy when the download fails', () async {
      // The test binding answers every HTTP request with status 400.
      await cache.putImage(url, Uint8List(4));
      await makeOld(url);
      CacheNetworkMedia.maxAge = const Duration(days: 1);

      final provider = ImageMediaProvider(url: url, cacheDirectory: tempDir);

      expect(await provider.fetchMedia(), hasLength(4));
    });
  });

  test('maxCacheSizeBytes deletes least recently used entries', () async {
    final now = DateTime.now();
    const keys = ['a', 'b', 'c'];
    for (var i = 0; i < keys.length; i++) {
      await cache.putImage(keys[i], Uint8List(6));
      final file = cache.fileFor(keys[i]);
      await file.setLastAccessed(now.subtract(Duration(minutes: 10 - i)));
    }
    CacheNetworkMedia.maxCacheSizeBytes = 10;

    await cache.trim();

    expect(await cache.fileFor('a').exists(), isFalse);
    expect(await cache.fileFor('b').exists(), isFalse);
    expect(await cache.fileFor('c').exists(), isTrue);
  });

  test('clear deletes cache entries and nothing else', () async {
    await cache.putImage(url, Uint8List(1));
    final unrelated = File('${tempDir.path}/keep.txt');
    await unrelated.writeAsString('keep');

    await CacheNetworkMedia.clear(cacheDirectory: tempDir);

    expect(await cache.fileFor(url).exists(), isFalse);
    expect(await unrelated.exists(), isTrue);
  });

  test('evict removes a single entry', () async {
    await cache.putImage('a', Uint8List(1));
    await cache.putImage('b', Uint8List(1));

    await CacheNetworkMedia.evict('a', cacheDirectory: tempDir);

    expect(await cache.getImage('a'), isNull);
    expect(await cache.getImage('b'), isNotNull);
  });

  test('prefetch keeps a fresh entry without downloading again', () async {
    await cache.putImage(url, Uint8List(3));

    await CacheNetworkMedia.prefetch(url, cacheDirectory: tempDir);

    expect(await cache.getImage(url), hasLength(3));
  });

  test('memCacheWidth and memCacheHeight decode at a smaller size', () {
    final provider = ImageMediaProvider(url: url);
    final Widget widget = provider.buildWidget(
      data: Uint8List(0),
      extraParams: const {'cacheWidth': 100, 'cacheHeight': 50},
    );

    final resized = (widget as Image).image as ResizeImage;
    expect(resized.width, 100);
    expect(resized.height, 50);
  });
}
