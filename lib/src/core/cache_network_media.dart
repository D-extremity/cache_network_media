import 'dart:io';

import '../providers/cache_network_media_image_provider.dart';
import '../providers/image_media_provider.dart';
import 'cache_directory.dart';
import 'disk_cache_manager.dart';

/// Cache settings and cache management shared by images, SVGs and Lottie.
///
/// ```dart
/// void main() {
///   CacheNetworkMedia.maxAge = const Duration(days: 7);
///   CacheNetworkMedia.maxCacheSizeBytes = 200 * 1024 * 1024; // 200 MB
///   runApp(const MyApp());
/// }
/// ```
///
/// If you pass a custom `cacheDirectory` to widgets or providers, pass the
/// same directory to [clear], [evict] and [prefetch].
abstract final class CacheNetworkMedia {
  /// How long a downloaded file stays fresh before it is downloaded again.
  ///
  /// If the new download fails (for example while offline), the expired copy
  /// is still shown. Defaults to `null`, which never expires.
  static Duration? get maxAge => DiskCacheManager.maxAge;

  static set maxAge(Duration? value) => DiskCacheManager.maxAge = value;

  /// Upper bound for the disk cache, in bytes.
  ///
  /// When a download pushes the cache over this size, the least recently used
  /// files are deleted first. Defaults to `null`, which means no limit.
  static int? get maxCacheSizeBytes => DiskCacheManager.maxSizeBytes;

  static set maxCacheSizeBytes(int? value) =>
      DiskCacheManager.maxSizeBytes = value;

  /// Deletes every cached file.
  ///
  /// Images that Flutter has already decoded stay in its `ImageCache` until
  /// they are evicted from it.
  static Future<void> clear({Directory? cacheDirectory}) async {
    final directory = await resolveCacheDirectory(cacheDirectory);
    await DiskCacheManager(directory).clear();
  }

  /// Removes [url] from the disk cache, so the next load downloads it again.
  ///
  /// Also removes `CacheNetworkMediaImageProvider(url)` from Flutter's
  /// `ImageCache`. Flutter stores providers with a custom `scale`, or wrapped
  /// in `ResizeImage`, as separate entries that cannot be looked up by URL.
  /// Evict those with the same provider you display:
  ///
  /// ```dart
  /// await CacheNetworkMedia.evict(url);
  /// await ResizeImage(CacheNetworkMediaImageProvider(url), width: 200).evict();
  /// ```
  static Future<void> evict(String url, {Directory? cacheDirectory}) async {
    final directory = await resolveCacheDirectory(cacheDirectory);
    await DiskCacheManager(directory).remove(url);
    await CacheNetworkMediaImageProvider(
      url,
      cacheDirectory: cacheDirectory,
    ).evict();
  }

  /// Downloads [url] into the disk cache without displaying it.
  ///
  /// Works for images, SVGs and Lottie files. Does nothing if a fresh copy is
  /// already cached.
  static Future<void> prefetch(String url, {Directory? cacheDirectory}) async {
    await ImageMediaProvider(
      url: url,
      cacheDirectory: cacheDirectory,
    ).fetchMedia();
  }
}
