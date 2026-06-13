import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SearchService {
  SearchService._();

  static Timer? _debounceTimer;

  static Future<List<SearchResult>> search({
    required String query,
    required String rootPath,
    int maxResults = 100,
    Duration debounce = const Duration(milliseconds: 300),
  }) async {
    if (query.trim().isEmpty) return [];

    final completer = Completer<List<SearchResult>>();
    _debounceTimer?.cancel();

    _debounceTimer = Timer(debounce, () async {
      try {
        final results = await _performSearch(
          query: query.toLowerCase(),
          rootPath: rootPath,
          maxResults: maxResults,
        );
        completer.complete(results);
      } catch (e) {
        completer.complete([]);
      }
    });

    return completer.future;
  }

  static Future<List<SearchResult>> _performSearch({
    required String query,
    required String rootPath,
    required int maxResults,
  }) async {
    final results = <SearchResult>[];
    final rootDir = Directory(rootPath);

    if (!await rootDir.exists()) return results;

    await _searchDirectory(
      dir: rootDir,
      query: query,
      results: results,
      maxResults: maxResults,
      depth: 0,
      maxDepth: 8,
    );

    results.sort((a, b) {
      // Prioritize name matches
      if (a.name.toLowerCase().contains(query) &&
          !b.name.toLowerCase().contains(query)) {
        return -1;
      }
      if (!a.name.toLowerCase().contains(query) &&
          b.name.toLowerCase().contains(query)) {
        return 1;
      }
      return b.modifiedAt.compareTo(a.modifiedAt);
    });

    return results.take(maxResults).toList();
  }

  static Future<void> _searchDirectory({
    required Directory dir,
    required String query,
    required List<SearchResult> results,
    required int maxResults,
    required int depth,
    required int maxDepth,
  }) async {
    if (depth > maxDepth || results.length >= maxResults) return;

    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (results.length >= maxResults) break;

        try {
          final name = entity.path.split(Platform.pathSeparator).last;
          if (name.startsWith('.')) continue;

          final stat = await entity.stat();
          final isDir = entity is Directory;
          final matches = name.toLowerCase().contains(query);

          if (matches) {
            results.add(SearchResult(
              name: name,
              path: entity.path,
              isDirectory: isDir,
              size: stat.size,
              modifiedAt: stat.modified,
            ));
          }

          if (isDir && !matches) {
            // Only search subdirectories if they might contain matches
            await _searchDirectory(
              dir: entity,
              query: query,
              results: results,
              maxResults: maxResults,
              depth: depth + 1,
              maxDepth: maxDepth,
            );
          }
        } catch (_) {
          continue;
        }
      }
    } catch (_) {}
  }

  static void cancelSearch() {
    _debounceTimer?.cancel();
  }
}

class SearchResult {
  const SearchResult({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modifiedAt,
  });

  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime modifiedAt;
}
