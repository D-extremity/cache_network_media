import 'dart:io';

import '../platform/cache_network_media_platform_interface.dart';

Future<Directory>? _defaultDirectory;

/// Resolves the directory used for the disk cache.
///
/// Uses [custom] when provided, otherwise a `cache_network_media` folder in
/// the platform's cache directory. The directory is created if it
/// does not exist yet.
Future<Directory> resolveCacheDirectory(Directory? custom) async {
  if (custom != null && custom.path.isNotEmpty) {
    if (!await custom.exists()) {
      await custom.create(recursive: true);
    }
    return custom;
  }

  final future = _defaultDirectory ??= _createDefaultDirectory();
  try {
    return await future;
  } catch (_) {
    // Allow a later call to try again.
    _defaultDirectory = null;
    rethrow;
  }
}

Future<Directory> _createDefaultDirectory() async {
  final cacheDirPath = await CacheNetworkMediaPlatform.instance
      .getTempCacheDir();
  if (cacheDirPath == null || cacheDirPath.isEmpty) {
    throw Exception('Unable to get cache directory path.');
  }

  final directory = Directory('$cacheDirPath/cache_network_media');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  return directory;
}
