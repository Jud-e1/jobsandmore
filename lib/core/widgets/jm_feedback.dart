import 'dart:math' as math;

import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

/// Illustration motifs for empty states. Each is drawn in code with brand
/// colours, so empty states never reuse the same stock image.
enum JmIllustration { search, saved, inbox, applications, learning, offline }

/// Illustrated empty state: art + title + message + optional action.
class JmEmptyState extends StatelessWidget {
  const new({
    required this.title,
    required this.message,
    this.illustration = JmIllustration.search,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final String title;
  final String message;
  final JmIllustration illustration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(JmSpace.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: JmIllustrationArt(
                  motif: illustration,
                  size: compact ? 120 : 168,
                ),
              ),
              const SizedBox(height: JmSpace.x6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: compact ? type.h4 : type.h3,
              ),
              const SizedBox(height: JmSpace.x2),
              Text(
                message,
                textAlign: TextAlign.center,
                style: type.body.copyWith(color: jm.textMuted),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: JmSpace.x6),
                JmButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state with a retry action. Messages should say what happened and
/// what the user can do, without technical jargon.
class JmErrorState extends StatelessWidget {
  const new({
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
    this.offline = false,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(JmSpace.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (offline)
                const ExcludeSemantics(
                  child: JmIllustrationArt(
                    motif: JmIllustration.offline,
                    size: 140,
                  ),
                )
              else
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: jm.errorSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsBold.warningCircle,
                    color: jm.error,
                    size: 30,
                  ),
                ),
              const SizedBox(height: JmSpace.x6),
              Text(title, textAlign: TextAlign.center, style: type.h4),
              const SizedBox(height: JmSpace.x2),
              Text(
                message,
                textAlign: TextAlign.center,
                style: type.body.copyWith(color: jm.textMuted),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: JmSpace.x6),
                JmButton.secondary(
                  label: 'Try again',
                  leading: PhosphorIconsBold.arrowClockwise,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Code-drawn spot illustration: a soft disc, floating "cards" and a motif
/// icon, with an amber accent. Distinct per motif.
class JmIllustrationArt extends StatelessWidget {
  const new({required this.motif, this.size = 160, super.key});

  final JmIllustration motif;
  final double size;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final icon = switch (motif) {
      JmIllustration.search => PhosphorIconsFill.magnifyingGlass,
      JmIllustration.saved => PhosphorIconsFill.heart,
      JmIllustration.inbox => PhosphorIconsFill.tray,
      JmIllustration.applications => PhosphorIconsFill.paperPlaneTilt,
      JmIllustration.learning => PhosphorIconsFill.graduationCap,
      JmIllustration.offline => PhosphorIconsFill.wifiSlash,
    };
    final tilt = switch (motif) {
      JmIllustration.search => -0.12,
      JmIllustration.saved => 0.1,
      JmIllustration.inbox => -0.06,
      JmIllustration.applications => 0.14,
      JmIllustration.learning => -0.1,
      JmIllustration.offline => 0.06,
    };
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [jm.primarySoft, jm.primarySoft.withValues(alpha: 0)],
              ),
            ),
          ),
          Transform.rotate(
            angle: tilt,
            child: Container(
              width: size * 0.52,
              height: size * 0.62,
              decoration: BoxDecoration(
                color: jm.surface,
                borderRadius: BorderRadius.circular(size * 0.08),
                border: Border.all(color: jm.border),
                boxShadow: jm.shadowMd,
              ),
              padding: EdgeInsets.all(size * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final w in [0.7, 1.0, 0.85, 0.5]) ...[
                    FractionallySizedBox(
                      widthFactor: w,
                      child: Container(
                        height: size * 0.035,
                        decoration: BoxDecoration(
                          color: jm.surfaceSunken,
                          borderRadius: JmRadius.pill,
                        ),
                      ),
                    ),
                    SizedBox(height: size * 0.045),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            right: size * 0.12,
            bottom: size * 0.14,
            child: Container(
              width: size * 0.34,
              height: size * 0.34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: jm.signature,
                boxShadow: jm.shadowPrimary,
              ),
              child: Icon(icon, color: Colors.white, size: size * 0.18),
            ),
          ),
          Positioned(
            left: size * 0.14,
            top: size * 0.16,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: size * 0.07,
                height: size * 0.07,
                decoration: BoxDecoration(
                  color: jm.accent,
                  borderRadius: BorderRadius.circular(size * 0.015),
                ),
              ),
            ),
          ),
          Positioned(
            right: size * 0.2,
            top: size * 0.1,
            child: Container(
              width: size * 0.045,
              height: size * 0.045,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: jm.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton blocks. Compose them to mirror the real layout.
class JmSkeleton extends StatelessWidget {
  const new({
    this.width,
    this.height = 14,
    this.radius = JmRadius.input,
    this.circle = false,
    super.key,
  });

  const new circle({required double size, super.key})
    : width = size,
      height = size,
      radius = 0,
      circle = true;

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: context.jm.surfaceSunken,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(radius),
    ),
  );
}

/// Applies the shimmer sweep to any skeleton subtree (static under
/// reduce-motion) and hides it from screen readers behind one label.
class JmShimmer extends StatelessWidget {
  const new({required this.child, this.label = 'Loading', super.key});

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Semantics(
      label: label,
      liveRegion: true,
      excludeSemantics: true,
      child: context.reduceMotion
          ? child
          : Shimmer.fromColors(
              baseColor: jm.surfaceSunken,
              highlightColor: jm.isDark ? jm.surfaceAlt : jm.surface,
              period: const Duration(milliseconds: 1400),
              child: child,
            ),
    );
  }
}

/// Skeleton that matches the `JmJobCard` layout.
class JmJobCardSkeleton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Container(
      padding: const EdgeInsets.all(JmSpace.x6),
      decoration: BoxDecoration(
        color: jm.surface,
        borderRadius: JmRadius.cardAll,
        border: Border.all(color: jm.border),
      ),
      child: const JmShimmer(
        label: 'Loading job',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                JmSkeleton(width: 48, height: 48, radius: 12),
                SizedBox(width: JmSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JmSkeleton(width: 220, height: 18),
                      SizedBox(height: JmSpace.x2),
                      JmSkeleton(width: 140),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: JmSpace.x6),
            Row(
              children: [
                JmSkeleton(width: 90),
                SizedBox(width: JmSpace.x4),
                JmSkeleton(width: 70),
                SizedBox(width: JmSpace.x4),
                JmSkeleton(width: 60),
              ],
            ),
            SizedBox(height: JmSpace.x6),
            JmSkeleton(width: 160, height: 16),
          ],
        ),
      ),
    );
  }
}

/// Branded modal bottom sheet with drag handle, title and safe-area padding.
Future<T?> showJmBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  bool scrollable = true,
}) {
  final jm = context.jm;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollable,
    useSafeArea: true,
    barrierColor: jm.scrim,
    sheetAnimationStyle: AnimationStyle(
      duration: JmMotion.of(context, JmMotion.page),
      curve: JmMotion.emphasized,
      reverseDuration: JmMotion.of(context, JmMotion.standard),
    ),
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (context) {
      final type = context.type;
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: JmSpace.x3),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.jm.borderStrong,
                  borderRadius: JmRadius.pill,
                ),
              ),
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  JmSpace.x6,
                  JmSpace.x4,
                  JmSpace.x3,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title, style: type.h4),
                      ),
                    ),
                    JmIconButton(
                      icon: PhosphorIconsBold.x,
                      label: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  JmSpace.x6,
                  JmSpace.x4,
                  JmSpace.x6,
                  JmSpace.x6,
                ),
                child: builder(context),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Branded dialog. Returns true when the primary action is chosen.
Future<bool?> showJmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
  IconData? icon,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: context.jm.scrim,
    transitionDuration: JmMotion.of(context, JmMotion.standard),
    transitionBuilder: (context, a, _, child) {
      final curved = CurvedAnimation(parent: a, curve: JmMotion.emphasized);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (context, _, _) {
      final jm = context.jm;
      final type = context.type;
      final tone = destructive ? JmTone.error : JmTone.primary;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(JmSpace.x6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Material(
              color: jm.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: JmRadius.sheetAll,
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(JmSpace.x6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: jm.toneBg(tone),
                          borderRadius: JmRadius.buttonAll,
                        ),
                        child: Icon(icon, color: jm.toneFg(tone), size: 24),
                      ),
                      const SizedBox(height: JmSpace.x4),
                    ],
                    Semantics(header: true, child: Text(title, style: type.h4)),
                    const SizedBox(height: JmSpace.x2),
                    Text(
                      message,
                      style: type.body.copyWith(color: jm.textMuted),
                    ),
                    const SizedBox(height: JmSpace.x6),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: JmSpace.x3,
                      runSpacing: JmSpace.x3,
                      children: [
                        JmButton.secondary(
                          label: cancelLabel,
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        JmButton(
                          label: confirmLabel,
                          variant: destructive
                              ? JmButtonVariant.destructive
                              : JmButtonVariant.primary,
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Floating toast built on SnackBar (so screen readers announce it).
void showJmToast(
  BuildContext context,
  String message, {
  JmTone tone = JmTone.neutral,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final jm = context.jm;
  final type = context.type;
  final width = MediaQuery.sizeOf(context).width;
  final icon = switch (tone) {
    JmTone.success => PhosphorIconsFill.checkCircle,
    JmTone.error => PhosphorIconsFill.warningCircle,
    JmTone.warning => PhosphorIconsFill.warning,
    JmTone.info => PhosphorIconsFill.info,
    _ => PhosphorIconsFill.bell,
  };
  final iconColor = switch (tone) {
    JmTone.success => jm.isDark ? jm.success : const Color(0xFF3DD68C),
    JmTone.error => const Color(0xFFFF8A8E),
    JmTone.warning => const Color(0xFFFDB022),
    JmTone.info => const Color(0xFF8DBDFA),
    _ => jm.isDark ? jm.textMuted : const Color(0xFFA3AEC0),
  };
  final bg = jm.isDark ? jm.surfaceAlt : JmBrand.ink;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        width: width > 600 ? 420 : null,
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: JmSpace.x4,
            vertical: JmSpace.x3,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: JmRadius.buttonAll,
            border: jm.isDark ? Border.all(color: jm.borderStrong) : null,
            boxShadow: jm.shadowLg,
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: JmSpace.x3),
              Expanded(
                child: Text(
                  message,
                  style: type.label.copyWith(
                    color: jm.isDark ? jm.text : Colors.white,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onAction();
                  },
                  child: Text(
                    actionLabel,
                    style: type.label.copyWith(
                      color: jm.isDark ? jm.primary : JmBrand.emeraldLifted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
}
