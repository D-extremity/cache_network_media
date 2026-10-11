import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../core/cache_directory.dart';
import '../core/disk_cache_manager.dart';

/// Abstract base class for all media providers.
///
/// Provides shared functionality for downloading, caching, and managing network media.
/// All media-specific providers extend this class and implement [buildWidget] to
/// render their specific media type.
///
/// Common functionality:
/// - Network downloading with HTTP client
/// - Disk-based caching using [DiskCacheManager]
/// - Platform-specific cache directory resolution
/// - Cache hit/miss logging for debugging
///
/// @author @D-extremity
/// @see [ImageMediaProvider] for image implementation
/// @see [SvgMediaProvider] for SVG implementation
/// @see [LottieMediaProvider] for Lottie implementation
abstract class BaseMediaProvider {
  /// The network URL of the media to fetch
  final String url;

  /// Optional custom cache directory. If null, uses platform default
  final Directory? cacheDirectory;

  /// Internal cache manager instance, created lazily on first use
  DiskCacheManager? _cacheManager;

  /// HTTP headers sent with the download request, e.g. `Authorization` for a
  /// CDN that requires it. The cache is keyed by URL only, so a cached file is
  /// served regardless of the headers.
  final Map<String, String>? headers;

  /// How long the server may take to respond, and to send each next chunk,
  /// before the download fails with a [TimeoutException].
  /// Defaults to [defaultTimeout].
  final Duration? timeout;

  BaseMediaProvider({
    required this.url,
    this.cacheDirectory,
    this.headers,
    this.timeout,
  });

  /// Used when [timeout] is not set.
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// One client for all downloads, so connections are reused.
  static final HttpClient _httpClient = HttpClient();

  /// Fetches media from cache or downloads from network.
  ///
  /// Flow:
  /// 1. Initializes cache manager if needed
  /// 2. Checks cache for existing data
  /// 3. If cache hit, returns cached data immediately
  /// 4. If cache miss, downloads from network
  /// 5. Saves downloaded data to cache
  /// 6. Returns the data
  ///
  /// Entries older than [DiskCacheManager.maxAge] are downloaded again. If
  /// that download fails (for example while offline), the expired copy is
  /// returned instead.
  ///
  /// @return The media data as [Uint8List]
  /// @throws Exception if network request fails
  ///
  /// [onProgress] reports download progress. It is not called when the file
  /// comes from the cache.
  Future<Uint8List> fetchMedia({
    ValueChanged<DownloadProgress>? onProgress,
  }) async {
    final cache = await cacheManager();
    // Callers asking for the same entry while it loads share one future, so
    // 20 list items with the same avatar cause a single read or download.
    final key = cache.fileFor(url).path;
    var load = _inFlight[key];
    if (load == null) {
      load = _InFlightLoad();
      _inFlight[key] = load;
      final started = load;
      started.future = _load(cache, started.report).whenComplete(() {
        _inFlight.remove(key);
      });
    }
    if (onProgress != null) {
      load.listen(onProgress);
    }
    return load.future;
  }

  static final Map<String, _InFlightLoad> _inFlight = {};

  Future<Uint8List> _load(
    DiskCacheManager cache,
    ValueChanged<DownloadProgress> onProgress,
  ) async {
    final cachedData = await cache.getImage(url);
    if (cachedData != null) {
      // debugPrint('Cache HIT for: $url');
      return cachedData;
    }

    // debugPrint('Cache MISS for: $url - Downloading...');

    final Uint8List data;
    try {
      data = await downloadFromNetwork(onProgress: onProgress);
    } catch (_) {
      // An expired copy is better than an error while offline.
      final staleData = await cache.getImage(url, allowStale: true);
      if (staleData != null) {
        // debugPrint('Serving expired cache for: $url');
        return staleData;
      }
      rethrow;
    }
    await cache.putImage(url, data);

    return data;
  }

  /// Downloads media from the network URL.
  ///
  /// Sends [headers] and fails with a [TimeoutException] when the server stops
  /// responding for longer than [timeout]. Reports progress through
  /// [onProgress]. This method can be overridden by subclasses if custom
  /// download logic is needed.
  ///
  /// @return The downloaded media as [Uint8List]
  /// @throws Exception if HTTP status is not 200 or network error occurs
  Future<Uint8List> downloadFromNetwork({
    ValueChanged<DownloadProgress>? onProgress,
  }) async {
    final limit = timeout ?? defaultTimeout;
    final request = await _httpClient.getUrl(Uri.parse(url)).timeout(limit);
    headers?.forEach(request.headers.set);
    final response = await request.close().timeout(limit);

    if (response.statusCode != 200) {
      // Drain so the connection can be reused.
      await response.drain<void>().timeout(limit, onTimeout: () {});
      throw Exception('HTTP ${response.statusCode}: Failed to load $url');
    }

    final total = response.contentLength >= 0 ? response.contentLength : null;
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response.timeout(limit)) {
      builder.add(chunk);
      onProgress?.call(DownloadProgress(builder.length, total));
    }
    return builder.takeBytes();
  }

  /// Builds the widget for this media type.
  ///
  /// Must be implemented by subclasses to create the appropriate widget
  /// for their media type (Image, SvgPicture, Lottie, etc.).
  ///
  /// @param data The media data to display
  /// @param width Optional width for the widget
  /// @param height Optional height for the widget
  /// @param fit How to inscribe the media into the allocated space
  /// @param alignment How to align the media within its bounds
  /// @param extraParams Additional type-specific parameters
  /// @return The configured widget for this media type
  Widget buildWidget({
    required Uint8List data,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    Map<String, dynamic>? extraParams,
  });

  /// Initializes the cache manager with appropriate directory.
  ///
  /// If [cacheDirectory] is provided, uses that directory.
  /// Otherwise, gets platform-specific cache directory and creates
  /// a `cache_network_media` subdirectory.
  ///
  /// @return Initialized [DiskCacheManager] instance
  /// @throws Exception if unable to get or create cache directory
  Future<DiskCacheManager> _initCacheManager() async {
    return DiskCacheManager(await resolveCacheDirectory(cacheDirectory));
  }

  /// The disk cache backing this provider, created on first use.
  @protected
  Future<DiskCacheManager> cacheManager() async {
    return _cacheManager ??= await _initCacheManager();
  }

  /// Clears the cached file for this media URL.
  ///
  /// Deletes the cached file if it exists. Useful for forcing a fresh
  /// download or managing cache size.
  ///
  /// @throws Exception if unable to delete the file
  Future<void> clearCache() async {
    _cacheManager ??= await _initCacheManager();
    await _cacheManager!.remove(url);
  }
}

/// Progress of a download, reported while media loads from the network.
@immutable
class DownloadProgress {
  const DownloadProgress(this.received, this.total);

  /// Bytes received so far.
  final int received;

  /// Total size in bytes, or `null` if the server did not send one.
  final int? total;

  /// A value from 0.0 to 1.0, or `null` if [total] is unknown. Pass it to
  /// `CircularProgressIndicator(value: ...)`; `null` shows the indeterminate
  /// animation.
  double? get fraction {
    final total = this.total;
    if (total == null || total == 0) {
      return null;
    }
    return (received / total).clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) =>
      other is DownloadProgress &&
      other.received == received &&
      other.total == total;

  @override
  int get hashCode => Object.hash(received, total);
}

/// A running load that several callers share, and their progress listeners.
class _InFlightLoad {
  late final Future<Uint8List> future;
  final List<ValueChanged<DownloadProgress>> _listeners = [];
  DownloadProgress? _last;

  void listen(ValueChanged<DownloadProgress> listener) {
    _listeners.add(listener);
    final last = _last;
    if (last != null) {
      listener(last);
    }
  }

  void report(DownloadProgress progress) {
    _last = progress;
    for (final listener in List.of(_listeners)) {
      listener(progress);
    }
  }
}
