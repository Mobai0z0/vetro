import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:vetro/core/models/file_item.dart';

class PdfPreview extends StatelessWidget {
  const PdfPreview({super.key, required this.file});

  final FileItem file;

  @override
  Widget build(BuildContext context) {
    return PdfViewer.file(
      File(file.path),
      params: const PdfViewerParams(
        scrollDirection: AxisDirection.vertical,
        minScale: 0.5,
        maxScale: 5.0,
      ),
    );
  }
}
