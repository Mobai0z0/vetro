import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vetro/core/models/file_item.dart';

class TextPreview extends StatefulWidget {
  const TextPreview({super.key, required this.file, this.isCode = false});

  final FileItem file;
  final bool isCode;

  @override
  State<TextPreview> createState() => _TextPreviewState();
}

class _TextPreviewState extends State<TextPreview> {
  String? _content;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final file = File(widget.file.path);
      final content = await file.readAsString();
      if (mounted) setState(() => _content = content);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.error),
            const SizedBox(height: 16),
            Text('Error reading file: $_error'),
          ],
        ),
      );
    }

    if (_content == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.isCode) {
      return _CodeView(content: _content!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _content!,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }
}

class _CodeView extends StatelessWidget {
  const _CodeView({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: SelectableText.rich(
          TextSpan(
            text: content,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.5,
              color: isDark ? const Color(0xFFD4D4D4) : const Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}
