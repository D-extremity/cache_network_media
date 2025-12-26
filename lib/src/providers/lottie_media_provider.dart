import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'base_media_provider.dart';
import '../platform/cache_network_media_method_channel.dart';

/// Provider for Lottie animations
class LottieMediaProvider extends BaseMediaProvider {
  LottieMediaProvider({required super.url, super.cacheDirectory});

  /// Specialized caching for Lottie files - saves as JSON
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

  /// Build Lottie widget from cached file
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
