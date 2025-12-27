import Flutter
import UIKit

public class CacheNetworkMediaPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "cache_network_media",
            binaryMessenger: registrar.messenger()
        )

        let instance = CacheNetworkMediaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getTempCacheDir":
            result(NSTemporaryDirectory())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
