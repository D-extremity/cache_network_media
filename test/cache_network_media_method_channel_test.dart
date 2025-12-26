import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cache_network_media/cache_network_media_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelCacheNetworkMedia platform = MethodChannelCacheNetworkMedia();
  const MethodChannel channel = MethodChannel('cache_network_media');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
