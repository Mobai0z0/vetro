import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/file_item.dart';
import '../models/sort_type.dart';
import '../constants/file_extensions.dart';

class FileService {
  Future<List<FileItem>> listDirectory(String path, {bool showHidden = false}) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final List<FileItem> items = [];

    await for (final entity in dir.list(followLinks: false)) {
      try {
        final stat = await entity.stat();
        final name = p.basename(entity.path);
        final isHidden = name.startsWith('.');

        if (!showHidden && isHidden) continue;

        final ext = entity is File ? p.extension(name).substring(1) : '';
        final type = entity is Directory
            ? FileType.folder
            : FileExtensions.getTypeFromExtension(ext);

        items.add(FileItem(
          name: name,
          path: entity.path,
          parentPath: path,
          type: type,
          size: stat.size,
          modifiedAt: stat.modified,
          createdAt: stat.changed,
          extension: ext,
          isHidden: isHidden,
        ));
      } catch (_) {
        continue;
      }
    }

    return items;
  }

  Future<FileItem?> getFileInfo(String path) async {
    final entity = FileSystemEntity.typeSync(path);
    if (entity == FileSystemEntityType.notFound) return null;

    final stat = await FileStat.stat(path);
    final name = p.basename(path);
    final isDir = entity == FileSystemEntityType.directory;
    final ext = isDir ? '' : p.extension(name).substring(1);
    final type = isDir
        ? FileType.folder
        : FileExtensions.getTypeFromExtension(ext);

    return FileItem(
      name: name,
      path: path,
      parentPath: p.dirname(path),
      type: type,
      size: stat.size,
      modifiedAt: stat.modified,
      createdAt: stat.changed,
      extension: ext,
      isHidden: name.startsWith('.'),
    );
  }

  Future<void> createDirectory(String parentPath, String name) async {
    final dir = Directory(p.join(parentPath, name));
    await dir.create(recursive: true);
  }

  Future<void> rename(String path, String newName) async {
    final entity = FileSystemEntity.typeSync(path) == FileSystemEntityType.directory
        ? Directory(path)
        : File(path);
    final newPath = p.join(p.dirname(path), newName);
    await entity.rename(newPath);
  }

  Future<void> delete(String path, {bool recursive = false}) async {
    final entity = FileSystemEntity.typeSync(path) == FileSystemEntityType.directory
        ? Directory(path)
        : File(path);
    await entity.delete(recursive: recursive);
  }

  Future<void> copy(String sourcePath, String destPath) async {
    final stat = await FileStat.stat(sourcePath);
    if (stat.type == FileSystemEntityType.directory) {
      await Directory(sourcePath).copy(destPath);
    } else {
      await File(sourcePath).copy(destPath);
    }
  }

  Future<void> move(String sourcePath, String destPath) async {
    final entity = FileSystemEntity.typeSync(sourcePath) == FileSystemEntityType.directory
        ? Directory(sourcePath)
        : File(sourcePath);
    await entity.rename(destPath);
  }

  int compareFiles(FileItem a, FileItem b, SortType sort, bool ascending) {
    int cmp;
    switch (sort) {
      case SortType.name:
        cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case SortType.size:
        cmp = a.size.compareTo(b.size);
      case SortType.date:
        cmp = a.modifiedAt.compareTo(b.modifiedAt);
      case SortType.type:
        cmp = a.type.index.compareTo(b.type.index);
    }
    return ascending ? cmp : -cmp;
  }
}
