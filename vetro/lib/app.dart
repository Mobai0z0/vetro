import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetro/core/theme/vetro_theme.dart';
import 'package:vetro/core/theme/vetro_colors.dart';
import 'package:vetro/core/services/error_banner.dart';
import 'package:vetro/features/settings/data/settings_service.dart';
import 'package:vetro/features/shell/presentation/shell_screen.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('Must be overridden');
});

class VetroApp extends ConsumerWidget {
  const VetroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);
    final seedColor = settings.accentColor;
    final themeMode = settings.themeMode;

    final lightScheme = VetroColors.generateColorScheme(seedColor, Brightness.light);
    final darkScheme = VetroColors.generateColorScheme(seedColor, Brightness.dark);

    return MaterialApp(
      title: 'Vetro',
      debugShowCheckedModeBanner: false,
      theme: VetroTheme.light(lightScheme),
      darkTheme: VetroTheme.dark(darkScheme),
      themeMode: themeMode,
      home: ErrorBanner(
        child: const ShellScreen(),
      ),
    );
  }
}
