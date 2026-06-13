import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class PathUtils {
  PathUtils._();

  static String getFileName(String path) => p.basename(path);

  static String getFileNameWithoutExtension(String path) =>
      p.basenameWithoutExtension(path);

  static String getExtension(String path) {
    final ext = p.extension(path);
    return ext.startsWith('.') ? ext.substring(1) : ext;
  }

  static String getParentPath(String path) => p.dirname(path);

  static String join(String part1, [String? part2, String? part3]) =>
      p.join(part1, part2, part3);

  static String normalize(String path) => p.normalize(path);

  static bool isWithin(String parent, String child) => p.isWithin(parent, child);

  static String relative(String path, {String? from}) =>
      p.relative(path, from: from);

  /// Format a path for display, abbreviating home directory
  static String displayPath(String path, String? homePath) {
    if (homePath == null || homePath.isEmpty) return path;

    final normalized = normalize(path);
    final normalizedHome = normalize(homePath);

    if (normalized == normalizedHome) return '~';
    if (normalized.startsWith(normalizedHome + Platform.pathSeparator)) {
      return '~/${relative(normalized, from: normalizedHome)}';
    }

    return normalized;
  }

  /// Check if a path looks like a root directory
  static bool isRoot(String path) {
    final normalized = normalize(path);
    if (Platform.isWindows) {
      // Check for drive roots like "C:\"
      return RegExp(r'^[A-Za-z]:\\?$').hasMatch(normalized);
    }
    return normalized == '/';
  }

  /// Get common path prefix between two paths
  static String commonPrefix(String path1, String path2) {
    final parts1 = p.split(path1);
    final parts2 = p.split(path2);

    final common = <String>[];
    for (var i = 0; i < parts1.length && i < parts2.length; i++) {
      if (parts1[i] == parts2[i]) {
        common.add(parts1[i]);
      } else {
        break;
      }
    }

    if (common.isEmpty) {
      return Platform.isWindows ? 'C:\\' : '/';
    }

    return p.joinAll(common);
  }

  /// Sanitize a file/folder name
  static String sanitizeName(String name) {
    if (Platform.isWindows) {
      // Windows invalid characters
      return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    }
    // Unix: only null is truly invalid, but replace / for safety
    return name.replaceAll('/', '_');
  }

  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
