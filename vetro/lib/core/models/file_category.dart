import 'package:flutter/material.dart';

enum FileCategory {
  image(
    labelKey: 'category_images',
    icon: Icons.photo_library_outlined,
    activeIcon: Icons.photo_library,
    color: Color(0xFF4CAF50),
  ),
  video(
    labelKey: 'category_videos',
    icon: Icons.video_library_outlined,
    activeIcon: Icons.video_library,
    color: Color(0xFFF44336),
  ),
  audio(
    labelKey: 'category_music',
    icon: Icons.music_note_outlined,
    activeIcon: Icons.music_note,
    color: Color(0xFF9C27B0),
  ),
  document(
    labelKey: 'category_documents',
    icon: Icons.description_outlined,
    activeIcon: Icons.description,
    color: Color(0xFF2196F3),
  ),
  archive(
    labelKey: 'category_archives',
    icon: Icons.archive_outlined,
    activeIcon: Icons.archive,
    color: Color(0xFFFF9800),
  ),
  executable(
    labelKey: 'category_programs',
    icon: Icons.apps_outlined,
    activeIcon: Icons.apps,
    color: Color(0xFF607D8B),
  );

  const FileCategory({
    required this.labelKey,
    required this.icon,
    required this.activeIcon,
    required this.color,
  });

  final String labelKey;
  final IconData icon;
  final IconData activeIcon;
  final Color color;
}
