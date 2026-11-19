import 'package:flutter/widgets.dart';

import 'package:jobsandmore/app/theme/tokens.dart';

/// Layout classes. mobile < 600 ≤ tablet ≤ 1024 < desktop.
enum JmSize {
  mobile,
  tablet,
  desktop;

  static const double tabletMin = 600;
  static const double desktopMin = 1024;

  static JmSize fromWidth(double width) {
    if (width < tabletMin) return JmSize.mobile;
    if (width <= desktopMin) return JmSize.tablet;
    return JmSize.desktop;
  }

  bool get isMobile => this == JmSize.mobile;
  bool get isTablet => this == JmSize.tablet;
  bool get isDesktop => this == JmSize.desktop;

  /// Horizontal page gutter for this size.
  double get gutter => switch (this) {
    JmSize.mobile => JmSpace.x4,
    JmSize.tablet => JmSpace.x6,
    JmSize.desktop => JmSpace.x8,
  };

  /// Vertical rhythm between page sections.
  double get sectionGap => switch (this) {
    JmSize.mobile => JmSpace.x12,
    JmSize.tablet => JmSpace.x16,
    JmSize.desktop => JmSpace.x24,
  };
}

extension JmResponsiveContext on BuildContext {
  /// Layout class from the *screen* width.
  JmSize get screenSize => JmSize.fromWidth(MediaQuery.sizeOf(this).width);
}

/// Builds with the layout class of the space it is given (not the screen), so
/// components adapt correctly inside panes, dialogs and the dev gallery frame.
class JmResponsive extends StatelessWidget {
  const new({required this.builder, super.key});

  /// Picks one of up to three widgets; missing sizes fall back to the
  /// next-smaller one.
  new of({required Widget mobile, Widget? tablet, Widget? desktop, super.key})
    : builder = ((_, size) => switch (size) {
        JmSize.mobile => mobile,
        JmSize.tablet => tablet ?? mobile,
        JmSize.desktop => desktop ?? tablet ?? mobile,
      });

  final Widget Function(BuildContext context, JmSize size) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => builder(
      context,
      JmSize.fromWidth(
        c.hasBoundedWidth ? c.maxWidth : MediaQuery.sizeOf(context).width,
      ),
    ),
  );
}

/// Centres content at max 1200px with responsive gutters.
class JmContentWidth extends StatelessWidget {
  const new({
    required this.child,
    this.maxWidth = JmSpace.maxContent,
    this.padded = true,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final bool padded;

  @override
  Widget build(BuildContext context) => JmResponsive(
    builder: (context, size) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth + size.gutter * 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padded ? size.gutter : 0),
          child: child,
        ),
      ),
    ),
  );
}

/// A responsive grid: picks a column count from the available width and lays
/// children out in rows with consistent gaps.
class JmAdaptiveGrid extends StatelessWidget {
  const new({
    required this.children,
    this.minItemWidth = 280,
    this.maxColumns = 4,
    this.gap = JmSpace.x6,
    super.key,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double gap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cols = ((c.maxWidth + gap) / (minItemWidth + gap)).floor().clamp(
        1,
        maxColumns,
      );
      final rows = <Widget>[];
      for (var i = 0; i < children.length; i += cols) {
        final row = <Widget>[];
        for (var j = 0; j < cols; j++) {
          if (j > 0) row.add(SizedBox(width: gap));
          final idx = i + j;
          row.add(
            Expanded(
              child: idx < children.length
                  ? children[idx]
                  : const SizedBox.shrink(),
            ),
          );
        }
        if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
        rows.add(
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: row),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      );
    },
  );
}
