import 'dart:convert';
import 'dart:io';

import 'package:cache_network_media/cache_network_media.dart';
import 'package:cache_network_media/src/core/disk_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// A valid 1x1 transparent PNG.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
);

final _svg = utf8.encode(
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1">'
  '<rect width="1" height="1"/></svg>',
);

/// Lets real file I/O finish, then delivers the results to the widgets.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
}

void main() {
  late Directory tempDir;
  late DiskCacheManager cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cnm_widget_test_');
    cache = DiskCacheManager(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('parent rebuilds reuse the loaded media', (tester) async {
    const url = 'https://example.com/rebuild.png';
    await tester.runAsync(() => cache.putImage(url, _png));

    Widget build() => Directionality(
      textDirection: TextDirection.ltr,
      child: CacheNetworkMediaWidget.img(url: url, cacheDirectory: tempDir),
    );

    await tester.pumpWidget(build());
    await _settle(tester);
    expect(find.byType(Image), findsOneWidget);

    // If a rebuild started a new load, the placeholder would show again and
    // the load would now fail, since the file is gone and HTTP returns 400.
    await tester.runAsync(() => cache.remove(url));
    await tester.pumpWidget(build());
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a new url starts a new load', (tester) async {
    const first = 'https://example.com/first.png';
    const second = 'https://example.com/second.svg';
    await tester.runAsync(() async {
      await cache.putImage(first, _png);
      await cache.putImage(second, _svg);
    });

    Widget build(Widget child) {
      return Directionality(textDirection: TextDirection.ltr, child: child);
    }

    await tester.pumpWidget(
      build(CacheNetworkMediaWidget.img(url: first, cacheDirectory: tempDir)),
    );
    await _settle(tester);
    expect(find.byType(Image), findsOneWidget);

    await tester.pumpWidget(
      build(CacheNetworkMediaWidget.svg(url: second, cacheDirectory: tempDir)),
    );
    await _settle(tester);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('SVG resolves AlignmentDirectional', (tester) async {
    const url = 'https://example.com/aligned.svg';
    await tester.runAsync(() => cache.putImage(url, _svg));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: CacheNetworkMediaWidget.svg(
          url: url,
          cacheDirectory: tempDir,
          alignment: AlignmentDirectional.topStart,
        ),
      ),
    );
    await _settle(tester);

    expect(tester.takeException(), isNull);
    final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(picture.alignment, Alignment.topRight);
  });
}
