import 'package:flutter/foundation.dart';

enum FileType {
  folder,
  image,
  video,
  audio,
  document,
  archive,
  executable,
  text,
  code,
  other,
}

@immutable
class FileItem {
  const FileItem({
    required this.name,
    required this.path,
    required this.parentPath,
    required this.type,
    required this.size,
    required this.modifiedAt,
    required this.createdAt,
    this.extension = '',
    this.isHidden = false,
    this.mimeType,
  });

  final String name;
  final String path;
  final String parentPath;
  final FileType type;
  final int size;
  final DateTime modifiedAt;
  final DateTime createdAt;
  final String extension;
  final bool isHidden;
  final String? mimeType;

  bool get isFolder => type == FileType.folder;

  String get displayName {
    if (isFolder) return name;
    if (extension.isNotEmpty) {
      return name.substring(0, name.length - extension.length - 1);
    }
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileItem &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
