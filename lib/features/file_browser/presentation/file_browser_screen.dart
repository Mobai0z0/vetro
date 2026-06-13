import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:vetro/core/models/file_item.dart';
import 'package:vetro/core/services/file_service.dart';
import 'package:vetro/core/services/permission_service.dart';
import 'package:vetro/core/services/error_handler.dart';
import 'package:vetro/core/utils/format_utils.dart';
import 'package:vetro/core/utils/file_operations.dart';
import 'package:vetro/features/settings/data/settings_service.dart';
import 'package:vetro/features/shell/presentation/shell_screen.dart';
import 'package:vetro/features/preview/presentation/preview_screen.dart';
import 'widgets/file_list_tile.dart';
import 'widgets/file_grid_tile.dart';
import 'widgets/sort_bottom_sheet.dart';
import 'widgets/create_folder_dialog.dart';
import 'widgets/file_action_bottom_sheet.dart';

final fileServiceProvider = Provider<FileService>((ref) => FileService());
final permissionServiceProvider = Provider<PermissionService>((ref) => PermissionService());

final currentPathProvider = StateProvider<String>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  final homePath = settings.homePath;
  if (homePath.isNotEmpty) return homePath;
  return '';
});

final viewModeProvider = StateProvider<bool>((ref) => false);

final fileListProvider = FutureProvider<List<FileItem>>((ref) async {
  final path = ref.watch(currentPathProvider);
  final fileService = ref.watch(fileServiceProvider);
  try {
    return fileService.listDirectory(path);
  } catch (e) {
    ErrorHandler.instance.handle(e, source: 'listDirectory');
    return <FileItem>[];
  }
});

class FileBrowserScreen extends ConsumerStatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  ConsumerState<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends ConsumerState<FileBrowserScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectionPaths = [];
  bool _isSearching = false;
  String _searchQuery = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;

    final settings = ref.read(settingsServiceProvider);
    if (settings.homePath.isEmpty) {
      final home = await _getHomePath();
      ref.read(currentPathProvider.notifier).state = home;
    }
  }

  Future<String> _getHomePath() async {
    try {
      final dirs = await PermissionService().requestStoragePermission();
      if (!dirs.granted) {
        ErrorHandler.instance.handle(
          'Storage permission denied',
          source: 'FileBrowser',
        );
      }
    } catch (_) {}

    // Use path_provider as fallback
    try {
      final home = await _getHomeDirectory();
      return home;
    } catch (_) {
      return '';
    }
  }

  Future<String> _getHomeDirectory() async {
    if (await _pathExists('/home')) return '/home';
    if (await _pathExists('C:\\Users')) return 'C:\\Users';
    if (await _pathExists('/Users')) return '/Users';
    return '';
  }

  Future<bool> _pathExists(String path) async {
    try {
      return await Directory(path).exists();
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateTo(String path) {
    ref.read(currentPathProvider.notifier).state = path;
    ref.invalidate(fileListProvider);
    setState(() => _selectionPaths = []);
    _focusNode.requestFocus();
  }

  void _navigateUp() {
    final current = ref.read(currentPathProvider);
    final parent = p.dirname(current);
    if (parent != current) {
      _navigateTo(parent);
    }
  }

  void _openFile(FileItem file) {
    if (file.isFolder) {
      _navigateTo(file.path);
    } else {
      _showPreview(file);
    }
  }

  void _showPreview(FileItem file) {
    if (FileOperations.canPreview(file.path)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PreviewScreen(file: file),
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

  void _toggleSelection(String path) {
    setState(() {
      if (_selectionPaths.contains(path)) {
        _selectionPaths.remove(path);
      } else {
        _selectionPaths.add(path);
      }
    });
  }

  void _clearSelection() => setState(() => _selectionPaths = []);

  void _selectAll(List<FileItem> files) {
    setState(() {
      _selectionPaths = files.map((f) => f.path).toList();
    });
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => const SortBottomSheet(),
    );
  }

  void _showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (_) => CreateFolderDialog(
        parentPath: ref.read(currentPathProvider),
        onCreated: () => ref.invalidate(fileListProvider),
      ),
    );
  }

  void _showRenameDialog(FileItem file) {
    final controller = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == file.name) {
                Navigator.pop(ctx);
                return;
              }
              try {
                await ref.read(fileServiceProvider).rename(file.path, newName);
                ref.invalidate(fileListProvider);
                if (mounted) Navigator.pop(ctx);
              } catch (e) {
                ErrorHandler.instance.handle(e, source: 'rename');
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showFileActions(FileItem file) {
    showModalBottomSheet(
      context: context,
      builder: (_) => FileActionBottomSheet(
        file: file,
        onAction: (action) {
          Navigator.pop(context);
          _handleFileAction(action, file);
        },
      ),
    );
  }

  void _handleFileAction(String action, FileItem file) async {
    final fileService = ref.read(fileServiceProvider);

    switch (action) {
      case 'rename':
        _showRenameDialog(file);
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete'),
            content: Text('Delete "${file.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          try {
            await fileService.delete(file.path);
            ref.invalidate(fileListProvider);
          } catch (e) {
            ErrorHandler.instance.handle(e, source: 'delete');
          }
        }
        break;
      case 'copy':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to destination and paste')),
        );
        break;
      case 'move':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to destination and paste')),
        );
        break;
      case 'info':
        _showFileInfo(file);
        break;
    }
  }

  void _showFileInfo(FileItem file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Type', file.isFolder ? 'Folder' : file.extension.toUpperCase()),
            _infoRow('Size', FormatUtils.formatFileSize(file.size)),
            _infoRow('Modified', FormatUtils.formatFullDateTime(file.modifiedAt)),
            const SizedBox(height: 8),
            Text(
              file.path,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: file.path));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Path copied')),
              );
            },
            child: const Text('Copy Path'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = ref.watch(currentPathProvider);
    final isGrid = ref.watch(viewModeProvider);
    final fileListAsync = ref.watch(fileListProvider);
    final isSelecting = _selectionPaths.isNotEmpty;

    final files = fileListAsync.valueOrNull ?? [];
    final filteredFiles = _searchQuery.isEmpty
        ? files
        : files
            .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return PopScope(
      canPop: _selectionPaths.isEmpty && !isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_selectionPaths.isNotEmpty) {
            _clearSelection();
          } else if (isSearching) {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: isSelecting
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSelection,
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _navigateUp,
                ),
          title: isSelecting
              ? Text('${_selectionPaths.length} selected')
              : isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.basename(currentPath),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          currentPath,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
          actions: isSelecting
              ? [
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: () => _selectAll(filteredFiles),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete'),
                          content: Text(
                            'Delete ${_selectionPaths.length} items?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        for (final path in _selectionPaths) {
                          await ref.read(fileServiceProvider).delete(path);
                        }
                        _clearSelection();
                        ref.invalidate(fileListProvider);
                      }
                    },
                  ),
                ]
              : [
                  IconButton(
                    icon: Icon(isSearching ? Icons.close : Icons.search),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchQuery = '';
                          _searchController.clear();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
                    onPressed: () {
                      ref.read(viewModeProvider.notifier).state = !isGrid;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: _showSortDialog,
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'create_folder') _showCreateFolderDialog();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'create_folder',
                        child: ListTile(
                          leading: Icon(Icons.create_new_folder),
                          title: Text('New Folder'),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ],
        ),
        body: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.backspace &&
                  !isSearching) {
                _navigateUp();
              } else if (event.logicalKey == LogicalKeyboardKey.enter &&
                  _selectionPaths.length == 1) {
                final file = files.firstWhere(
                  (f) => f.path == _selectionPaths.first,
                );
                _showRenameDialog(file);
              }
            }
          },
          child: fileListAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $e'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(fileListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (_) {
              if (filteredFiles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty ? Icons.search_off : Icons.folder_open,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty ? 'No results' : 'Empty folder',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                );
              }

              if (isGrid) {
                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredFiles.length,
                  itemBuilder: (context, index) {
                    final file = filteredFiles[index];
                    final isSelected = _selectionPaths.contains(file.path);
                    return FileGridTile(
                      file: file,
                      isSelected: isSelected,
                      onTap: () => _selectionPaths.isNotEmpty
                          ? _toggleSelection(file.path)
                          : _openFile(file),
                      onLongPress: () => _toggleSelection(file.path),
                      onSecondaryTap: () => _showFileActions(file),
                    );
                  },
                );
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: filteredFiles.length,
                itemBuilder: (context, index) {
                  final file = filteredFiles[index];
                  final isSelected = _selectionPaths.contains(file.path);
                  return FileListTile(
                    file: file,
                    isSelected: isSelected,
                    onTap: () => _selectionPaths.isNotEmpty
                        ? _toggleSelection(file.path)
                        : _openFile(file),
                    onLongPress: () => _toggleSelection(file.path),
                    onSecondaryTap: () => _showFileActions(file),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateFolderDialog,
          child: const Icon(Icons.create_new_folder),
        ),
      ),
    );
  }
}
