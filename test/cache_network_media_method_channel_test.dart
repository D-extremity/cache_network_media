import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cache_network_media/src/platform/cache_network_media_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelCacheNetworkMedia platform = MethodChannelCacheNetworkMedia();
  const MethodChannel channel = MethodChannel('cache_network_media');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getTempCacheDir') {
            return '/tmp/cache';
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getTempCacheDir returns valid path', () async {
    final result = await platform.getTempCacheDir();
    expect(result, '/tmp/cache');
    expect(result, isNotNull);
  });

  test('getTempCacheDir returns string type', () async {
    final result = await platform.getTempCacheDir();
    expect(result, isA<String>());
  });

  test('method channel is configured correctly', () {
    expect(platform.methodChannel.name, 'cache_network_media');
  });
}
