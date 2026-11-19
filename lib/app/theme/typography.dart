import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Font loading switch. Tests turn this off so they never touch the network.
abstract final class JmFonts {
  static bool useGoogleFonts = true;

  static TextStyle heading(TextStyle base) => useGoogleFonts
      ? GoogleFonts.inter(textStyle: base)
      : base.copyWith(fontFamily: 'Inter');

  static TextStyle body(TextStyle base) => useGoogleFonts
      ? GoogleFonts.inter(textStyle: base)
      : base.copyWith(fontFamily: 'Inter');
}

/// The JobsAndMore type scale.
///
/// Desktop: Display 56/48, H1 40, H2 32, H3 24, H4 20, Body L 18, Body 16,
/// Small 14, Caption 12. On compact (mobile) layouts headings scale down ~15%;
/// body sizes stay put so reading comfort is unchanged. Flutter applies the
/// user's system text scale on top of these values.
@immutable
class JmTextStyles extends ThemeExtension<JmTextStyles> {
  const new({
    required this.display,
    required this.displaySm,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.bodyL,
    required this.body,
    required this.small,
    required this.caption,
    required this.label,
    required this.overline,
  });

  factory build({required Color color, bool compact = false}) {
    final k = compact ? 0.85 : 1.0;
    TextStyle h(double size, FontWeight w, double lh, double ls) =>
        JmFonts.heading(
          TextStyle(
            fontSize: (size * k).roundToDouble(),
            fontWeight: w,
            height: lh,
            letterSpacing: ls,
            color: color,
          ),
        );
    TextStyle b(double size, FontWeight w, double lh, [double ls = 0]) =>
        JmFonts.body(
          TextStyle(
            fontSize: size,
            fontWeight: w,
            height: lh,
            letterSpacing: ls,
            color: color,
          ),
        );
    return JmTextStyles(
      display: h(72, FontWeight.w700, 1.04, -2.2),
      displaySm: h(56, FontWeight.w700, 1.06, -1.6),
      h1: h(44, FontWeight.w700, 1.1, -1.2),
      h2: h(36, FontWeight.w700, 1.14, -0.9),
      h3: h(24, FontWeight.w700, 1.22, -0.5),
      h4: h(19, FontWeight.w600, 1.3, -0.3),
      bodyL: b(19, FontWeight.w400, 1.5, -0.2),
      body: b(16, FontWeight.w400, 1.5, -0.1),
      small: b(14, FontWeight.w400, 1.5),
      caption: b(12, FontWeight.w500, 1.4, 0.1),
      label: b(14, FontWeight.w600, 1.3, 0.05),
      overline: b(12, FontWeight.w700, 1.3, 1.2),
    );
  }

  final TextStyle display;
  final TextStyle displaySm;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle bodyL;
  final TextStyle body;
  final TextStyle small;
  final TextStyle caption;
  final TextStyle label;

  /// Uppercase eyebrow text above section titles.
  final TextStyle overline;

  /// Maps the scale onto Material's [TextTheme] so stock widgets match.
  TextTheme toTextTheme() => TextTheme(
    displayLarge: display,
    displayMedium: displaySm,
    displaySmall: h1,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: h4,
    titleMedium: body.copyWith(fontWeight: FontWeight.w600),
    titleSmall: label,
    bodyLarge: bodyL,
    bodyMedium: body,
    bodySmall: small,
    labelLarge: label.copyWith(fontSize: 16),
    labelMedium: label,
    labelSmall: caption,
  );

  @override
  JmTextStyles copyWith() => this;

  @override
  JmTextStyles lerp(covariant ThemeExtension<JmTextStyles>? other, double t) {
    if (other is! JmTextStyles) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return JmTextStyles(
      display: l(display, other.display),
      displaySm: l(displaySm, other.displaySm),
      h1: l(h1, other.h1),
      h2: l(h2, other.h2),
      h3: l(h3, other.h3),
      h4: l(h4, other.h4),
      bodyL: l(bodyL, other.bodyL),
      body: l(body, other.body),
      small: l(small, other.small),
      caption: l(caption, other.caption),
      label: l(label, other.label),
      overline: l(overline, other.overline),
    );
  }
}
