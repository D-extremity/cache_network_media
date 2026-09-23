import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'base_media_provider.dart';

/// Provider for Lottie animation files.
///
/// Lottie JSON files share the disk cache used for images and SVGs, so
/// expiry, size limits and `CacheNetworkMedia` apply to them as well.
/// The cached file is rendered with [Lottie.file].
///
/// @author @D-extremity
/// @see [BaseMediaProvider] for base caching functionality
class LottieMediaProvider extends BaseMediaProvider {
  LottieMediaProvider({required super.url, super.cacheDirectory});

  /// Fetches the Lottie file from cache or network.
  ///
  /// Uses the same caching rules as [fetchMedia], then returns the cached
  /// file so it can be rendered with [Lottie.file].
  ///
  /// @return A [File] pointing to the cached Lottie JSON
  /// @throws Exception if unable to download or save the file
  Future<File> fetchLottieFile() async {
    await fetchMedia();
    final cache = await cacheManager();
    return cache.fileFor(url);
  }

  /// Not used for Lottie animations.
  ///
  /// This method is required by [BaseMediaProvider] but is not used for Lottie.
  /// Lottie animations use [buildLottieWidget] instead, which works with cached files.
  ///
  /// @throws UnimplementedError always, as this method should not be called
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

  /// Builds a Lottie widget from a cached JSON file.
  ///
  /// Creates a [Lottie.file] widget with the specified properties.
  /// This method is called after [fetchLottieFile] has retrieved the cached file.
  ///
  /// @param lottieFile The cached Lottie JSON file to render
  /// @param width The width of the animation widget
  /// @param height The height of the animation widget
  /// @param fit How to inscribe the animation into the allocated space
  /// @param alignment How to align the animation within its bounds
  /// @param extraParams Map containing Lottie-specific properties:
  ///   - `repeat`: Whether to loop the animation
  ///   - `reverse`: Whether to play in reverse
  ///   - `animate`: Whether to start immediately
  ///   - `frameRate`: Custom frame rate (FPS)
  ///   - `delegates`: Custom [LottieDelegates]
  ///   - `options`: Additional [LottieOptions]
  ///   - `addRepaintBoundary`: Whether to add repaint boundary
  ///   - `renderCache`: Cache strategy for rendering
  ///
  /// @return A configured [Lottie] widget
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
      // The widget passes an already resolved Alignment.
      alignment: (alignment ?? Alignment.center).resolve(null),

      // Lottie-specific properties
      repeat: extraParams?['repeat'] as bool? ?? true,
      reverse: extraParams?['reverse'] as bool? ?? false,
      animate: extraParams?['animate'] as bool? ?? true,
      frameRate:
          extraParams?['frameRate'] != null
              ? FrameRate(extraParams!['frameRate'] as double)
              : FrameRate.max,
      delegates: extraParams?['delegates'] as LottieDelegates?,
      options: extraParams?['options'] as LottieOptions?,
      addRepaintBoundary: extraParams?['addRepaintBoundary'] as bool? ?? true,
      renderCache: extraParams?['renderCache'] as RenderCache?,
    );
  }
}
