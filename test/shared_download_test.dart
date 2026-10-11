import 'dart:io';

import 'package:cache_network_media/src/providers/base_media_provider.dart';
import 'package:cache_network_media/src/providers/image_media_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _CountingProvider extends ImageMediaProvider {
  _CountingProvider({
    required super.url,
    super.cacheDirectory,
    this.fail = false,
  });

  static int downloads = 0;
  final bool fail;

  @override
  Future<Uint8List> downloadFromNetwork({
    ValueChanged<DownloadProgress>? onProgress,
  }) async {
    downloads++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (fail) throw Exception('boom');
    return Uint8List.fromList([1, 2, 3]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const url = 'https://example.com/avatar.png';
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('cnm_shared_');
    _CountingProvider.downloads = 0;
  });

  tearDown(() async => dir.delete(recursive: true));

  test('concurrent loads of one URL download once', () async {
    final results = await Future.wait([
      for (var i = 0; i < 20; i++)
        _CountingProvider(url: url, cacheDirectory: dir).fetchMedia(),
    ]);
    expect(_CountingProvider.downloads, 1);
    expect(results.every((r) => r.length == 3), isTrue);
  });

  test('a failed shared download is retried by the next request', () async {
    final failing = Future.wait([
      for (var i = 0; i < 3; i++)
        _CountingProvider(
          url: url,
          cacheDirectory: dir,
          fail: true,
        ).fetchMedia().then<Object?>((_) => null, onError: (Object e) => e),
    ]);
    expect((await failing).every((e) => e != null), isTrue);
    expect(_CountingProvider.downloads, 1);

    await _CountingProvider(url: url, cacheDirectory: dir).fetchMedia();
    expect(_CountingProvider.downloads, 2);
  });
}
