import '../models/file_item.dart';

class FileExtensions {
  FileExtensions._();

  static const Map<String, FileType> extensionMap = {
    // Images
    'jpg': FileType.image,
    'jpeg': FileType.image,
    'png': FileType.image,
    'gif': FileType.image,
    'webp': FileType.image,
    'svg': FileType.image,
    'bmp': FileType.image,
    'ico': FileType.image,
    'tiff': FileType.image,
    'tif': FileType.image,
    'heic': FileType.image,
    'heif': FileType.image,

    // Videos
    'mp4': FileType.video,
    'mkv': FileType.video,
    'avi': FileType.video,
    'mov': FileType.video,
    'webm': FileType.video,
    'flv': FileType.video,
    'wmv': FileType.video,
    'm4v': FileType.video,
    '3gp': FileType.video,

    // Audio
    'mp3': FileType.audio,
    'wav': FileType.audio,
    'flac': FileType.audio,
    'ogg': FileType.audio,
    'aac': FileType.audio,
    'm4a': FileType.audio,
    'wma': FileType.audio,
    'opus': FileType.audio,

    // Documents
    'pdf': FileType.document,
    'doc': FileType.document,
    'docx': FileType.document,
    'xls': FileType.document,
    'xlsx': FileType.document,
    'ppt': FileType.document,
    'pptx': FileType.document,
    'odt': FileType.document,
    'ods': FileType.document,
    'odp': FileType.document,
    'csv': FileType.document,
    'rtf': FileType.document,

    // Archives
    'zip': FileType.archive,
    'rar': FileType.archive,
    '7z': FileType.archive,
    'tar': FileType.archive,
    'gz': FileType.archive,
    'bz2': FileType.archive,
    'xz': FileType.archive,
    'tgz': FileType.archive,

    // Executables
    'exe': FileType.executable,
    'msi': FileType.executable,
    'app': FileType.executable,
    'dmg': FileType.executable,
    'deb': FileType.executable,
    'rpm': FileType.executable,
    'appimage': FileType.executable,
    'apk': FileType.executable,
    'ipa': FileType.executable,

    // Text / Code
    'txt': FileType.text,
    'md': FileType.text,
    'json': FileType.code,
    'xml': FileType.code,
    'yaml': FileType.code,
    'yml': FileType.code,
    'toml': FileType.code,
    'ini': FileType.code,
    'conf': FileType.code,
    'cfg': FileType.code,
    'log': FileType.text,
    'csv': FileType.text,
    'html': FileType.code,
    'htm': FileType.code,
    'css': FileType.code,
    'js': FileType.code,
    'ts': FileType.code,
    'dart': FileType.code,
    'py': FileType.code,
    'java': FileType.code,
    'c': FileType.code,
    'cpp': FileType.code,
    'h': FileType.code,
    'rs': FileType.code,
    'go': FileType.code,
    'rb': FileType.code,
    'php': FileType.code,
    'swift': FileType.code,
    'kt': FileType.code,
    'sh': FileType.code,
    'bat': FileType.code,
    'ps1': FileType.code,
    'sql': FileType.code,
    'r': FileType.code,
    'lua': FileType.code,
    'pl': FileType.code,
    'vue': FileType.code,
    'jsx': FileType.code,
    'tsx': FileType.code,
    'scss': FileType.code,
    'less': FileType.code,
    'sass': FileType.code,
  };

  static FileType getTypeFromExtension(String extension) {
    return extensionMap[extension.toLowerCase()] ?? FileType.other;
  }
}
