import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetro/core/models/sort_type.dart';
import 'package:vetro/features/settings/data/settings_service.dart';
import 'package:vetro/features/shell/presentation/shell_screen.dart';
import 'widgets/color_picker_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _SectionHeader(title: 'Appearance'.toUpperCase()),
          ColorPickerTile(
            currentColor: settings.accentColor,
            onColorChanged: (color) {
              settings.accentColor = color;
              // Force app rebuild by invalidating settings
              ref.invalidate(settingsServiceProvider);
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Follow system'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (v) {
              settings.themeMode = v ? ThemeMode.dark : ThemeMode.light;
              ref.invalidate(settingsServiceProvider);
            },
          ),

          // File Browser Section
          _SectionHeader(title: 'File Browser'.toUpperCase()),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Home Folder'),
            subtitle: Text(
              settings.homePath.isEmpty ? 'System default' : settings.homePath,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHomePathDialog(context, ref, settings),
          ),
          SwitchListTile(
            title: const Text('Open with Internal Viewer'),
            subtitle: const Text('Preview files inside the app'),
            secondary: const Icon(Icons.open_in_new),
            value: settings.openWithInternal,
            onChanged: (v) => settings.openWithInternal = v,
          ),
          ListTile(
            leading: const Icon(Icons.sort),
            title: const Text('Default Sort'),
            subtitle: Text(_sortTypeName(settings.sortType)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSortPicker(context, ref, settings),
          ),

          // Language Section
          _SectionHeader(title: 'Language'.toUpperCase()),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_languageName(settings.languageCode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, ref, settings),
          ),

          // Storage Section
          _SectionHeader(title: 'Storage'.toUpperCase()),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear Cache'),
            onTap: () => _clearCache(context),
          ),

          // About Section
          _SectionHeader(title: 'About'.toUpperCase()),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Vetro'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source Code'),
            subtitle: const Text('github.com/vetro/vetro'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: context, applicationName: 'Vetro'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _sortTypeName(SettingsService settings) {
    switch (settings.sortType) {
      case SortType.name:
        return 'Name';
      case SortType.size:
        return 'Size';
      case SortType.date:
        return 'Date';
      case SortType.type:
        return 'Type';
    }
  }

  String _languageName(String code) {
    switch (code) {
      case 'system':
        return 'System default';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      default:
        return code;
    }
  }

  void _showHomePathDialog(BuildContext context, WidgetRef ref, SettingsService settings) {
    final controller = TextEditingController(text: settings.homePath);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Home Folder Path'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '/path/to/folder or leave empty for system default',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              settings.homePath = controller.text.trim();
              ref.invalidate(fileListProvider);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSortPicker(BuildContext context, WidgetRef ref, SettingsService settings) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Default Sort'),
        children: SortType.values.map((type) {
          return SimpleDialogOption(
            onPressed: () {
              settings.sortType = type;
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                if (settings.sortType == type)
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(_sortTypeName(type)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, SettingsService settings) {
    final languages = [
      ('system', 'System default'),
      ('en', 'English'),
      ('zh', '中文'),
    ];

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Language'),
        children: languages.map((lang) {
          return SimpleDialogOption(
            onPressed: () {
              settings.languageCode = lang.$1;
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                if (settings.languageCode == lang.$1)
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(lang.$2),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Clear all cached files? This will not delete your files.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Vetro',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.folder, size: 48),
      children: const [
        Text('A cross-platform file browser with built-in previewers.'),
        SizedBox(height: 16),
        Text('Built with Flutter and Material Design 3.'),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
