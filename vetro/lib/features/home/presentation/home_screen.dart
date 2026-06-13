import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetro/core/models/file_category.dart';
import 'package:vetro/core/models/sort_type.dart';
import 'package:vetro/core/services/scanner_service.dart';
import 'package:vetro/core/services/permission_service.dart';
import 'package:vetro/core/services/error_handler.dart';
import 'package:vetro/core/models/file_item.dart';
import 'package:vetro/features/settings/data/settings_service.dart';
import 'package:vetro/core/utils/format_utils.dart';
import 'package:vetro/core/utils/file_operations.dart';
import 'widgets/category_card.dart';

final scannerServiceProvider = Provider<ScannerService>((ref) => ScannerService());

final categoryFilesProvider = FutureProvider<Map<String, List<FileItem>>>((ref) async {
  final scanner = ref.watch(scannerServiceProvider);

  // Request permissions first
  final permissionService = PermissionService();
  final result = await permissionService.requestStoragePermission();
  if (!result.granted) {
    ErrorHandler.instance.handle(
      'Storage permission denied. Some files may not be visible.',
      source: 'HomeScreen',
      severity: ErrorSeverity.warning,
    );
  }

  final dirs = await scanner.getSystemDirectories();
  return scanner.scanByCategory(dirs);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryFilesAsync = ref.watch(categoryFilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vetro'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(categoryFilesProvider),
          ),
        ],
      ),
      body: categoryFilesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.error),
              const SizedBox(height: 16),
              Text('Error: $e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(categoryFilesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (categoryFiles) {
          final categories = FileCategory.values;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final files = categoryFiles[category.name] ?? [];
              return CategoryCard(
                category: category,
                fileCount: files.length,
                totalSize: files.fold(0, (sum, f) => sum + f.size),
                onTap: () => _openCategory(context, category, files),
              );
            },
          );
        },
      ),
    );
  }

  void _openCategory(
    BuildContext context,
    FileCategory category,
    List<FileItem> files,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryFilesScreen(
          category: category,
          files: files,
        ),
      ),
    );
  }
}

class CategoryFilesScreen extends ConsumerStatefulWidget {
  const CategoryFilesScreen({
    super.key,
    required this.category,
    required this.files,
  });

  final FileCategory category;
  final List<FileItem> files;

  @override
  ConsumerState<CategoryFilesScreen> createState() =>
      _CategoryFilesScreenState();
}

class _CategoryFilesScreenState extends ConsumerState<CategoryFilesScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsServiceProvider);
    final sorted = List<FileItem>.from(widget.files)
      ..sort((a, b) {
        int cmp;
        switch (settings.sortType) {
          case SortType.name:
            cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          case SortType.size:
            cmp = a.size.compareTo(b.size);
          case SortType.date:
            cmp = a.modifiedAt.compareTo(b.modifiedAt);
          case SortType.type:
            cmp = a.type.index.compareTo(b.type.index);
        }
        return settings.sortAscending ? cmp : -cmp;
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name.toUpperCase()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: sorted.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.category.icon, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No files found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final file = sorted[index];
                return ListTile(
                  leading: Icon(
                    widget.category.activeIcon,
                    color: widget.category.color,
                  ),
                  title: Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(FormatUtils.formatFileSize(file.size)),
                      Text(
                        FormatUtils.formatDate(file.modifiedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () => _openFile(file),
                );
              },
            ),
    );
  }

  void _openFile(FileItem file) {
    if (FileOperations.canPreview(file.path)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _FilePreviewScreen(file: file),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No preview available for .${file.extension} files'),
        ),
      );
    }
  }
}

class _FilePreviewScreen extends StatelessWidget {
  const _FilePreviewScreen({required this.file});

  final FileItem file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(file.name)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.open_in_new, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(file.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Preview for .${file.extension} files',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
