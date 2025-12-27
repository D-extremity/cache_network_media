import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'base_media_provider.dart';

/// Provider for SVG (Scalable Vector Graphics) files.
///
/// Handles caching and rendering of SVG vector graphics using the
/// [flutter_svg] package. Supports color filtering, theming, and
/// all SVG-specific rendering options.
///
/// SVG files maintain their vector properties and can be scaled
/// without loss of quality.
///
/// @author @D-extremity
/// @see [BaseMediaProvider] for caching implementation
class SvgMediaProvider extends BaseMediaProvider {
  SvgMediaProvider({required super.url, super.cacheDirectory});

  /// Builds a [SvgPicture.memory] widget from cached SVG data.
  ///
  /// @param data The SVG bytes to render
  /// @param width Optional width for the SVG
  /// @param height Optional height for the SVG
  /// @param fit How to inscribe the SVG into the allocated space (defaults to [BoxFit.contain])
  /// @param alignment How to align the SVG within its bounds
  /// @param extraParams Map containing SVG-specific properties from [CacheNetworkMediaWidget.svg]
  /// @return A configured [SvgPicture] widget
  @override
  Widget buildWidget({
    required Uint8List data,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    Map<String, dynamic>? extraParams,
  }) {
    return SvgPicture.memory(
      data,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      alignment: alignment as Alignment? ?? Alignment.center,
      colorFilter: extraParams?['colorFilter'] as ColorFilter?,
      theme: extraParams?['theme'] as SvgTheme?,
      semanticsLabel: extraParams?['semanticsLabel'] as String?,
      excludeFromSemantics:
          extraParams?['excludeFromSemantics'] as bool? ?? false,
      clipBehavior: extraParams?['clipBehavior'] as Clip? ?? Clip.hardEdge,
      allowDrawingOutsideViewBox:
          extraParams?['allowDrawingOutsideViewBox'] as bool? ?? false,
      matchTextDirection: extraParams?['matchTextDirection'] as bool? ?? false,
    );
  }
}
