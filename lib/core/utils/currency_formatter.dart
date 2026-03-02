import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormat = NumberFormat.compact(
    locale: 'id_ID',
  );

  /// Format double to Rupiah (e.g., "Rp 1.500.000")
  static String formatRupiah(double amount) => _rupiahFormat.format(amount);

  /// Format double to compact (e.g., "1,5 jt")
  static String formatCompact(double amount) => _compactFormat.format(amount);

  /// Format number with thousand separator
  static String formatNumber(double amount) =>
      NumberFormat('#,###', 'id_ID').format(amount);
}
