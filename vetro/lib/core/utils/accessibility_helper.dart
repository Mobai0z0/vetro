import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityHelper {
  AccessibilityHelper._();

  static SemanticsProperties get fileTile => const SemanticsProperties(
        button: false,
        focusable: true,
        label: 'File',
      );

  static SemanticsProperties get folderTile => const SemanticsProperties(
        button: true,
        focusable: true,
        label: 'Folder',
      );

  static Semantics handleFileTileAccessibility({
    required String name,
    required bool isFolder,
    required String size,
    required String modifiedDate,
  }) {
    return Semantics(
      label: isFolder ? 'Folder' : 'File',
      value: '$name, $size, modified $modifiedDate',
      button: isFolder,
      child: const SizedBox.shrink(),
    );
  }

  static String formatAccessibilityLabel({
    required String name,
    required bool isFolder,
    required int size,
    required DateTime modifiedAt,
    String? extension,
  }) {
    final buffer = StringBuffer();
    buffer.write(isFolder ? 'Folder: ' : 'File: ');
    buffer.write(name);

    if (!isFolder) {
      buffer.write(', ${_formatSize(size)}');
      if (extension != null && extension.isNotEmpty) {
        buffer.write(', ${extension.toUpperCase()}');
      }
    }

    buffer.write(', modified ${_formatDate(modifiedAt)}');
    return buffer.toString();
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes bytes';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).round()} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).round()} GB';
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  static void announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static void triggerHapticFeedback() {
    HapticFeedback.mediumImpact();
  }

  static void triggerSelectionFeedback() {
    HapticFeedback.selectionClick();
  }
}
