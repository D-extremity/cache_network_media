import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cache_network_media_platform_interface.dart';

/// An implementation of [CacheNetworkMediaPlatform] that uses method channels.
class MethodChannelCacheNetworkMedia extends CacheNetworkMediaPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cache_network_media');

  @override
  Future<String?> getTempCacheDir() async {
    final directoryPath = await methodChannel.invokeMethod('getTempCacheDir');
    return directoryPath;
  }
}
