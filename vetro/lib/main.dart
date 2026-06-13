import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetro/app.dart';
import 'package:vetro/core/services/error_handler.dart';
import 'package:vetro/core/services/thumbnail_cache.dart';
import 'package:vetro/features/settings/data/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final settings = await SettingsService.create();
  await ThumbnailCache.instance.init();

  // Global error handler
  FlutterError.onError = (details) {
    ErrorHandler.instance.handle(
      details.exception,
      source: 'FlutterError',
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(() {
    runApp(
      ProviderScope(
        overrides: [
          settingsServiceProvider.overrideWithValue(settings),
        ],
        child: const VetroApp(),
      ),
    );
  }, (error, stackTrace) {
    ErrorHandler.instance.handle(error, stackTrace: stackTrace);
  });
}
