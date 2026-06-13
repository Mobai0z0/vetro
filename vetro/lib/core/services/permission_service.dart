import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionResult {
  const PermissionResult({
    required this.granted,
    this.deniedPermissions = const [],
    this.permanentlyDenied = false,
  });

  final bool granted;
  final List<String> deniedPermissions;
  final bool permanentlyDenied;

  @override
  String toString() => 'PermissionResult(granted: $granted, denied: $deniedPermissions)';
}

class PermissionService {
  Future<PermissionResult> requestStoragePermission() async {
    if (kIsWeb) return const PermissionResult(granted: true);

    if (Platform.isAndroid) {
      return _requestAndroidStoragePermission();
    } else if (Platform.isIOS) {
      return _requestIOSPermission();
    } else if (Platform.isMacOS) {
      return _requestMacOSPermission();
    }

    // Desktop platforms: no explicit permission needed
    return const PermissionResult(granted: true);
  }

  Future<PermissionResult> requestMediaPermission() async {
    if (kIsWeb || !Platform.isAndroid) {
      return requestStoragePermission();
    }

    final results = <String, PermissionStatus>{};

    final photos = await Permission.photos.status;
    if (photos.isDenied || photos.isPermanentlyDenied) {
      results['photos'] = await Permission.photos.request();
    }

    final videos = await Permission.videos.status;
    if (videos.isDenied || videos.isPermanentlyDenied) {
      results['videos'] = await Permission.videos.request();
    }

    final audio = await Permission.audio.status;
    if (audio.isDenied || audio.isPermanentlyDenied) {
      results['audio'] = await Permission.audio.request();
    }

    final allGranted = results.values.every((s) => s.isGranted);
    final anyPermanently = results.values.any((s) => s.isPermanentlyDenied);
    final denied = results.entries
        .where((e) => !e.value.isGranted)
        .map((e) => e.key)
        .toList();

    return PermissionResult(
      granted: allGranted,
      deniedPermissions: denied,
      permanentlyDenied: anyPermanently,
    );
  }

  Future<PermissionResult> _requestAndroidStoragePermission() async {
    // Android 13+ uses granular media permissions
    if (await _isAndroid13OrAbove()) {
      return _requestAndroid13Permissions();
    }

    // Android 11-12: MANAGE_EXTERNAL_STORAGE for full access
    if (await _isAndroid11OrAbove()) {
      if (await Permission.manageExternalStorage.isGranted) {
        return const PermissionResult(granted: true);
      }

      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return const PermissionResult(granted: true);
      }

      // Fallback to basic storage
      final storageStatus = await Permission.storage.request();
      return PermissionResult(
        granted: storageStatus.isGranted,
        deniedPermissions: storageStatus.isGranted ? [] : ['manage_external_storage'],
        permanentlyDenied: storageStatus.isPermanentlyDenied,
      );
    }

    // Android 10 and below
    final status = await Permission.storage.request();
    return PermissionResult(
      granted: status.isGranted,
      deniedPermissions: status.isGranted ? [] : ['storage'],
      permanentlyDenied: status.isPermanentlyDenied,
    );
  }

  Future<PermissionResult> _requestAndroid13Permissions() async {
    final denied = <String>[];

    final photos = await Permission.photos.request();
    if (!photos.isGranted) denied.add('photos');

    final videos = await Permission.videos.request();
    if (!videos.isGranted) denied.add('videos');

    final audio = await Permission.audio.request();
    if (!audio.isGranted) denied.add('audio');

    final anyPermanently = photos.isPermanentlyDenied ||
        videos.isPermanentlyDenied ||
        audio.isPermanentlyDenied;

    return PermissionResult(
      granted: denied.isEmpty,
      deniedPermissions: denied,
      permanentlyDenied: anyPermanently,
    );
  }

  Future<PermissionResult> _requestIOSPermission() async {
    // iOS needs specific photo/video/audio access
    final denied = <String>[];

    final photos = await Permission.photos.request();
    if (!photos.isGranted) denied.add('photos');

    final anyPermanently = photos.isPermanentlyDenied;

    return PermissionResult(
      granted: denied.isEmpty,
      deniedPermissions: denied,
      permanentlyDenied: anyPermanently,
    );
  }

  Future<PermissionResult> _requestMacOSPermission() async {
    // macOS needs file access through sandbox
    final photos = await Permission.photos.status;
    final movies = await Permission.movies.status;
    final music = await Permission.music.status;

    final denied = <String>[];
    if (photos.isDenied) denied.add('photos');
    if (movies.isDenied) denied.add('movies');
    if (music.isDenied) denied.add('music');

    if (denied.isNotEmpty) {
      // Request all at once
      await [Permission.photos, Permission.movies, Permission.music].request();
    }

    return const PermissionResult(granted: true);
  }

  Future<bool> _isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;
    try {
      final sdkInt = int.parse(
        Platform.version.split(' ').last.split('-').first,
      );
      return sdkInt >= 33;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isAndroid11OrAbove() async {
    if (!Platform.isAndroid) return false;
    try {
      final sdkInt = int.parse(
        Platform.version.split(' ').last.split('-').first,
      );
      return sdkInt >= 30;
    } catch (_) {
      return false;
    }
  }

  Future<bool> openAppSettingsIfDenied(PermissionResult result) async {
    if (result.permanentlyDenied) {
      return openAppSettings();
    }
    return false;
  }
}
