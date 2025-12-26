import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'base_media_provider.dart';

/**
 * Provider for standard image formats (PNG, JPG, WebP, etc.).
 * 
 * Handles caching and rendering of raster images using Flutter's
 * [Image.memory] widget. Supports all standard image properties
 * including color blending, filtering, and accessibility.
 * 
 * Supported formats: PNG, JPG, JPEG, WebP, GIF, BMP, WBMP
 * 
 * @author @D-extremity
 * @see [BaseMediaProvider] for caching implementation
 */
class ImageMediaProvider extends BaseMediaProvider {
  ImageMediaProvider({required super.url, super.cacheDirectory});

  /**
   * Builds an [Image.memory] widget from cached image data.
   * 
   * @param data The image bytes to display
   * @param width Optional width for the image
   * @param height Optional height for the image
   * @param fit How to inscribe the image into the allocated space
   * @param alignment How to align the image within its bounds
   * @param extraParams Map containing image-specific properties from [CacheNetworkMediaWidget.img]
   * @return A configured [Image] widget
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
    return Image.memory(
      data,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment ?? Alignment.center,
      frameBuilder: extraParams?['frameBuilder'] as ImageFrameBuilder?,
      errorBuilder: extraParams?['errorBuilder'] as ImageErrorWidgetBuilder?,
      semanticLabel: extraParams?['semanticLabel'] as String?,
      excludeFromSemantics:
          extraParams?['excludeFromSemantics'] as bool? ?? false,
      color: extraParams?['color'] as Color?,
      opacity: extraParams?['opacity'] as Animation<double>?,
      colorBlendMode: extraParams?['colorBlendMode'] as BlendMode?,
      repeat: extraParams?['repeat'] as ImageRepeat? ?? ImageRepeat.noRepeat,
      centerSlice: extraParams?['centerSlice'] as Rect?,
      matchTextDirection: extraParams?['matchTextDirection'] as bool? ?? false,
      gaplessPlayback: extraParams?['gaplessPlayback'] as bool? ?? false,
      isAntiAlias: extraParams?['isAntiAlias'] as bool? ?? false,
      filterQuality:
          extraParams?['filterQuality'] as FilterQuality? ??
          FilterQuality.medium,
    );
  }
}
