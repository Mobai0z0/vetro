import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/file_item.dart';
import '../constants/file_extensions.dart';

class ScannerService {
  Future<List<String>> getSystemDirectories() async {
    final dirs = <String>[];

    if (Platform.isAndroid || Platform.isIOS) {
      final appDir = await getApplicationDocumentsDirectory();
      dirs.add(appDir.path);
    } else {
      final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
      if (home.isNotEmpty) {
        dirs.addAll([
          p.join(home, 'Desktop'),
          p.join(home, 'Documents'),
          p.join(home, 'Downloads'),
          p.join(home, 'Pictures'),
          p.join(home, 'Music'),
          p.join(home, 'Videos'),
        ]);
      }
    }

    return dirs.where((d) => Directory(d).existsSync()).toList();
  }

  Future<Map<String, List<FileItem>>> scanByCategory(List<String> directories) async {
    final Map<String, List<FileItem>> results = {
      'image': [],
      'video': [],
      'audio': [],
      'document': [],
      'archive': [],
      'executable': [],
    };

    for (final dirPath in directories) {
      await _scanDirectory(Directory(dirPath), results, depth: 0);
    }

    for (final list in results.values) {
      list.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    }

    return results;
  }

  Future<void> _scanDirectory(
    Directory dir,
    Map<String, List<FileItem>> results, {
    required int depth,
  }) async {
    if (depth > 3) return;

    try {
      await for (final entity in dir.list(followLinks: false)) {
        try {
          if (entity is Directory) {
            await _scanDirectory(entity, results, depth: depth + 1);
          } else if (entity is File) {
            final name = p.basename(entity.path);
            if (name.startsWith('.')) continue;

            final ext = p.extension(name).substring(1).toLowerCase();
            final type = FileExtensions.getTypeFromExtension(ext);

            final categoryKey = _typeToCategoryKey(type);
            if (categoryKey != null && results[categoryKey] != null) {
              final stat = await entity.stat();
              results[categoryKey]!.add(FileItem(
                name: name,
                path: entity.path,
                parentPath: p.dirname(entity.path),
                type: type,
                size: stat.size,
                modifiedAt: stat.modified,
                createdAt: stat.changed,
                extension: ext,
              ));
            }
          }
        } catch (_) {
          continue;
        }
      }
    } catch (_) {}
  }

  String? _typeToCategoryKey(FileType type) {
    switch (type) {
      case FileType.image:
        return 'image';
      case FileType.video:
        return 'video';
      case FileType.audio:
        return 'audio';
      case FileType.document:
        return 'document';
      case FileType.archive:
        return 'archive';
      case FileType.executable:
        return 'executable';
      default:
        return null;
    }
  }
}
