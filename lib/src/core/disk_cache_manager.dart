import 'dart:io';
import 'dart:typed_data';

/// Stores downloaded media as files in [directory].
///
/// Entries older than [maxAge] count as expired, and the least recently used
/// entries are deleted once the cache grows beyond [maxSizeBytes].
class DiskCacheManager {
  final Directory directory;

  DiskCacheManager(this.directory);

  /// How long a downloaded entry stays fresh. `null` means it never expires.
  static Duration? maxAge;

  /// Upper bound for the total size of cached files, in bytes. `null` means
  /// no limit.
  static int? maxSizeBytes;

  static const _extension = '.cache';
  static final _temporaryFile = RegExp(r'\.cache\.\d+\.tmp$');
  static int _tmpCounter = 0;
  static final Set<String> _trimming = <String>{};

  /// The file that holds the entry for [key], whether or not it exists yet.
  File fileFor(String key) {
    final safeName = key.hashCode.toString();
    return File('${directory.path}/$safeName$_extension');
  }

  /// Returns the cached bytes for [key], or `null` if there is no entry.
  ///
  /// Expired entries are ignored unless [allowStale] is true.
  Future<Uint8List?> getImage(String key, {bool allowStale = false}) async {
    final file = fileFor(key);
    final stat = await file.stat();
    if (stat.type == FileSystemEntityType.notFound) {
      return null;
    }
    if (!allowStale && _isExpired(stat)) {
      return null;
    }

    final bytes = await file.readAsBytes();
    try {
      // The last access time drives least-recently-used eviction.
      await file.setLastAccessed(DateTime.now());
    } on FileSystemException {
      // Not supported on every file system; eviction then uses the last
      // access time the OS recorded.
    }
    return bytes;
  }

  Future<void> putImage(String key, Uint8List bytes) async {
    final file = fileFor(key);
    // Write to a temporary file first so an interrupted write never leaves a
    // truncated entry behind.
    final tmp = File('${file.path}.${_tmpCounter++}.tmp');
    await tmp.parent.create(recursive: true);
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(file.path);
    _scheduleTrim();
  }

  Future<void> remove(String key) async {
    final file = fileFor(key);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Deletes every cache entry in [directory]. Other files are left alone.
  Future<void> clear() async {
    if (!await directory.exists()) {
      return;
    }
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File &&
          (entity.path.endsWith(_extension) ||
              _temporaryFile.hasMatch(entity.path))) {
        await _deleteQuietly(entity);
      }
    }
  }

  /// Deletes the least recently used entries until the cache fits in
  /// [maxSizeBytes].
  Future<void> trim() async {
    final limit = maxSizeBytes;
    if (limit == null || !await directory.exists()) {
      return;
    }

    final entries = <(File, FileStat)>[];
    var total = 0;
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File && entity.path.endsWith(_extension)) {
        final stat = await entity.stat();
        entries.add((entity, stat));
        total += stat.size;
      }
    }
    if (total <= limit) {
      return;
    }

    entries.sort((a, b) => a.$2.accessed.compareTo(b.$2.accessed));
    for (final (file, stat) in entries) {
      if (total <= limit) {
        break;
      }
      if (await _deleteQuietly(file)) {
        total -= stat.size;
      }
    }
  }

  void _scheduleTrim() {
    if (maxSizeBytes == null || !_trimming.add(directory.path)) {
      return;
    }
    trim().whenComplete(() => _trimming.remove(directory.path)).ignore();
  }

  static bool _isExpired(FileStat stat) {
    final age = maxAge;
    return age != null && DateTime.now().difference(stat.modified) > age;
  }

  static Future<bool> _deleteQuietly(File file) async {
    try {
      await file.delete();
      return true;
    } on FileSystemException {
      // Already gone, or in use by a concurrent read.
      return false;
    }
  }
}
