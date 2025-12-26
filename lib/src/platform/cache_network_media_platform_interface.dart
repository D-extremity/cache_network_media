import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cache_network_media_method_channel.dart';

abstract class CacheNetworkMediaPlatform extends PlatformInterface {
  /// Constructs a CacheNetworkMediaPlatform.
  CacheNetworkMediaPlatform() : super(token: _token);

  static final Object _token = Object();

  static CacheNetworkMediaPlatform _instance = MethodChannelCacheNetworkMedia();

  /// The default instance of [CacheNetworkMediaPlatform] to use.
  ///
  /// Defaults to [MethodChannelCacheNetworkMedia].
  static CacheNetworkMediaPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CacheNetworkMediaPlatform] when
  /// they register themselves.
  static set instance(CacheNetworkMediaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getTempCacheDir() {
    throw UnimplementedError('getTempCacheDir() has not been implemented.');
  }
}
