import 'package:flutter_test/flutter_test.dart';
import 'package:cache_network_media/cache_network_media.dart';
import 'package:cache_network_media/cache_network_media_platform_interface.dart';
import 'package:cache_network_media/cache_network_media_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCacheNetworkMediaPlatform
    with MockPlatformInterfaceMixin
    implements CacheNetworkMediaPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CacheNetworkMediaPlatform initialPlatform =
      CacheNetworkMediaPlatform.instance;

  test('$MethodChannelCacheNetworkMedia is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCacheNetworkMedia>());
  });

  test('getPlatformVersion', () async {
    CacheNetworkMedia cacheNetworkMediaPlugin = CacheNetworkMedia();
    MockCacheNetworkMediaPlatform fakePlatform =
        MockCacheNetworkMediaPlatform();
    CacheNetworkMediaPlatform.instance = fakePlatform;

    expect(await cacheNetworkMediaPlugin.getPlatformVersion(), '42');
  });
}
