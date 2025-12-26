import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'base_media_provider.dart';

class ImageMediaProvider extends BaseMediaProvider {
  ImageMediaProvider({required super.url, super.cacheDirectory});

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
