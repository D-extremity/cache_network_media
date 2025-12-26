import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cache_network_media/cache_network_media_method_channel.dart';
import 'package:cache_network_media/disk_cache_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class CacheNetworkImage extends ImageProvider<CacheNetworkImage> {
  final String url;
  final double scale;
  final Directory? cacheDirectory;
  CacheNetworkImage({
    required this.url,
    required this.cacheDirectory,
    this.scale = 1.0,
  });

  DiskCacheManager? _diskCacheManager;

  @override
  Future<CacheNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter loadImage(
    CacheNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(codec: _loadAsync(), scale: scale);
  }

  Future<Codec> _loadAsync() async {
    _diskCacheManager ??= await getDiskCacheManager();
    Uint8List? bytes = await _diskCacheManager?.getImage(url);

    if (bytes == null) {
      final Uri uri = Uri.parse(url);
      final HttpClient httpClient = HttpClient();
      final HttpClientRequest request = await httpClient.getUrl(uri);
      final HttpClientResponse response = await request.close();
      if (response.statusCode != 200) {
        throw Exception(
          'Unable to fetch image, statusCode: ${response.statusCode}, $uri',
        );
      }
      bytes = await consolidateHttpClientResponseBytes(response);
      await _diskCacheManager?.putImage(url, bytes);
    }
    return await instantiateImageCodec(bytes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheNetworkImage && other.url == url && other.scale == scale;

  @override
  int get hashCode => Object.hash(url, scale);

  void deleteAllData() {
    cacheDirectory?.delete(recursive: true);
  }

  Future<DiskCacheManager> getDiskCacheManager() async {
    try {
      if (cacheDirectory != null && cacheDirectory!.path.isNotEmpty) {
        _diskCacheManager = DiskCacheManager(cacheDirectory!);
        log('Using provided cache directory: ${cacheDirectory!.path}');
        return _diskCacheManager!;
      } else {
        final cacheDirPath = await _getCacheDirectoryPath();
        final directory = Directory(cacheDirPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        _diskCacheManager = DiskCacheManager(directory);
        return _diskCacheManager!;
      }
    } catch (e, stackTrace) {
      throw Exception(
        'Error setting DiskCacheManager: ${e.toString()} \n$stackTrace',
      );
    }
  }
}

Future<String> _getCacheDirectoryPath() async {
  String? tempDirPath = await MethodChannelCacheNetworkMedia()
      .getTempCacheDir();
  if (tempDirPath == null || tempDirPath.isEmpty) {
    throw Exception('Unable to get temporary cache directory path.');
  }
  return '$tempDirPath/cache_network_media';
}
