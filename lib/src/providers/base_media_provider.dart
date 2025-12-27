import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../core/disk_cache_manager.dart';
import '../platform/cache_network_media_method_channel.dart';

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

  BaseMediaProvider({required this.url, this.cacheDirectory});

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
  /// @return The media data as [Uint8List]
  /// @throws Exception if network request fails
  Future<Uint8List> fetchMedia() async {
    _cacheManager ??= await _initCacheManager();
    Uint8List? cachedData = await _cacheManager?.getImage(url);
    if (cachedData != null) {
      debugPrint('Cache HIT for: $url');
      return cachedData;
    }

    debugPrint('Cache MISS for: $url - Downloading...');

    final data = await downloadFromNetwork();
    await _cacheManager?.putImage(url, data);

    return data;
  }

  /// Downloads media from the network URL.
  ///
  /// Uses [HttpClient] to perform the download. This method can be overridden
  /// by subclasses if custom download logic is needed.
  ///
  /// @return The downloaded media as [Uint8List]
  /// @throws Exception if HTTP status is not 200 or network error occurs
  Future<Uint8List> downloadFromNetwork() async {
    final uri = Uri.parse(url);
    final httpClient = HttpClient();

    try {
      final request = await httpClient.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: Failed to load $url');
      }

      return await consolidateHttpClientResponseBytes(response);
    } finally {
      httpClient.close();
    }
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
    if (cacheDirectory != null && cacheDirectory!.path.isNotEmpty) {
      debugPrint('Using provided cache directory: ${cacheDirectory!.path}');
      return DiskCacheManager(cacheDirectory!);
    }

    final cacheDirPath = await MethodChannelCacheNetworkMedia()
        .getTempCacheDir();
    if (cacheDirPath == null || cacheDirPath.isEmpty) {
      throw Exception('Unable to get cache directory path.');
    }

    final directory = Directory('$cacheDirPath/cache_network_media');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return DiskCacheManager(directory);
  }

  /// Clears the cached file for this media URL.
  ///
  /// Deletes the cached file if it exists. Useful for forcing a fresh
  /// download or managing cache size.
  ///
  /// @throws Exception if unable to delete the file
  Future<void> clearCache() async {
    _cacheManager ??= await _initCacheManager();
    final safeKey = url.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final file = File('${_cacheManager!.directory.path}/$safeKey.cache_image');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
