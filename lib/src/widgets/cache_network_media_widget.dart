import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../providers/base_media_provider.dart';
import '../providers/image_media_provider.dart';
import '../providers/svg_media_provider.dart';
import '../providers/lottie_media_provider.dart';

class CacheNetworkMediaWidget extends StatelessWidget {
  final String url;
  final BaseMediaProvider _provider;
  final bool _isLottie;

  // Common properties
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final Widget? placeholder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  // Type-specific properties stored as Map
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

  /// Create a cached Lottie animation widget
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
