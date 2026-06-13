import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  static final _numberFormat = NumberFormat.decimalPattern();
  static final _dateOnlyFormat = DateFormat.yMMMd();
  static final _dateTimeFormat = DateFormat.yMMMd().add_jm();
  static final _timeFormat = DateFormat.jm();

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String formatTotalSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${_numberFormat.format((bytes / 1024).round())} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${_numberFormat.format((bytes / (1024 * 1024)).round())} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return _timeFormat.format(date);
    if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    if (now.difference(date).inDays < 7) {
      return DateFormat.EEEE().format(date);
    }
    return _dateOnlyFormat.format(date);
  }

  static String formatFullDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }
}
