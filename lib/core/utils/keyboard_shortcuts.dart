import 'package:flutter/services.dart';

class KeyboardShortcuts {
  KeyboardShortcuts._();

  static final Map<LogicalKeySet, String> defaultShortcuts = {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
        'new_folder',
    LogicalKeySet(LogicalKeyboardKey.delete): 'delete',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA):
        'select_all',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
        'copy',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyX):
        'cut',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
        'paste',
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
        'search',
    LogicalKeySet(LogicalKeyboardKey.escape): 'escape',
    LogicalKeySet(LogicalKeyboardKey.backspace): 'back',
    LogicalKeySet(LogicalKeyboardKey.enter): 'open',
    LogicalKeySet(LogicalKeyboardKey.f2): 'rename',
    LogicalKeySet(LogicalKeyboardKey.f5): 'refresh',
  };

  static String? getAction(KeyEvent event) {
    if (event is! KeyDownEvent) return null;

    final isCtrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyN) {
      return 'new_folder';
    }
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyA) {
      return 'select_all';
    }
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyC) {
      return 'copy';
    }
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyX) {
      return 'cut';
    }
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyV) {
      return 'paste';
    }
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyF) {
      return 'search';
    }
    if (event.logicalKey == LogicalKeyboardKey.delete) {
      return 'delete';
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      return 'escape';
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      return 'back';
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      return 'open';
    }
    if (event.logicalKey == LogicalKeyboardKey.f2) {
      return 'rename';
    }
    if (event.logicalKey == LogicalKeyboardKey.f5) {
      return 'refresh';
    }

    return null;
  }
}
