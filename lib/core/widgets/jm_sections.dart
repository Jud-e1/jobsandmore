import 'package:fl_chart/fl_chart.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_pressable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Eyebrow + title + supporting line, with an optional trailing link.
class JmSectionHeader extends StatelessWidget {
  const new({
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.centered = false,
    this.large = false,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool centered;

  /// Page-level section (H2) instead of a card-level heading (H3).
  final bool large;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final align = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    final text = Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            textAlign: textAlign,
            style: type.overline.copyWith(
              color: jm.isDark ? jm.primary : jm.onPrimarySoft,
            ),
          ),
          const SizedBox(height: JmSpace.x2),
        ],
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: textAlign,
            style: large ? type.h2 : type.h3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: JmSpace.x2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              subtitle!,
              textAlign: textAlign,
              style: (large ? type.bodyL : type.body).copyWith(
                color: jm.textMuted,
              ),
            ),
          ),
        ],
      ],
    );

    if (actionLabel == null || onAction == null || centered) return text;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: text),
        const SizedBox(width: JmSpace.x4),
        JmTextLink(label: actionLabel!, onTap: onAction!),
      ],
    );
  }
}

/// Inline text link with an arrow that nudges on hover.
class JmTextLink extends StatelessWidget {
  const new({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final color = jm.isDark ? jm.primary : jm.onPrimarySoft;
    return JmPressable(
      onTap: onTap,
      isButton: false,
      semanticLabel: label,
      scaleOnPress: false,
      builder: (context, s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.type.label.copyWith(
                color: color,
                decoration: s.hovered ? TextDecoration.underline : null,
                decorationColor: color,
              ),
            ),
            AnimatedPadding(
              duration: JmMotion.micro,
              padding: EdgeInsets.only(left: s.hovered ? 8 : 4),
              child: Icon(PhosphorIconsBold.arrowRight, size: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// KPI tile: label, value, change vs previous period and a sparkline.
class JmStatTile extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    this.icon,
    this.delta,
    this.deltaLabel,
    this.trend,
    this.positiveIsGood = true,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  /// Fractional change, e.g. 0.12 for +12%.
  final double? delta;

  /// e.g. "vs last 30 days".
  final String? deltaLabel;

  /// Series for the sparkline (oldest first).
  final List<double>? trend;

  /// Set false for metrics where going down is good (e.g. time-to-hire).
  final bool positiveIsGood;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final up = (delta ?? 0) >= 0;
    final good = up == positiveIsGood;
    final deltaColor = delta == null || delta == 0
        ? jm.textMuted
        : (good ? jm.success : jm.error);

    return Semantics(
      container: true,
      label:
          '$label: $value'
          '${delta == null ? '' : ', ${up ? 'up' : 'down'} ${(delta!.abs() * 100).round()} percent'}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(JmSpace.x6),
        decoration: BoxDecoration(
          color: jm.surface,
          borderRadius: JmRadius.cardAll,
          border: Border.all(color: jm.border),
          boxShadow: jm.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: jm.primarySoft,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, size: 18, color: jm.onPrimarySoft),
                  ),
                  const SizedBox(width: JmSpace.x3),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: type.small.copyWith(
                      color: jm.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: JmSpace.x4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: type.h2.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (delta != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              up
                                  ? PhosphorIconsBold.trendUp
                                  : PhosphorIconsBold.trendDown,
                              size: 14,
                              color: deltaColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${up ? '+' : '−'}${(delta!.abs() * 100).round()}%',
                              style: type.caption.copyWith(
                                color: deltaColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (deltaLabel != null) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  deltaLabel!,
                                  overflow: TextOverflow.ellipsis,
                                  style: type.caption.copyWith(
                                    color: jm.textSubtle,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (trend != null && trend!.length > 1)
                  SizedBox(
                    width: 96,
                    height: 40,
                    child: JmSparkline(
                      values: trend!,
                      color: good || delta == null ? jm.primary : jm.error,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal line + area sparkline.
class JmSparkline extends StatelessWidget {
  const new({required this.values, required this.color, super.key});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) => LineChart(
    LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      minY: values.reduce((a, b) => a < b ? a : b) * 0.9,
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (var i = 0; i < values.length; i++)
              FlSpot(i.toDouble(), values[i]),
          ],
          isCurved: true,
          curveSmoothness: 0.3,
          color: color,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.25),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    ),
    duration: JmMotion.of(context, JmMotion.page),
  );
}
