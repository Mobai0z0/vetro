import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:vetro/core/models/file_item.dart';

class FileOperations {
  FileOperations._();

  static List<FileItem> sortByType(List<FileItem> files, {bool ascending = true}) {
    final sorted = List<FileItem>.from(files);
    sorted.sort((a, b) {
      int cmp;
      if (a.isFolder && !b.isFolder) {
        cmp = -1;
      } else if (!a.isFolder && b.isFolder) {
        cmp = 1;
      } else {
        cmp = a.type.index.compareTo(b.type.index);
      }
      return ascending ? cmp : -cmp;
    });
    return sorted;
  }

  static bool isImage(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp', 'ico']
        .contains(ext);
  }

  static bool isVideo(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp4', 'mkv', 'avi', 'mov', 'webm', 'flv', 'wmv'].contains(ext);
  }

  static bool isAudio(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp3', 'wav', 'flac', 'ogg', 'aac', 'm4a', 'wma'].contains(ext);
  }

  static bool isPdf(String path) {
    return path.toLowerCase().endsWith('.pdf');
  }

  static bool isMarkdown(String path) {
    return path.toLowerCase().endsWith('.md');
  }

  static bool isText(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['txt', 'log', 'ini', 'conf', 'cfg', 'json', 'xml', 'yaml', 'yml']
        .contains(ext);
  }

  static bool isArchive(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'tgz']
        .contains(ext);
  }

  static bool canPreview(String path) {
    return isImage(path) ||
        isVideo(path) ||
        isAudio(path) ||
        isPdf(path) ||
        isMarkdown(path) ||
        isText(path) ||
        isArchive(path);
  }

  static Future<int> getDirectorySize(Directory dir) async {
    int totalSize = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          try {
            totalSize += await entity.length();
          } catch (_) {}
        }
      }
    } catch (_) {}
    return totalSize;
  }

  static Future<int> countFiles(Directory dir) async {
    int count = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) count++;
      }
    } catch (_) {}
    return count;
  }

  static String getFileIcon(String path) {
    final ext = path.split('.').last.toLowerCase();

    if (isImage(path)) return 'image';
    if (isVideo(path)) return 'video';
    if (isAudio(path)) return 'audio';
    if (isPdf(path)) return 'pdf';
    if (isMarkdown(path)) return 'markdown';
    if (isArchive(path)) return 'archive';

    switch (ext) {
      case 'doc':
      case 'docx':
        return 'word';
      case 'xls':
      case 'xlsx':
        return 'excel';
      case 'ppt':
      case 'pptx':
        return 'powerpoint';
      case 'json':
      case 'xml':
      case 'yaml':
      case 'yml':
        return 'code';
      case 'exe':
      case 'msi':
      case 'app':
      case 'dmg':
      case 'deb':
      case 'rpm':
      case 'appimage':
        return 'executable';
      default:
        return 'file';
    }
  }
}
