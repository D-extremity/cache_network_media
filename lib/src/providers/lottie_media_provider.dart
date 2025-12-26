import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'base_media_provider.dart';
import '../platform/cache_network_media_method_channel.dart';

/**
 * Provider for Lottie animation files with specialized JSON-based caching.
 * 
 * This provider handles downloading, caching, and rendering Lottie animations.
 * Unlike image providers that cache as binary data, this provider:
 * - Saves Lottie files as JSON with `.json` extension
 * - Stores in a dedicated `lottie/` subdirectory
 * - Uses [Lottie.file] for better performance than memory-based loading
 * 
 * Cache structure:
 * ```
 * cache_network_media/
 * └── lottie/
 *     └── <safe_url_hash>.json
 * ```
 * 
 * @author @D-extremity
 * @see [BaseMediaProvider] for base caching functionality
 */
class LottieMediaProvider extends BaseMediaProvider {
  LottieMediaProvider({required super.url, super.cacheDirectory});

  /**
   * Fetches Lottie file from cache or network.
   * 
   * This method implements specialized caching for Lottie animations:
   * 1. Checks if the JSON file exists in the lottie cache directory
   * 2. If found, returns the cached file immediately
   * 3. If not found, downloads from network and saves as `.json`
   * 
   * The file is saved with a sanitized URL as the filename to ensure
   * filesystem compatibility across platforms.
   * 
   * @return A [File] object pointing to the cached Lottie JSON file
   * @throws Exception if unable to download or save the file
   */
  Future<File> fetchLottieFile() async {
    final cacheDir = await _getLottieCacheDirectory();
    final safeKey = url.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final cachedFile = File('${cacheDir.path}/$safeKey.json');

    // Check if file exists in cache
    if (await cachedFile.exists()) {
      debugPrint('Lottie Cache HIT for: $url');
      return cachedFile;
    }

    debugPrint('Lottie Cache MISS for: $url - Downloading...');

    // Download from network
    final data = await downloadFromNetwork();

    // Save as JSON file
    await cachedFile.writeAsBytes(data, flush: true);

    debugPrint('Lottie cached to: ${cachedFile.path}');
    return cachedFile;
  }

  /**
   * Gets or creates the dedicated Lottie cache directory.
   * 
   * Creates a `lottie/` subdirectory within the cache path to keep
   * Lottie JSON files organized separately from other cached media.
   * 
   * @return A [Directory] object for the Lottie cache location
   * @throws Exception if unable to get or create the directory
   */
  Future<Directory> _getLottieCacheDirectory() async {
    if (cacheDirectory != null && cacheDirectory!.path.isNotEmpty) {
      final lottieDir = Directory('${cacheDirectory!.path}/lottie');
      if (!await lottieDir.exists()) {
        await lottieDir.create(recursive: true);
      }
      return lottieDir;
    }

    final cacheDirPath = await MethodChannelCacheNetworkMedia()
        .getTempCacheDir();
    if (cacheDirPath == null || cacheDirPath.isEmpty) {
      throw Exception('Unable to get cache directory path.');
    }

    final directory = Directory('$cacheDirPath/cache_network_media/lottie');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  /**
   * Not used for Lottie animations.
   * 
   * This method is required by [BaseMediaProvider] but is not used for Lottie.
   * Lottie animations use [buildLottieWidget] instead, which works with cached files.
   * 
   * @throws UnimplementedError always, as this method should not be called
   */
  @override
  Widget buildWidget({
    required Uint8List data,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    Map<String, dynamic>? extraParams,
  }) {
    // This method is not used for Lottie, but required by base class
    // Use buildLottieWidget instead
    throw UnimplementedError('Use buildLottieWidget for Lottie animations');
  }

  /**
   * Builds a Lottie widget from a cached JSON file.
   * 
   * Creates a [Lottie.file] widget with the specified properties.
   * This method is called after [fetchLottieFile] has retrieved the cached file.
   * 
   * @param lottieFile The cached Lottie JSON file to render
   * @param width The width of the animation widget
   * @param height The height of the animation widget
   * @param fit How to inscribe the animation into the allocated space
   * @param alignment How to align the animation within its bounds
   * @param extraParams Map containing Lottie-specific properties:
   *   - `repeat`: Whether to loop the animation
   *   - `reverse`: Whether to play in reverse
   *   - `animate`: Whether to start immediately
   *   - `frameRate`: Custom frame rate (FPS)
   *   - `delegates`: Custom [LottieDelegates]
   *   - `options`: Additional [LottieOptions]
   *   - `addRepaintBoundary`: Whether to add repaint boundary
   *   - `renderCache`: Cache strategy for rendering
   * 
   * @return A configured [Lottie] widget
   */
  Widget buildLottieWidget({
    required File lottieFile,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    Map<String, dynamic>? extraParams,
  }) {
    return Lottie.file(
      lottieFile,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      alignment: alignment as Alignment? ?? Alignment.center,

      // Lottie-specific properties
      repeat: extraParams?['repeat'] as bool? ?? true,
      reverse: extraParams?['reverse'] as bool? ?? false,
      animate: extraParams?['animate'] as bool? ?? true,
      frameRate: extraParams?['frameRate'] != null
          ? FrameRate(extraParams!['frameRate'] as double)
          : FrameRate.max,
      delegates: extraParams?['delegates'] as LottieDelegates?,
      options: extraParams?['options'] as LottieOptions?,
      addRepaintBoundary: extraParams?['addRepaintBoundary'] as bool? ?? true,
      renderCache: extraParams?['renderCache'] as RenderCache?,
    );
  }
}
