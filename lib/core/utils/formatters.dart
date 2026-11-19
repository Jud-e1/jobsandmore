import 'package:intl/intl.dart';

/// Shared display formatting (Naira, dates, deadlines).
abstract final class JmFormat {
  static final _naira = NumberFormat.currency(
    locale: 'en',
    symbol: '₦',
    decimalDigits: 0,
  );

  /// ₦450,000.
  static String naira(num amount) => _naira.format(amount);

  /// ₦450k, ₦1.2m.
  static String nairaShort(num amount) {
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '₦${m.toStringAsFixed(m >= 10 || m == m.roundToDouble() ? 0 : 1)}m';
    }
    if (amount >= 1000) return '₦${(amount / 1000).round()}k';
    return '₦${amount.round()}';
  }

  /// "₦350k – ₦500k / month", or null when the employer has not disclosed it.
  static String? salaryRange(
    int? min,
    int? max, {
    required bool disclosed,
    String period = 'month',
  }) {
    if (!disclosed || (min == null && max == null)) return null;
    if (min != null && max != null && min != max) {
      return '${nairaShort(min)} – ${nairaShort(max)} / $period';
    }
    return '${nairaShort(min ?? max!)} / $period';
  }

  /// Deadline text plus whether it should be shown as urgent.
  static ({String label, bool urgent}) closingIn(
    DateTime closing,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(closing.year, closing.month, closing.day);
    final days = day.difference(today).inDays;
    if (days < 0) return (label: 'Closed', urgent: false);
    if (days == 0) return (label: 'Closes today', urgent: true);
    if (days == 1) return (label: 'Closes tomorrow', urgent: true);
    if (days <= 7) return (label: 'Closes in $days days', urgent: days <= 3);
    return (
      label: 'Closes ${DateFormat('d MMM').format(closing)}',
      urgent: false,
    );
  }

  /// "Today", "Yesterday", "3 days ago", "12 Mar 2026".
  static String relativeDay(DateTime date, DateTime now) {
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    return DateFormat('d MMM yyyy').format(date);
  }

  static String shortDate(DateTime date) =>
      DateFormat('d MMM yyyy').format(date);
}
