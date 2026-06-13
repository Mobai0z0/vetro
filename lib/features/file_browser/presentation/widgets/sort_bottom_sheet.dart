import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetro/core/models/sort_type.dart';
import 'package:vetro/features/file_browser/presentation/file_browser_screen.dart';
import 'package:vetro/features/settings/data/settings_service.dart';

class SortBottomSheet extends ConsumerWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);
    final currentSort = settings.sortType;
    final isAscending = settings.sortAscending;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Sort by', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _SortOption(
            label: 'Name',
            icon: Icons.sort_by_alpha,
            selected: currentSort == SortType.name,
            onTap: () {
              settings.sortType = SortType.name;
              ref.invalidate(fileListProvider);
            },
          ),
          _SortOption(
            label: 'Size',
            icon: Icons.sort,
            selected: currentSort == SortType.size,
            onTap: () {
              settings.sortType = SortType.size;
              ref.invalidate(fileListProvider);
            },
          ),
          _SortOption(
            label: 'Date',
            icon: Icons.calendar_today,
            selected: currentSort == SortType.date,
            onTap: () {
              settings.sortType = SortType.date;
              ref.invalidate(fileListProvider);
            },
          ),
          _SortOption(
            label: 'Type',
            icon: Icons.category,
            selected: currentSort == SortType.type,
            onTap: () {
              settings.sortType = SortType.type;
              ref.invalidate(fileListProvider);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Ascending'),
            value: isAscending,
            onChanged: (v) {
              settings.sortAscending = v;
              ref.invalidate(fileListProvider);
            },
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: selected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      selected: selected,
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }
}
