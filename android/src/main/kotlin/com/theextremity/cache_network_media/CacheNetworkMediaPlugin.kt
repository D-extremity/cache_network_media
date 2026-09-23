package com.theextremity.cache_network_media

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class CacheNetworkMediaPlugin : FlutterPlugin, MethodCallHandler {

  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  companion object {
    private const val CHANNEL_NAME = "cache_network_media"
  }

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {

      "getTempCacheDir" -> {
        try{
          // externalCacheDir is null when shared storage is unavailable;
          // the internal cache directory always exists.
          val cacheDir = context.externalCacheDir ?: context.cacheDir
          result.success(cacheDir.absolutePath)
        } catch (e: Exception) {
          result.error("ERROR", "Failed to get external cache directory: ${e.message}", null)
        }
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
