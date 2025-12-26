import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../providers/base_media_provider.dart';
import '../providers/image_media_provider.dart';
import '../providers/svg_media_provider.dart';
import '../providers/lottie_media_provider.dart';

/// A widget that loads and caches network media including images, SVG, and Lottie animations.
/// 
/// This widget provides efficient caching for various media types fetched from network URLs.
/// It automatically handles downloading, caching, and displaying media with support for
/// placeholders and error handling.
/// 
/// Supported media types:
/// - Images (PNG, JPG, WebP, etc.) via [CacheNetworkMediaWidget.img]
/// - SVG vector graphics via [CacheNetworkMediaWidget.svg]
/// - Lottie animations via [CacheNetworkMediaWidget.lottie]
/// 
/// Example:
/// ```dart
/// CacheNetworkMediaWidget.img(
///   url: 'https://example.com/image.png',
///   width: 200,
///   height: 200,
///   placeholder: CircularProgressIndicator(),
/// )
/// ```
/// 
/// @author @D-extremity
/// @see [ImageMediaProvider] for image caching implementation
/// @see [SvgMediaProvider] for SVG caching implementation
/// @see [LottieMediaProvider] for Lottie caching implementation
class CacheNetworkMediaWidget extends StatelessWidget {
  /// The network URL of the media to load and cache
  final String url;

  /// Internal media provider instance handling the specific media type
  final BaseMediaProvider _provider;

  /// Flag indicating if this widget is displaying a Lottie animation
  final bool _isLottie;

  /// The width of the widget
  ///
  /// If null, the widget will use its natural width
  final double? width;

  /// The height of the widget
  ///
  /// If null, the widget will use its natural height
  final double? height;

  /// How the media should be inscribed into the allocated space
  ///
  /// Defaults vary by media type:
  /// - Images: No default (uses Flutter's Image default)
  /// - SVG & Lottie: [BoxFit.contain]
  final BoxFit? fit;

  /// How to align the media within its bounds
  ///
  /// Defaults to [Alignment.center]
  final AlignmentGeometry alignment;

  /// Widget displayed while the media is being loaded
  ///
  /// If null, shows a [CircularProgressIndicator] centered in a [SizedBox]
  /// with the specified [width] and [height]
  final Widget? placeholder;

  /// Callback for building a widget when an error occurs
  ///
  /// If null, displays a red error icon
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  /// Type-specific properties stored as Map
  final Map<String, dynamic> _extraParams;

  const CacheNetworkMediaWidget._({
    super.key,
    required this.url,
    required BaseMediaProvider provider,
    bool isLottie = false,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorBuilder,
    Map<String, dynamic>? extraParams,
  }) : _provider = provider,
       _isLottie = isLottie,
       _extraParams = extraParams ?? const {};

  /// Creates a cached network image widget for standard image formats.
  /// 
  /// Supports PNG, JPG, JPEG, WebP, and other standard image formats.
  /// Downloaded images are cached locally for faster subsequent loads.
  /// 
  /// Example:
  /// ```dart
  /// CacheNetworkMediaWidget.img(
  ///   url: 'https://example.com/photo.jpg',
  ///   width: 300,
  ///   height: 200,
  ///   fit: BoxFit.cover,
  ///   placeholder: CircularProgressIndicator(),
  ///   color: Colors.blue,
  ///   colorBlendMode: BlendMode.multiply,
  /// )
  /// ```
  /// 
  /// @param url The network URL of the image (required)
  /// @param cacheDirectory Custom directory for caching. If null, uses platform default
  /// @param width The width of the image widget
  /// @param height The height of the image widget
  /// @param fit How to inscribe the image into the space allocated during layout
  /// @param alignment How to align the image within its bounds
  /// @param placeholder Widget to show while the image is loading
  /// @param errorBuilder Builder for custom error widget
  /// @param frameBuilder Builder for custom frame rendering
  /// @param loadingBuilder Builder for custom loading states (not used with Image.memory)
  /// @param imageErrorBuilder Error builder specific to image errors
  /// @param semanticLabel Semantic description for screen readers
  /// @param excludeFromSemantics Whether to exclude from semantics tree
  /// @param color Color to blend with the image
  /// @param opacity Opacity animation to apply to the image
  /// @param colorBlendMode Blend mode for [color]
  /// @param repeat How to paint any portions of the layout bounds not covered by the image
  /// @param centerSlice The center slice for nine-patch images
  /// @param matchTextDirection Whether to flip the image in RTL text direction
  /// @param gaplessPlayback Whether to continue showing the old image while loading new one
  /// @param isAntiAlias Whether to paint the image with anti-aliasing
  /// @param filterQuality The quality of image sampling
  /// 
  /// @author @D-extremity
  CacheNetworkMediaWidget.img({
    Key? key,
    required String url,
    Directory? cacheDirectory,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    Widget? placeholder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? imageErrorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.medium,
  }) : this._(
         key: key,
         url: url,
         provider: ImageMediaProvider(url: url, cacheDirectory: cacheDirectory),
         width: width,
         height: height,
         fit: fit,
         alignment: alignment,
         placeholder: placeholder,
         errorBuilder: errorBuilder,
         extraParams: {
           'frameBuilder': frameBuilder,
           'loadingBuilder': loadingBuilder,
           'errorBuilder': imageErrorBuilder,
           'semanticLabel': semanticLabel,
           'excludeFromSemantics': excludeFromSemantics,
           'color': color,
           'opacity': opacity,
           'colorBlendMode': colorBlendMode,
           'repeat': repeat,
           'centerSlice': centerSlice,
           'matchTextDirection': matchTextDirection,
           'gaplessPlayback': gaplessPlayback,
           'isAntiAlias': isAntiAlias,
           'filterQuality': filterQuality,
         },
       );

  /// Creates a cached SVG vector graphics widget.
  /// 
  /// Supports SVG files with full vector rendering capabilities.
  /// Downloaded SVG files are cached locally for faster subsequent loads.
  /// SVG content can be tinted and themed.
  /// 
  /// Example:
  /// ```dart
  /// CacheNetworkMediaWidget.svg(
  ///   url: 'https://example.com/icon.svg',
  ///   width: 100,
  ///   height: 100,
  ///   color: Colors.blue, // Simple color tinting
  ///   fit: BoxFit.contain,
  /// )
  /// ```
  /// 
  /// @param url The network URL of the SVG file (required)
  /// @param cacheDirectory Custom directory for caching. If null, uses platform default
  /// @param width The width of the SVG widget
  /// @param height The height of the SVG widget
  /// @param fit How to inscribe the SVG into the space allocated during layout
  /// @param alignment How to align the SVG within its bounds
  /// @param placeholder Widget to show while the SVG is loading
  /// @param errorBuilder Builder for custom error widget
  /// @param colorFilter Advanced color filtering for the SVG
  /// @param color Simple color tinting (creates a [ColorFilter] with srcIn blend mode)
  /// @param theme SVG theme for styling
  /// @param semanticsLabel Semantic description for screen readers
  /// @param excludeFromSemantics Whether to exclude from semantics tree
  /// @param clipBehavior How to clip the SVG content
  /// @param allowDrawingOutsideViewBox Whether to allow drawing outside the viewBox
  /// @param matchTextDirection Whether to flip the SVG in RTL text direction
  /// 
  /// @author @D-extremity
  CacheNetworkMediaWidget.svg({
    Key? key,
    required String url,
    Directory? cacheDirectory,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    Widget? placeholder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    ColorFilter? colorFilter,
    Color? color,
    SvgTheme? theme,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    Clip clipBehavior = Clip.hardEdge,
    bool allowDrawingOutsideViewBox = false,
    bool matchTextDirection = false,
  }) : this._(
         key: key,
         url: url,
         provider: SvgMediaProvider(url: url, cacheDirectory: cacheDirectory),
         width: width,
         height: height,
         fit: fit,
         alignment: alignment,
         placeholder: placeholder,
         errorBuilder: errorBuilder,
         extraParams: {
           'colorFilter':
               colorFilter ??
               (color != null
                   ? ColorFilter.mode(color, BlendMode.srcIn)
                   : null),
           'theme': theme,
           'semanticsLabel': semanticsLabel,
           'excludeFromSemantics': excludeFromSemantics,
           'clipBehavior': clipBehavior,
           'allowDrawingOutsideViewBox': allowDrawingOutsideViewBox,
           'matchTextDirection': matchTextDirection,
         },
       );

  /// Creates a cached Lottie animation widget.
  /// 
  /// Supports Lottie JSON animations with full animation control.
  /// Downloaded Lottie files are cached as JSON for better performance and debugging.
  /// Uses file-based caching for optimal Lottie rendering.
  /// 
  /// Example:
  /// ```dart
  /// CacheNetworkMediaWidget.lottie(
  ///   url: 'https://example.com/animation.json',
  ///   width: 200,
  ///   height: 200,
  ///   repeat: true,
  ///   animate: true,
  ///   frameRate: 60.0,
  /// )
  /// ```
  /// 
  /// @param url The network URL of the Lottie JSON file (required)
  /// @param cacheDirectory Custom directory for caching. If null, uses platform default
  /// @param width The width of the Lottie widget
  /// @param height The height of the Lottie widget
  /// @param fit How to inscribe the animation into the space allocated during layout
  /// @param alignment How to align the animation within its bounds
  /// @param placeholder Widget to show while the animation is loading
  /// @param errorBuilder Builder for custom error widget
  /// @param repeat Whether to loop the animation continuously
  /// @param reverse Whether to play the animation in reverse
  /// @param animate Whether to start animating immediately
  /// @param frameRate Custom frame rate for the animation (in FPS)
  /// @param delegates Custom delegates for Lottie rendering
  /// @param options Additional Lottie options
  /// @param addRepaintBoundary Whether to add a repaint boundary for performance
  /// @param renderCache Cache strategy for rendering
  /// 
  /// @author @D-extremity
  CacheNetworkMediaWidget.lottie({
    Key? key,
    required String url,
    Directory? cacheDirectory,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    Widget? placeholder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    bool repeat = true,
    bool reverse = false,
    bool animate = true,
    double? frameRate,
    LottieDelegates? delegates,
    LottieOptions? options,
    bool addRepaintBoundary = true,
    RenderCache? renderCache,
  }) : this._(
         key: key,
         url: url,
         provider: LottieMediaProvider(
           url: url,
           cacheDirectory: cacheDirectory,
         ),
         isLottie: true,
         width: width,
         height: height,
         fit: fit,
         alignment: alignment,
         placeholder: placeholder,
         errorBuilder: errorBuilder,
         extraParams: {
           'repeat': repeat,
           'reverse': reverse,
           'animate': animate,
           'frameRate': frameRate,
           'delegates': delegates,
           'options': options,
           'addRepaintBoundary': addRepaintBoundary,
           'renderCache': renderCache,
         },
       );

  @override
  Widget build(BuildContext context) {
    // Lottie uses file-based caching
    if (_isLottie) {
      final lottieProvider = _provider as LottieMediaProvider;
      return FutureBuilder<File>(
        future: lottieProvider.fetchLottieFile(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorBuilder?.call(
                  context,
                  snapshot.error!,
                  snapshot.stackTrace,
                ) ??
                const Icon(Icons.error_outline, color: Colors.red);
          }

          if (!snapshot.hasData) {
            return placeholder ??
                SizedBox(
                  width: width,
                  height: height,
                  child: const Center(child: CircularProgressIndicator()),
                );
          }

          return lottieProvider.buildLottieWidget(
            lottieFile: snapshot.data!,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            extraParams: _extraParams,
          );
        },
      );
    }

    // Images and SVGs use Uint8List-based caching
    return FutureBuilder<Uint8List>(
      future: _provider.fetchMedia(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(
                context,
                snapshot.error!,
                snapshot.stackTrace,
              ) ??
              const Icon(Icons.error_outline, color: Colors.red);
        }

        if (!snapshot.hasData) {
          return placeholder ??
              SizedBox(
                width: width,
                height: height,
                child: const Center(child: CircularProgressIndicator()),
              );
        }

        return _provider.buildWidget(
          data: snapshot.data!,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          extraParams: _extraParams,
        );
      },
    );
  }
}
