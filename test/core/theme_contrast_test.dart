import 'package:flutter_test/flutter_test.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Every text/background pair the components use must meet WCAG 2.2 AA
/// (4.5:1 for body text).
void main() {
  for (final (name, p) in [
    ('light', JmPalette.light),
    ('dark', JmPalette.dark),
  ]) {
    group('$name palette meets AA', () {
      final pairs = <String, (Color, Color)>{
        'text on background': (p.text, p.background),
        'text on surface': (p.text, p.surface),
        'muted on background': (p.textMuted, p.background),
        'muted on surface': (p.textMuted, p.surface),
        'subtle on background': (p.textSubtle, p.background),
        'subtle on surface': (p.textSubtle, p.surface),
        'onPrimary on primary': (p.onPrimary, p.primary),
        'onAccent on accent': (p.onAccent, p.accent),
        'onPrimarySoft on primarySoft': (p.onPrimarySoft, p.primarySoft),
        'onAccentSoft on accentSoft': (p.onAccentSoft, p.accentSoft),
        'info on infoSoft': (p.info, p.infoSoft),
        'success on successSoft': (p.success, p.successSoft),
        'warning on warningSoft': (p.warning, p.warningSoft),
        'error on errorSoft': (p.error, p.errorSoft),
        'muted on sunken (neutral badge)': (p.textMuted, p.surfaceSunken),
      };
      for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
        test(label, () {
          final ratio = contrast(fg, bg);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$label is ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    });
  }
}
