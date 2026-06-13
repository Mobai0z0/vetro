import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:vetro/core/models/file_item.dart';
import 'package:vetro/core/utils/format_utils.dart';

class ArchivePreview extends StatefulWidget {
  const ArchivePreview({super.key, required this.file});

  final FileItem file;

  @override
  State<ArchivePreview> createState() => _ArchivePreviewState();
}

class _ArchivePreviewState extends State<ArchivePreview> {
  List<ArchiveFile>? _files;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArchive();
  }

  Future<void> _loadArchive() async {
    try {
      final bytes = await File(widget.file.path).readAsBytes();
      Archive archive;

      switch (widget.file.extension.toLowerCase()) {
        case 'zip':
          archive = ZipDecoder().decodeBytes(bytes);
          break;
        case 'tar':
          archive = TarDecoder().decodeBytes(bytes);
          break;
        case 'gz':
        case 'tgz':
          archive = GZipDecoder().decodeBytes(bytes);
          break;
        default:
          throw UnsupportedFormat('Unsupported archive format');
      }

      if (mounted) {
        setState(() {
          _files = archive.toList();
        });
      }
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
            Text('Error reading archive: $_error'),
          ],
        ),
      );
    }

    if (_files == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_files!.isEmpty) {
      return const Center(
        child: Text('Archive is empty'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.archive, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                '${_files!.length} files in archive',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: _files!.length,
            itemBuilder: (context, index) {
              final file = _files![index];
              final isDir = file.isFile == false;
              final name = file.name;
              final size = file.size;

              return ListTile(
                leading: Icon(
                  isDir ? Icons.folder : Icons.insert_drive_file,
                  color: isDir ? Colors.amber : null,
                ),
                title: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: isDir
                    ? null
                    : Text(FormatUtils.formatFileSize(size)),
                trailing: isDir ? null : const Icon(Icons.chevron_right),
              );
            },
          ),
        ),
      ],
    );
  }
}
