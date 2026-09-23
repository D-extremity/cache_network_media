import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'base_media_provider.dart';

/// Provider for Lottie animation files.
///
/// Lottie JSON files share the disk cache used for images and SVGs, so
/// expiry, size limits and `CacheNetworkMedia` apply to them as well.
/// The animation is rendered from the loaded bytes with [Lottie.memory],
/// so it does not depend on the cached file still existing afterwards.
///
/// @author @D-extremity
/// @see [BaseMediaProvider] for base caching functionality
class LottieMediaProvider extends BaseMediaProvider {
  LottieMediaProvider({required super.url, super.cacheDirectory});

  /// Builds a [Lottie.memory] widget from the cached JSON bytes.
  ///
  /// @param data The Lottie JSON bytes to render
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
  @override
  Widget buildWidget({
    required Uint8List data,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    Map<String, dynamic>? extraParams,
  }) {
    return Lottie.memory(
      data,
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
