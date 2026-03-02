import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _displayWithTimeFormat = DateFormat(
    'dd MMM yyyy, HH:mm',
  );
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _shortMonthFormat = DateFormat('MMM');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  /// Format DateTime to "dd MMM yyyy" (e.g., "02 Mar 2026")
  static String formatDisplay(DateTime date) => _displayFormat.format(date);

  /// Format DateTime to "dd MMM yyyy, HH:mm"
  static String formatDisplayWithTime(DateTime date) =>
      _displayWithTimeFormat.format(date);

  /// Format DateTime to "MMMM yyyy" (e.g., "March 2026")
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);

  /// Format DateTime to short month (e.g., "Mar")
  static String formatShortMonth(DateTime date) =>
      _shortMonthFormat.format(date);

  /// Format DateTime to ISO date string "yyyy-MM-dd"
  static String formatIso(DateTime date) => _isoFormat.format(date);

  /// Get start of month for filtering
  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  /// Get end of month for filtering
  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);

  /// Get list of last N months as DateTime (first day of each month)
  static List<DateTime> getLastNMonths(int n) {
    final now = DateTime.now();
    return List.generate(
      n,
      (i) => DateTime(now.year, now.month - i, 1),
    ).reversed.toList();
  }
}
