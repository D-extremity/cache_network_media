import 'dart:io';
import 'dart:typed_data';

class DiskCacheManager {
  final Directory directory;

  DiskCacheManager(this.directory);

  File _getCacheFile(String key) {
    final safeName = key.hashCode.toString();
    return File('${directory.path}/$safeName.cache');
  }

  Future<Uint8List?> getImage(String key) async {
    final file = _getCacheFile(key);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  Future<void> putImage(String key, Uint8List bytes) async {
    final file = _getCacheFile(key);
    await file.writeAsBytes(bytes, flush: true);
  }
}
