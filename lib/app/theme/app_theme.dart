import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:jobsandmore/app/theme/motion.dart';
import 'package:jobsandmore/app/theme/tokens.dart';
import 'package:jobsandmore/app/theme/typography.dart';
import 'package:material_ui/material_ui.dart';

export 'package:jobsandmore/app/theme/motion.dart';
export 'package:jobsandmore/app/theme/tokens.dart';
export 'package:jobsandmore/app/theme/typography.dart';

/// Builds the Material 3 [ThemeData] for each brightness from the tokens.
abstract final class JmTheme {
  static ThemeData light({bool compact = false}) =>
      _build(JmPalette.light, compact: compact);

  static ThemeData dark({bool compact = false}) =>
      _build(JmPalette.dark, compact: compact);

  static ThemeData _build(JmPalette p, {required bool compact}) {
    final type = JmTextStyles.build(color: p.text, compact: compact);
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primarySoft,
      onPrimaryContainer: p.onPrimarySoft,
      secondary: p.secondary,
      onSecondary: p.onSecondary,
      tertiary: p.accent,
      onTertiary: p.onAccent,
      tertiaryContainer: p.accentSoft,
      onTertiaryContainer: p.onAccentSoft,
      error: p.error,
      onError: p.isDark ? JmBrand.ink : Colors.white,
      errorContainer: p.errorSoft,
      onErrorContainer: p.error,
      surface: p.surface,
      onSurface: p.text,
      onSurfaceVariant: p.textMuted,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.background,
      surfaceContainer: p.surfaceAlt,
      surfaceContainerHigh: p.surfaceAlt,
      surfaceContainerHighest: p.surfaceSunken,
      outline: p.borderStrong,
      outlineVariant: p.border,
      shadow: p.shadowTint,
      scrim: p.scrim,
      inverseSurface: p.isDark ? const Color(0xFFEDF1F7) : JmBrand.ink,
      onInverseSurface: p.isDark ? JmBrand.ink : Colors.white,
      inversePrimary: p.isDark ? JmBrand.emerald : JmBrand.emeraldLifted,
      surfaceTint: Colors.transparent,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: JmRadius.inputAll,
      borderSide: BorderSide(color: p.borderStrong),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: type.toTextTheme(),
      extensions: [p, type],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      focusColor: p.focus.withValues(alpha: 0.16),
      hoverColor: p.text.withValues(alpha: 0.04),
      highlightColor: Colors.transparent,
      iconTheme: IconThemeData(color: p.textMuted, size: 20),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: type.h4,
        shape: Border(bottom: BorderSide(color: p.border)),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: JmRadius.cardAll,
          side: BorderSide(color: p.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.isDark ? p.surfaceSunken : p.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: JmSpace.x4,
          vertical: 14,
        ),
        hintStyle: type.body.copyWith(color: p.textSubtle),
        helperStyle: type.small.copyWith(color: p.textMuted),
        errorStyle: type.small.copyWith(color: p.error),
        prefixIconColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.focused) ? p.primary : p.textSubtle,
        ),
        suffixIconColor: p.textSubtle,
        border: inputBorder,
        enabledBorder: inputBorder,
        hoverColor: Colors.transparent,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: p.primary, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: p.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: p.error, width: 2),
        ),
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: p.border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(JmSpace.x4),
        contentTextStyle: type.label,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        modalBackgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(JmRadius.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: JmRadius.sheetAll),
        titleTextStyle: type.h4,
        contentTextStyle: type.body.copyWith(color: p.textMuted),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.isDark ? const Color(0xFFEDF1F7) : JmBrand.ink,
          borderRadius: JmRadius.inputAll,
        ),
        textStyle: type.caption.copyWith(
          color: p.isDark ? JmBrand.ink : Colors.white,
        ),
        waitDuration: const Duration(milliseconds: 400),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primarySoft,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => type.caption.copyWith(
            color: s.contains(WidgetState.selected) ? p.text : p.textMuted,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 22,
            color: s.contains(WidgetState.selected)
                ? p.onPrimarySoft
                : p.textMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.primarySoft,
        selectedIconTheme: IconThemeData(color: p.onPrimarySoft, size: 22),
        unselectedIconTheme: IconThemeData(color: p.textMuted, size: 22),
        selectedLabelTextStyle: type.caption.copyWith(
          color: p.text,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: type.caption.copyWith(color: p.textMuted),
      ),
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(JmRadius.full),
        thickness: WidgetStateProperty.all(6),
        thumbColor: WidgetStateProperty.all(
          p.textSubtle.withValues(alpha: 0.4),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.surfaceSunken,
        circularTrackColor: p.surfaceSunken,
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : p.surfaceSunken,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onPrimary : p.textSubtle,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.transparent
              : p.borderStrong,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: p.borderStrong, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : null,
        ),
        checkColor: WidgetStateProperty.all(p.onPrimary),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: p.brightness,
        primaryColor: p.primary,
      ),
    );
  }
}

/// Shorthand access to the design tokens from any widget.
extension JmThemeContext on BuildContext {
  JmPalette get jm => Theme.of(this).extension<JmPalette>()!;
  JmTextStyles get type => Theme.of(this).extension<JmTextStyles>()!;
  bool get reduceMotion => JmMotion.reduced(this);
}
