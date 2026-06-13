import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vetro/core/models/file_item.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key, required this.file});

  final FileItem file;

  @override
  Widget build(BuildContext context) {
    if (file.extension == 'svg') {
      return _SvgPreview(file: file);
    }
    return _RasterPreview(file: file);
  }
}

class _RasterPreview extends StatelessWidget {
  const _RasterPreview({required this.file});

  final FileItem file;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.1,
      maxScale: 5.0,
      child: Center(
        child: Image.file(
          File(file.path),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _SvgPreview extends StatelessWidget {
  const _SvgPreview({required this.file});

  final FileItem file;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.1,
      maxScale: 5.0,
      child: Center(
        child: SvgPicture.file(
          File(file.path),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
