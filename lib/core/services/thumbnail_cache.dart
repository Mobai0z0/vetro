import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThumbnailCache {
  static ThumbnailCache? _instance;
  static ThumbnailCache get instance => _instance ??= ThumbnailCache._();
  ThumbnailCache._();

  Directory? _cacheDir;
  final Map<String, Uint8List> _memoryCache = {};

  Future<void> init() async {
    final temp = await getTemporaryDirectory();
    _cacheDir = Directory(p.join(temp.path, 'vetro_thumbnails'));
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
  }

  String _cacheKey(String filePath, int width, int height) {
    return '${filePath}_${width}x$height'.replaceAll(RegExp(r'[/\\: ]'), '_');
  }

  Future<Uint8List?> get(String filePath, {int width = 200, int height = 200}) async {
    final key = _cacheKey(filePath, width, height);

    // Memory cache
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }

    // Disk cache
    if (_cacheDir != null) {
      final cacheFile = File(p.join(_cacheDir!.path, '$key.thumb'));
      if (await cacheFile.exists()) {
        try {
          final bytes = await cacheFile.readAsBytes();
          _memoryCache[key] = bytes;
          return bytes;
        } catch (_) {
          await cacheFile.delete();
        }
      }
    }

    return null;
  }

  Future<void> put(String filePath, Uint8List bytes, {int width = 200, int height = 200}) async {
    final key = _cacheKey(filePath, width, height);

    _memoryCache[key] = bytes;

    // Limit memory cache
    if (_memoryCache.length > 200) {
      final keysToRemove = _memoryCache.keys.take(50).toList();
      for (final k in keysToRemove) {
        _memoryCache.remove(k);
      }
    }

    // Disk cache
    if (_cacheDir != null) {
      try {
        final cacheFile = File(p.join(_cacheDir!.path, '$key.thumb'));
        await cacheFile.writeAsBytes(bytes);
      } catch (_) {}
    }
  }

  Future<bool> has(String filePath, {int width = 200, int height = 200}) async {
    final key = _cacheKey(filePath, width, height);
    if (_memoryCache.containsKey(key)) return true;

    if (_cacheDir != null) {
      final cacheFile = File(p.join(_cacheDir!.path, '$key.thumb'));
      return cacheFile.exists();
    }

    return false;
  }

  Future<void> clear() async {
    _memoryCache.clear();
    if (_cacheDir != null && await _cacheDir!.exists()) {
      await _cacheDir!.delete(recursive: true);
      await _cacheDir!.create(recursive: true);
    }
  }

  Future<int> getSize() async {
    int size = _memoryCache.values.fold(0, (sum, bytes) => sum + bytes.length);

    if (_cacheDir != null && await _cacheDir!.exists()) {
      await for (final entity in _cacheDir!.list()) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    }

    return size;
  }

  /// Generate thumbnail for an image file using Flutter's built-in decoding
  static Future<Uint8List?> generateImageThumbnail(String filePath, {
    int maxWidth = 200,
    int maxHeight = 200,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      return bytes; // Return original for now; could resize with image package
    } catch (e) {
      debugPrint('Thumbnail generation failed: $e');
      return null;
    }
  }
}
