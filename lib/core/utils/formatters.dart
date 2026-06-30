import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _amount = NumberFormat('#,##0', 'fr_FR');

  static String money(num value) => '${_amount.format(value)} XOF';

  static String amount(num value) => _amount.format(value);

  static String phone(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    final match =
        RegExp(r'^\+221(\d{2})(\d{3})(\d{2})(\d{2})$').firstMatch(cleaned);
    if (match == null) return value;
    return '+221 ${match[1]} ${match[2]} ${match[3]} ${match[4]}';
  }

  static String date(DateTime value) =>
      DateFormat('d MMM yyyy', 'fr_FR').format(value);

  static String dateTime(DateTime value) =>
      DateFormat('d MMM yyyy · HH:mm', 'fr_FR').format(value);

  static String periode(String yearMonth) {
    final parts = yearMonth.split('-');
    if (parts.length != 2) return yearMonth;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null || month < 1 || month > 12) {
      return yearMonth;
    }
    return DateFormat('MMMM yyyy', 'fr_FR').format(DateTime(year, month));
  }
}
