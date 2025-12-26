import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../core/disk_cache_manager.dart';
import '../platform/cache_network_media_method_channel.dart';

abstract class BaseMediaProvider {
  final String url;
  final Directory? cacheDirectory;

  DiskCacheManager? _cacheManager;

  BaseMediaProvider({required this.url, this.cacheDirectory});

  Future<Uint8List> fetchMedia() async {
    _cacheManager ??= await _initCacheManager();
    Uint8List? cachedData = await _cacheManager?.getImage(url);
    if (cachedData != null) {
      debugPrint('Cache HIT for: $url');
      return cachedData;
    }

    debugPrint('Cache MISS for: $url - Downloading...');

    final data = await downloadFromNetwork();
    await _cacheManager?.putImage(url, data);

    return data;
  }

  Future<Uint8List> downloadFromNetwork() async {
    final uri = Uri.parse(url);
    final httpClient = HttpClient();

    try {
      final request = await httpClient.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: Failed to load $url');
      }

      return await consolidateHttpClientResponseBytes(response);
    } finally {
      httpClient.close();
    }
  }

  Widget buildWidget({
    required Uint8List data,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    Map<String, dynamic>? extraParams,
  });

  Future<DiskCacheManager> _initCacheManager() async {
    if (cacheDirectory != null && cacheDirectory!.path.isNotEmpty) {
      debugPrint('Using provided cache directory: ${cacheDirectory!.path}');
      return DiskCacheManager(cacheDirectory!);
    }

    final cacheDirPath = await MethodChannelCacheNetworkMedia()
        .getTempCacheDir();
    if (cacheDirPath == null || cacheDirPath.isEmpty) {
      throw Exception('Unable to get cache directory path.');
    }

    final directory = Directory('$cacheDirPath/cache_network_media');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return DiskCacheManager(directory);
  }

  Future<void> clearCache() async {
    _cacheManager ??= await _initCacheManager();
    final safeKey = url.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final file = File('${_cacheManager!.directory.path}/$safeKey.cache_image');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
