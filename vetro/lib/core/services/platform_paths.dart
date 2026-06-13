import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PlatformPaths {
  PlatformPaths._();

  static Future<String> getHomeDirectory() async {
    if (kIsWeb) return '/';

    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }

    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';
    if (home.isNotEmpty) return home;

    // Fallback
    final temp = await getTemporaryDirectory();
    return p.dirname(temp.path);
  }

  static Future<List<Directory>> getSystemDirectories() async {
    final dirs = <Directory>[];

    if (kIsWeb) return dirs;

    if (Platform.isAndroid || Platform.isIOS) {
      final appDoc = await getApplicationDocumentsDirectory();
      dirs.add(appDoc);

      try {
        final appSupport = await getApplicationSupportDirectory();
        dirs.add(appSupport);
      } catch (_) {}

      if (Platform.isAndroid) {
        try {
          final ext = await getExternalStorageDirectory();
          if (ext != null) dirs.add(ext);
        } catch (_) {}
      }

      return dirs;
    }

    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';
    if (home.isEmpty) return dirs;

    if (Platform.isWindows) {
      dirs.addAll([
        Directory(p.join(home, 'Desktop')),
        Directory(p.join(home, 'Documents')),
        Directory(p.join(home, 'Downloads')),
        Directory(p.join(home, 'Pictures')),
        Directory(p.join(home, 'Music')),
        Directory(p.join(home, 'Videos')),
        Directory(p.join(home, 'OneDrive', 'Desktop')),
        Directory(p.join(home, 'OneDrive', 'Documents')),
        Directory(p.join(home, 'OneDrive', 'Downloads')),
      ]);
    } else if (Platform.isMacOS) {
      dirs.addAll([
        Directory(p.join(home, 'Desktop')),
        Directory(p.join(home, 'Documents')),
        Directory(p.join(home, 'Downloads')),
        Directory(p.join(home, 'Pictures')),
        Directory(p.join(home, 'Music')),
        Directory(p.join(home, 'Movies')),
        Directory('/System/Library'), // Read-only system
      ]);
    } else if (Platform.isLinux) {
      dirs.addAll([
        Directory(p.join(home, 'Desktop')),
        Directory(p.join(home, 'Documents')),
        Directory(p.join(home, 'Downloads')),
        Directory(p.join(home, 'Pictures')),
        Directory(p.join(home, 'Music')),
        Directory(p.join(home, 'Videos')),
        // XDG directories
        Directory(p.join(home, '.local', 'share')),
      ]);
    }

    return dirs.where((d) => d.existsSync()).toList();
  }

  static Future<String> getCacheDirectory() async {
    if (kIsWeb) return '';

    final temp = await getTemporaryDirectory();
    final cacheDir = Directory(p.join(temp.path, 'vetro_cache'));

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir.path;
  }

  static Future<int> getCacheSize() async {
    final cachePath = await getCacheDirectory();
    if (cachePath.isEmpty) return 0;

    final cacheDir = Directory(cachePath);
    if (!await cacheDir.exists()) return 0;

    int totalSize = 0;
    await for (final entity in cacheDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  static Future<void> clearCache() async {
    final cachePath = await getCacheDirectory();
    if (cachePath.isEmpty) return;

    final cacheDir = Directory(cachePath);
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create(recursive: true);
    }
  }

  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static String get pathSeparator => Platform.pathSeparator;
}
