import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'image_media_provider.dart';

/// An [ImageProvider] that loads an image from the network and caches it on
/// disk, using the same cache as `CacheNetworkMediaWidget.img`.
///
/// Decoded images go through Flutter's [ImageCache], so the same URL is only
/// decoded once while it stays in memory. Because it is a regular
/// [ImageProvider], it works anywhere Flutter accepts one:
///
/// ```dart
/// CircleAvatar(
///   backgroundImage: CacheNetworkMediaImageProvider('https://example.com/a.png'),
/// )
///
/// Container(
///   decoration: BoxDecoration(
///     image: DecorationImage(
///       image: CacheNetworkMediaImageProvider('https://example.com/bg.jpg'),
///       fit: BoxFit.cover,
///     ),
///   ),
/// )
///
/// await precacheImage(
///   CacheNetworkMediaImageProvider('https://example.com/hero.png'),
///   context,
/// );
/// ```
///
/// To decode at a smaller size (recommended for thumbnails), wrap it in
/// [ResizeImage]:
///
/// ```dart
/// Image(
///   image: ResizeImage(
///     CacheNetworkMediaImageProvider('https://example.com/photo.jpg'),
///     width: 200,
///   ),
/// )
/// ```
class CacheNetworkMediaImageProvider
    extends ImageProvider<CacheNetworkMediaImageProvider> {
  /// Creates a provider for the image at [url].
  const CacheNetworkMediaImageProvider(
    this.url, {
    this.scale = 1.0,
    this.cacheDirectory,
    this.headers,
    this.timeout,
  });

  /// The network URL of the image.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// Optional custom cache directory. If null, uses the platform default.
  final Directory? cacheDirectory;

  /// HTTP headers sent with the download, e.g. `Authorization`.
  final Map<String, String>? headers;

  /// How long the server may take to respond before the download fails.
  /// Defaults to 30 seconds.
  final Duration? timeout;

  @override
  Future<CacheNetworkMediaImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<CacheNetworkMediaImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    CacheNetworkMediaImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.url,
      informationCollector:
          () => <DiagnosticsNode>[
            DiagnosticsProperty<ImageProvider>('Image provider', this),
            DiagnosticsProperty<CacheNetworkMediaImageProvider>(
              'Image key',
              key,
            ),
          ],
    );
  }

  Future<ui.Codec> _loadAsync(
    CacheNetworkMediaImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    try {
      assert(key == this);
      final media = ImageMediaProvider(
        url: key.url,
        cacheDirectory: key.cacheDirectory,
        headers: key.headers,
        timeout: key.timeout,
      );
      final bytes = await media.fetchMedia();

      if (bytes.lengthInBytes == 0) {
        await media.clearCache();
        throw StateError(
          '${key.url} is empty and cannot be loaded as an image.',
        );
      }

      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      try {
        return await decode(buffer);
      } catch (_) {
        await media.clearCache();
        rethrow;
      }
    } catch (_) {
      // Evict so a later attempt (e.g. after connectivity returns) retries
      // instead of reusing the failed completer from the ImageCache.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CacheNetworkMediaImageProvider &&
        other.url == url &&
        other.scale == scale &&
        other.cacheDirectory?.path == cacheDirectory?.path &&
        mapEquals(other.headers, headers) &&
        other.timeout == timeout;
  }

  @override
  int get hashCode => Object.hash(
    url,
    scale,
    cacheDirectory?.path,
    timeout,
    headers == null
        ? null
        : Object.hashAllUnordered(
          headers!.entries.map((e) => Object.hash(e.key, e.value)),
        ),
  );

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CacheNetworkMediaImageProvider')}'
      '("$url", scale: ${scale.toStringAsFixed(1)})';
}
