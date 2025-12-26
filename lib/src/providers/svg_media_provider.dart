import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'base_media_provider.dart';

class SvgMediaProvider extends BaseMediaProvider {
  SvgMediaProvider({required super.url, super.cacheDirectory});

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
