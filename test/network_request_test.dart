import 'dart:async';
import 'dart:io';

import 'package:cache_network_media/cache_network_media.dart';
import 'package:cache_network_media/src/providers/image_media_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late Directory dir;
  late String base;
  final seenHeaders = <String, String?>{};
  final remotePorts = <int>{};

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('cnm_net_');
    seenHeaders.clear();
    remotePorts.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    base = 'http://${server.address.host}:${server.port}';
    server.listen((req) async {
      remotePorts.add(req.connectionInfo!.remotePort);
      seenHeaders['authorization'] = req.headers.value('authorization');
      if (req.uri.path == '/hang') {
        return; // never answers
      }
      if (req.uri.path == '/missing') {
        req.response.statusCode = 404;
        await req.response.close();
        return;
      }
      req.response.contentLength = 4000;
      for (var i = 0; i < 4; i++) {
        req.response.add(List.filled(1000, i));
        await req.response.flush();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await req.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
    await dir.delete(recursive: true);
  });

  test('sends headers', () async {
    await ImageMediaProvider(
      url: '$base/a.png',
      cacheDirectory: dir,
      headers: {'Authorization': 'Bearer token'},
    ).fetchMedia();
    expect(seenHeaders['authorization'], 'Bearer token');
  });

  test('reports progress up to the total', () async {
    final updates = <DownloadProgress>[];
    final bytes = await ImageMediaProvider(
      url: '$base/b.png',
      cacheDirectory: dir,
    ).fetchMedia(onProgress: updates.add);
    expect(bytes.length, 4000);
    expect(updates, isNotEmpty);
    expect(updates.last, const DownloadProgress(4000, 4000));
    expect(updates.last.fraction, 1.0);
  });

  test('times out when the server never responds', () async {
    await expectLater(
      ImageMediaProvider(
        url: '$base/hang',
        cacheDirectory: dir,
        timeout: const Duration(milliseconds: 200),
      ).fetchMedia(),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('a non-200 status throws and the connection is reused', () async {
    await expectLater(
      ImageMediaProvider(
        url: '$base/missing',
        cacheDirectory: dir,
      ).fetchMedia(),
      throwsException,
    );
    await ImageMediaProvider(
      url: '$base/c.png',
      cacheDirectory: dir,
    ).fetchMedia();
    expect(remotePorts.length, 1);
  });
}
