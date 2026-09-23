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
            // Library/Caches survives app restarts and is not backed up.
            // The OS only purges it under storage pressure while the app is
            // not running, unlike tmp/, which can be cleared at any time.
            let caches = FileManager.default.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            ).first
            result(caches?.path ?? NSTemporaryDirectory())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
