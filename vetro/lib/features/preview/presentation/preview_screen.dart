import 'package:flutter/material.dart';
import 'package:vetro/core/models/file_item.dart';
import 'package:vetro/core/constants/file_extensions.dart';
import 'image_preview.dart';
import 'video_preview.dart';
import 'audio_preview.dart';
import 'pdf_preview.dart';
import 'text_preview.dart';
import 'markdown_preview.dart';
import 'archive_preview.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.file});

  final FileItem file;

  static Widget forFile(FileItem file) {
    return PreviewScreen(file: file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildPreview(),
    );
  }

  Widget _buildPreview() {
    switch (file.type) {
      case FileType.image:
        return ImagePreview(file: file);
      case FileType.video:
        return VideoPreview(file: file);
      case FileType.audio:
        return AudioPreview(file: file);
      case FileType.document:
        if (file.extension == 'pdf') return PdfPreview(file: file);
        return _UnsupportedPreview(file: file);
      case FileType.text:
        return TextPreview(file: file);
      case FileType.code:
        return TextPreview(file: file, isCode: true);
      case FileType.archive:
        return ArchivePreview(file: file);
      default:
        return _UnsupportedPreview(file: file);
    }
  }
}

class _UnsupportedPreview extends StatelessWidget {
  const _UnsupportedPreview({required this.file});

  final FileItem file;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            file.name,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Preview not available for .${file.extension} files',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () {},
            child: const Text('Open with external app'),
          ),
        ],
      ),
    );
  }
}
