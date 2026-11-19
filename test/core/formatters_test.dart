import 'package:flutter_test/flutter_test.dart';
import 'package:jobsandmore/core/utils/formatters.dart';

void main() {
  group('JmFormat.salaryRange', () {
    test('hidden when not disclosed', () {
      expect(JmFormat.salaryRange(100000, 200000, disclosed: false), isNull);
    });

    test('formats ranges and single values in Naira', () {
      expect(
        JmFormat.salaryRange(350000, 500000, disclosed: true),
        '₦350k – ₦500k / month',
      );
      expect(
        JmFormat.salaryRange(1200000, null, disclosed: true),
        '₦1.2m / month',
      );
    });
  });

  group('JmFormat.closingIn', () {
    final now = DateTime(2026, 11, 17, 15);

    test('labels deadlines and urgency', () {
      expect(JmFormat.closingIn(DateTime(2026, 11, 16), now).label, 'Closed');
      expect(JmFormat.closingIn(DateTime(2026, 11, 17), now).urgent, isTrue);
      expect(
        JmFormat.closingIn(DateTime(2026, 11, 18), now).label,
        'Closes tomorrow',
      );
      final five = JmFormat.closingIn(DateTime(2026, 11, 22), now);
      expect(five.label, 'Closes in 5 days');
      expect(five.urgent, isFalse);
      expect(
        JmFormat.closingIn(DateTime(2026, 12, 12), now).label,
        'Closes 12 Dec',
      );
    });
  });
}
