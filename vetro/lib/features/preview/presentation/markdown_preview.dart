import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vetro/core/models/file_item.dart';

class MarkdownPreview extends StatefulWidget {
  const MarkdownPreview({super.key, required this.file});

  final FileItem file;

  @override
  State<MarkdownPreview> createState() => _MarkdownPreviewState();
}

class _MarkdownPreviewState extends State<MarkdownPreview> {
  String? _content;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    final file = File(widget.file.path);
    final content = await file.readAsString();
    if (mounted) setState(() => _content = content);
  }

  @override
  Widget build(BuildContext context) {
    if (_content == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Markdown(
      data: _content!,
      padding: const EdgeInsets.all(16),
    );
  }
}
