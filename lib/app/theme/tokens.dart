import 'package:material_ui/material_ui.dart';

/// Raw brand colour values. Screens never use these directly: they read the
/// semantic [JmPalette] from the theme (`context.jm`), which differs between
/// light and dark mode.
abstract final class JmBrand {
  // Values from the approved UI design (JobsAndMoreng.com – Web & Mobile).
  static const emerald = Color(0xFF0E6B47); // primary actions
  static const forest = Color(0xFF0A4F34); // hero, dark panels, active text
  static const emeraldLifted = Color(0xFF3FBF8A); // primary on dark surfaces
  static const teal = Color(0xFF1C8F64); // gradient partner
  static const ink = Color(0xFF1D1D1F); // text, dark sections, footer
  static const amber = Color(0xFFF2A93B); // hero CTA, highlights
  static const amberText = Color(0xFFC27C12); // "ng" in the wordmark
  static const amberDeep = Color(0xFF8A5A10); // text on amber-soft
  static const sky = Color(0xFF1F4E99);
  static const success = Color(0xFF0E6B47);
  static const warning = Color(0xFFB54708);
  static const error = Color(0xFFB42318);
  static const alert = Color(0xFFC2410C); // unread dots

  /// Green tonal scale (50–900). 700 is the brand primary.
  static const emeraldScale = <int, Color>{
    50: Color(0xFFE6F1EB),
    100: Color(0xFFCFE5D9),
    200: Color(0xFFB7D8C5),
    300: Color(0xFF86BEA0),
    400: Color(0xFF4F9E77),
    500: Color(0xFF26845A),
    600: Color(0xFF167650),
    700: Color(0xFF0E6B47),
    800: Color(0xFF0A4F34),
    900: Color(0xFF073824),
  };

  /// Ink tonal scale, used for neutrals.
  static const inkScale = <int, Color>{
    50: Color(0xFFF7F9FB),
    100: Color(0xFFEEF1F5),
    200: Color(0xFFE6EAF0),
    300: Color(0xFFCBD2DC),
    400: Color(0xFF98A2B3),
    500: Color(0xFF5B6575),
    600: Color(0xFF3A4556),
    700: Color(0xFF243044),
    800: Color(0xFF162236),
    900: Color(0xFF0F1B2D),
  };
}

/// 4-pt spacing grid.
abstract final class JmSpace {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x12 = 48;
  static const double x16 = 64;
  static const double x24 = 96;

  /// Max content width on desktop.
  static const double maxContent = 1200;

  /// Minimum touch target (44pt per HIG / WCAG 2.5.8).
  static const double minTouch = 44;
}

/// Corner radii.
abstract final class JmRadius {
  static const double input = 12;
  static const double button = 999;
  static const double card = 22;
  static const double sheet = 28;
  static const double full = 999;

  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));
  static const BorderRadius buttonAll = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetAll = BorderRadius.all(Radius.circular(sheet));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(full));
}

/// Semantic colour + depth tokens, attached to [ThemeData] as an extension so
/// light and dark mode are each designed deliberately.
@immutable
class JmPalette extends ThemeExtension<JmPalette> {
  const new({
    required this.brightness,
    required this.primary,
    required this.primaryHover,
    required this.onPrimary,
    required this.primarySoft,
    required this.onPrimarySoft,
    required this.secondary,
    required this.onSecondary,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.info,
    required this.infoSoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.error,
    required this.errorSoft,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.focus,
    required this.scrim,
    required this.glass,
    required this.glassBorder,
    required this.orbA,
    required this.orbB,
    required this.orbC,
    required this.shadowTint,
    required this.shadowStrength,
  });

  final Brightness brightness;

  final Color primary;
  final Color primaryHover;
  final Color onPrimary;
  final Color primarySoft;
  final Color onPrimarySoft;
  final Color secondary;
  final Color onSecondary;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color onAccentSoft;

  final Color info;
  final Color infoSoft;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color error;
  final Color errorSoft;

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceSunken;
  final Color border;
  final Color borderStrong;

  final Color text;
  final Color textMuted;
  final Color textSubtle;

  final Color focus;
  final Color scrim;
  final Color glass;
  final Color glassBorder;
  final Color orbA;
  final Color orbB;
  final Color orbC;
  final Color shadowTint;
  final double shadowStrength;

  bool get isDark => brightness == Brightness.dark;

  /// Signature Emerald â†’ Teal gradient. Use sparingly.
  LinearGradient get signature => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? const [Color(0xFF16A06C), JmBrand.teal]
        : const [JmBrand.emerald, JmBrand.teal],
  );

  /// Resting card shadow: soft, layered, ink-tinted.
  List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: shadowTint.withValues(alpha: 0.04 * shadowStrength),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: shadowTint.withValues(alpha: 0.06 * shadowStrength),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Raised / hover shadow (`0 8 24 rgba(15,27,45,0.08)` plus a contact layer).
  List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: shadowTint.withValues(alpha: 0.05 * shadowStrength),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: shadowTint.withValues(alpha: 0.08 * shadowStrength),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Overlay shadow for sheets, dialogs, menus and hovered cards.
  List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: shadowTint.withValues(alpha: 0.06 * shadowStrength),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: shadowTint.withValues(alpha: 0.14 * shadowStrength),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  /// Coloured glow under the primary CTA.
  List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: primary.withValues(alpha: isDark ? 0.35 : 0.28),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static const light = JmPalette(
    brightness: Brightness.light,
    primary: JmBrand.emerald,
    primaryHover: JmBrand.forest,
    onPrimary: Colors.white,
    primarySoft: Color(0xFFE6F1EB),
    onPrimarySoft: JmBrand.forest,
    secondary: JmBrand.ink,
    onSecondary: Colors.white,
    accent: JmBrand.amber,
    onAccent: JmBrand.ink,
    accentSoft: Color(0xFFFDF1DC),
    onAccentSoft: JmBrand.amberDeep,
    info: JmBrand.sky,
    infoSoft: Color(0xFFE4ECF8),
    success: JmBrand.emerald,
    successSoft: Color(0xFFE6F1EB),
    warning: Color(0xFFB54708),
    warningSoft: Color(0xFFFEF0E1),
    error: JmBrand.error,
    errorSoft: Color(0xFFFDECEC),
    background: Color(0xFFF5F5F7),
    surface: Colors.white,
    surfaceAlt: Color(0xFFF5F5F7),
    surfaceSunken: Color(0xFFEDEDF0),
    border: Color(0xFFE8E8ED),
    borderStrong: Color(0xFFD2D2D7),
    text: JmBrand.ink,
    textMuted: Color(0xFF6A6A6F),
    textSubtle: Color(0xFF6A6A6F),
    focus: JmBrand.sky,
    scrim: Color(0x9913201A),
    glass: Color(0xB3FFFFFF),
    glassBorder: Color(0xCCFFFFFF),
    orbA: Color(0xFF86BEA0),
    orbB: Color(0xFFB7D8C5),
    orbC: Color(0xFFF7D49A),
    shadowTint: JmBrand.ink,
    shadowStrength: 1,
  );

  static const dark = JmPalette(
    brightness: Brightness.dark,
    primary: JmBrand.emeraldLifted,
    primaryHover: Color(0xFF63D3A3),
    onPrimary: Color(0xFF04281A),
    primarySoft: Color(0xFF123526),
    onPrimarySoft: Color(0xFF9FE3C4),
    secondary: Color(0xFFE7ECF3),
    onSecondary: JmBrand.ink,
    accent: Color(0xFFF7B548),
    onAccent: JmBrand.ink,
    accentSoft: Color(0xFF3A2A0E),
    onAccentSoft: Color(0xFFFFD58C),
    info: Color(0xFF6AA8F7),
    infoSoft: Color(0xFF13274A),
    success: Color(0xFF3DD68C),
    successSoft: Color(0xFF0E3326),
    warning: Color(0xFFFDB022),
    warningSoft: Color(0xFF3A2709),
    error: Color(0xFFFF7A7E),
    errorSoft: Color(0xFF3D1518),
    background: Color(0xFF0B1410),
    surface: Color(0xFF121E18),
    surfaceAlt: Color(0xFF17251E),
    surfaceSunken: Color(0xFF0E1813),
    border: Color(0xFF243329),
    borderStrong: Color(0xFF34463B),
    text: Color(0xFFEDF2EE),
    textMuted: Color(0xFFA9B7AE),
    textSubtle: Color(0xFF93A399),
    focus: Color(0xFF6AA8F7),
    scrim: Color(0xB3050A14),
    glass: Color(0x9E121A2B),
    glassBorder: Color(0x33FFFFFF),
    orbA: Color(0xFF0F7A55),
    orbB: Color(0xFF0E6E68),
    orbC: Color(0xFF6B4A12),
    shadowTint: Colors.black,
    shadowStrength: 3,
  );

  @override
  JmPalette copyWith({Color? primary, Color? accent}) => JmPalette(
    brightness: brightness,
    primary: primary ?? this.primary,
    primaryHover: primaryHover,
    onPrimary: onPrimary,
    primarySoft: primarySoft,
    onPrimarySoft: onPrimarySoft,
    secondary: secondary,
    onSecondary: onSecondary,
    accent: accent ?? this.accent,
    onAccent: onAccent,
    accentSoft: accentSoft,
    onAccentSoft: onAccentSoft,
    info: info,
    infoSoft: infoSoft,
    success: success,
    successSoft: successSoft,
    warning: warning,
    warningSoft: warningSoft,
    error: error,
    errorSoft: errorSoft,
    background: background,
    surface: surface,
    surfaceAlt: surfaceAlt,
    surfaceSunken: surfaceSunken,
    border: border,
    borderStrong: borderStrong,
    text: text,
    textMuted: textMuted,
    textSubtle: textSubtle,
    focus: focus,
    scrim: scrim,
    glass: glass,
    glassBorder: glassBorder,
    orbA: orbA,
    orbB: orbB,
    orbC: orbC,
    shadowTint: shadowTint,
    shadowStrength: shadowStrength,
  );

  @override
  JmPalette lerp(covariant ThemeExtension<JmPalette>? other, double t) {
    if (other is! JmPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return JmPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: c(primary, other.primary),
      primaryHover: c(primaryHover, other.primaryHover),
      onPrimary: c(onPrimary, other.onPrimary),
      primarySoft: c(primarySoft, other.primarySoft),
      onPrimarySoft: c(onPrimarySoft, other.onPrimarySoft),
      secondary: c(secondary, other.secondary),
      onSecondary: c(onSecondary, other.onSecondary),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      accentSoft: c(accentSoft, other.accentSoft),
      onAccentSoft: c(onAccentSoft, other.onAccentSoft),
      info: c(info, other.info),
      infoSoft: c(infoSoft, other.infoSoft),
      success: c(success, other.success),
      successSoft: c(successSoft, other.successSoft),
      warning: c(warning, other.warning),
      warningSoft: c(warningSoft, other.warningSoft),
      error: c(error, other.error),
      errorSoft: c(errorSoft, other.errorSoft),
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceAlt: c(surfaceAlt, other.surfaceAlt),
      surfaceSunken: c(surfaceSunken, other.surfaceSunken),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      textSubtle: c(textSubtle, other.textSubtle),
      focus: c(focus, other.focus),
      scrim: c(scrim, other.scrim),
      glass: c(glass, other.glass),
      glassBorder: c(glassBorder, other.glassBorder),
      orbA: c(orbA, other.orbA),
      orbB: c(orbB, other.orbB),
      orbC: c(orbC, other.orbC),
      shadowTint: c(shadowTint, other.shadowTint),
      shadowStrength:
          shadowStrength + (other.shadowStrength - shadowStrength) * t,
    );
  }
}

/// Tone used by badges, toasts, chips and status colours.
enum JmTone { neutral, primary, accent, info, success, warning, error }

extension JmToneColors on JmPalette {
  Color toneFg(JmTone tone) => switch (tone) {
    JmTone.neutral => textMuted,
    JmTone.primary => onPrimarySoft,
    JmTone.accent => onAccentSoft,
    JmTone.info => info,
    JmTone.success => success,
    JmTone.warning => warning,
    JmTone.error => error,
  };

  Color toneBg(JmTone tone) => switch (tone) {
    JmTone.neutral => surfaceSunken,
    JmTone.primary => primarySoft,
    JmTone.accent => accentSoft,
    JmTone.info => infoSoft,
    JmTone.success => successSoft,
    JmTone.warning => warningSoft,
    JmTone.error => errorSoft,
  };
}
