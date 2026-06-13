import 'package:flutter/material.dart';
import 'package:vetro/core/models/file_item.dart';
import 'package:vetro/core/utils/format_utils.dart';
import 'package:vetro/core/constants/file_extensions.dart';

class FileGridTile extends StatelessWidget {
  const FileGridTile({
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(), color: _getIconColor(), size: 40),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
            if (!file.isFolder) ...[
              const SizedBox(height: 2),
              Text(
                FormatUtils.formatFileSize(file.size),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
