import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cache_network_media/src/core/disk_cache_manager.dart';
import 'package:cache_network_media/src/platform/cache_network_media_method_channel.dart';

class CacheNetworkSvg extends StatefulWidget {
  final String url;

  // Layout
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;

  // SVG behavior
  final bool matchTextDirection;
  final bool allowDrawingOutsideViewBox;
  final ColorFilter? colorFilter;
  final SvgTheme? theme;

  // Accessibility
  final String? semanticsLabel;
  final bool excludeFromSemantics;

  // Cache
  final Directory? cacheDirectory;

  // UI States
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const CacheNetworkSvg({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.hardEdge,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.colorFilter,
    this.theme,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.cacheDirectory,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<CacheNetworkSvg> createState() => _CacheNetworkSvgState();
}

class _CacheNetworkSvgState extends State<CacheNetworkSvg> {
  DiskCacheManager? _diskCacheManager;
  Uint8List? _svgBytes;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    try {
      _diskCacheManager ??= await _getDiskCacheManager();

      Uint8List? bytes = await _diskCacheManager!.getImage(widget.url);

      if (bytes == null) {
        final uri = Uri.parse(widget.url);
        final httpClient = HttpClient();
        final request = await httpClient.getUrl(uri);
        final response = await request.close();

        if (response.statusCode != 200) {
          throw Exception(
            'Unable to fetch SVG, statusCode: ${response.statusCode}, $uri',
          );
        }

        bytes = await consolidateHttpClientResponseBytes(response);
        await _diskCacheManager?.putImage(widget.url, bytes);
      }

      if (mounted) {
        setState(() => _svgBytes = bytes);
      }
    } catch (e, stack) {
      log('CacheNetworkSvg error: $e\n$stack');
      if (mounted) setState(() => _hasError = true);
    }
  }

  Future<DiskCacheManager> _getDiskCacheManager() async {
    if (widget.cacheDirectory != null &&
        widget.cacheDirectory!.path.isNotEmpty) {
      return DiskCacheManager(widget.cacheDirectory!);
    }

    final cacheDirPath =
        await MethodChannelCacheNetworkMedia().getTempCacheDir();
    final directory = Directory('$cacheDirPath/cache_network_media');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return DiskCacheManager(directory);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.sentiment_dissatisfied, size: 32),
              SizedBox(height: 6),
              Text('Failed to load image'),
            ],
          );
    }

    if (_svgBytes == null) {
      return widget.loadingWidget ??
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 1),
            ),
          );
    }

    return SvgPicture.memory(
      _svgBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      allowDrawingOutsideViewBox: widget.allowDrawingOutsideViewBox,
      matchTextDirection: widget.matchTextDirection,
      colorFilter: widget.colorFilter,
      theme: widget.theme,
      semanticsLabel: widget.semanticsLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      clipBehavior: widget.clipBehavior,
    );
  }
}
