import 'package:flutter/material.dart';
import 'package:vetro/core/models/file_item.dart';
import 'package:vetro/core/utils/format_utils.dart';
import 'package:vetro/core/constants/file_extensions.dart';

class FileListTile extends StatelessWidget {
  const FileListTile({
    super.key,
    required this.file,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onSecondaryTap,
  });

  final FileItem file;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSecondaryTap;

  IconData _getIcon() {
    if (file.isFolder) return Icons.folder;
    switch (file.type) {
      case FileType.image:
        return Icons.image;
      case FileType.video:
        return Icons.video_file;
      case FileType.audio:
        return Icons.audio_file;
      case FileType.document:
        return Icons.description;
      case FileType.archive:
        return Icons.zip;
      case FileType.executable:
        return Icons.apps;
      case FileType.text:
        return Icons.text_snippet;
      case FileType.code:
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getIconColor() {
    switch (file.type) {
      case FileType.folder:
        return const Color(0xFF6750A4);
      case FileType.image:
        return const Color(0xFF4CAF50);
      case FileType.video:
        return const Color(0xFFF44336);
      case FileType.audio:
        return const Color(0xFF9C27B0);
      case FileType.document:
        return const Color(0xFF2196F3);
      case FileType.archive:
        return const Color(0xFFFF9800);
      case FileType.executable:
        return const Color(0xFF607D8B);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      child: Container(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        child: ListTile(
          leading: Stack(
            children: [
              Icon(_getIcon(), color: _getIconColor(), size: 28),
              if (isSelected)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 12,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: file.isFolder
              ? null
              : Text(
                  FormatUtils.formatFileSize(file.size),
                  style: theme.textTheme.bodySmall,
                ),
          trailing: file.isFolder
              ? const Icon(Icons.chevron_right)
              : Text(
                  file.modifiedAt.month.toString().padLeft(2, '0') +
                      '/' +
                      file.modifiedAt.day.toString().padLeft(2, '0'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}
