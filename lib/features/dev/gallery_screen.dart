import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/app/theme/theme_mode_provider.dart';
import 'package:jobsandmore/core/widgets/widgets.dart';
import 'package:jobsandmore/features/dev/gallery_sections.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// `/dev/gallery`: every design-system component, in light and dark, at
/// phone, tablet and desktop widths. Dev builds only.
class GalleryScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

enum _Frame {
  fit(null, 'Fit', PhosphorIconsRegular.arrowsOutLineHorizontal),
  phone(375, '375', PhosphorIconsRegular.deviceMobile),
  tablet(768, '768', PhosphorIconsRegular.deviceTablet),
  laptop(1280, '1280', PhosphorIconsRegular.laptop),
  wide(1920, '1920', PhosphorIconsRegular.monitor);

  new(this.width, this.label, this.icon);

  final double? width;
  final String label;
  final IconData icon;
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final _scroll = ScrollController();
  final GlobalKey _scrollKey = GlobalKey();
  final Map<String, GlobalKey<State<StatefulWidget>>> _keys = {
    for (final s in gallerySections) s.id: GlobalKey(),
  };
  _Frame _frame = _Frame.fit;
  bool _compare = false;
  String _active = gallerySections.first.id;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_trackActive);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_trackActive)
      ..dispose();
    super.dispose();
  }

  void _trackActive() {
    String? current;
    for (final s in gallerySections) {
      final ctx = _keys[s.id]!.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      if (top < 200) current = s.id;
    }
    if (current != null && current != _active) {
      setState(() => _active = current!);
    }
  }

  void _jumpTo(String id) {
    final ctx = _keys[id]!.currentContext;
    if (ctx == null) return;
    final target = ctx.findRenderObject() as RenderBox?;
    final viewport =
        _scrollKey.currentContext?.findRenderObject() as RenderBox?;
    if (target == null || viewport == null || !_scroll.hasClients) return;
    setState(() => _active = id);
    // Scroll the page directly. Scrollable.ensureVisible stops at the nearest
    // scrollable, which in fixed-width frame mode is the frame's horizontal
    // scroller, so the page would not move.
    final dy = target.localToGlobal(Offset.zero, ancestor: viewport).dy;
    final position = _scroll.position;
    final offset = (_scroll.offset + dy - JmSpace.x4).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    final duration = JmMotion.of(context, JmMotion.page);
    if (duration == Duration.zero) {
      _scroll.jumpTo(offset);
    } else {
      _scroll.animateTo(offset, duration: duration, curve: JmMotion.emphasized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final size = context.screenSize;

    return Scaffold(
      backgroundColor: jm.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Toolbar(
              frame: _frame,
              compare: _compare,
              compact: size.isMobile,
              wide: size.isDesktop,
              onFrame: (f) => setState(() => _frame = f),
              onCompare: (v) => setState(() => _compare = v),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (size.isDesktop) _SideNav(active: _active, onTap: _jumpTo),
                  Expanded(
                    child: Scrollbar(
                      key: const ValueKey('gallery-scroll'),
                      controller: _scroll,
                      child: SingleChildScrollView(
                        key: _scrollKey,
                        controller: _scroll,
                        padding: const EdgeInsets.only(bottom: JmSpace.x24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [const _Hero(), _buildFrames(context)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrames(BuildContext context) {
    if (!_compare && _frame.width == null) {
      return JmContentWidth(child: _GalleryBody(keys: _keys));
    }

    Widget frame(Brightness? brightness, {required bool primary}) {
      return _DeviceFrame(
        width: _frame.width,
        brightness: brightness,
        child: _GalleryBody(keys: primary ? _keys : null),
      );
    }

    if (!_compare) {
      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: JmSpace.x6),
          child: frame(null, primary: true),
        ),
      );
    }

    final pair = [
      frame(Brightness.light, primary: true),
      const SizedBox(width: JmSpace.x6),
      frame(Brightness.dark, primary: false),
    ];
    if (_frame.width == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: JmSpace.x6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: pair[0]),
            pair[1],
            Expanded(child: pair[2]),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: JmSpace.x6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: pair),
    );
  }
}

class _GalleryBody extends StatelessWidget {
  const new({this.keys});

  final Map<String, GlobalKey>? keys;

  @override
  Widget build(BuildContext context) => JmResponsive(
    builder: (context, size) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in gallerySections)
          Padding(
            key: keys?[s.id],
            padding: EdgeInsets.only(top: size.isMobile ? 40 : 64),
            child: GallerySectionView(section: s),
          ),
      ],
    ),
  );
}

/// Renders its child at an exact logical width (and optional brightness),
/// with MediaQuery and the compact type scale set as a real device would.
class _DeviceFrame extends StatelessWidget {
  const new({required this.child, this.width, this.brightness});

  final Widget child;
  final double? width;
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    final outer = context.jm;
    final b = brightness ?? Theme.of(context).brightness;

    return LayoutBuilder(
      builder: (context, c) {
        final w = width ?? c.maxWidth;
        final compact = w < JmSize.tabletMin;
        final theme = b == Brightness.dark
            ? JmTheme.dark(compact: compact)
            : JmTheme.light(compact: compact);
        final mq = MediaQuery.of(context);

        return Column(
          children: [
            const SizedBox(height: JmSpace.x6),
            Text(
              '${w.round()} px · ${b == Brightness.dark ? 'Dark' : 'Light'}'
              ' · ${JmSize.fromWidth(w).name}',
              style: context.type.caption.copyWith(color: outer.textMuted),
            ),
            const SizedBox(height: JmSpace.x3),
            Container(
              width: w,
              decoration: BoxDecoration(
                borderRadius: JmRadius.sheetAll,
                border: Border.all(color: outer.borderStrong),
                boxShadow: outer.shadowLg,
              ),
              clipBehavior: Clip.antiAlias,
              child: MediaQuery(
                data: mq.copyWith(size: Size(w, mq.size.height)),
                child: Theme(
                  data: theme,
                  child: Builder(
                    builder: (context) => Material(
                      color: context.jm.background,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          JmSize.fromWidth(w).gutter,
                          0,
                          JmSize.fromWidth(w).gutter,
                          JmSpace.x12,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return JmResponsive(
      builder: (context, size) => JmMeshBackground(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.isMobile ? JmSpace.x12 : JmSpace.x16,
          ),
          child: JmContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JmBadge.premium(label: 'Design system · Phase 0'),
                const SizedBox(height: JmSpace.x4),
                Text(
                  'The JobsAndMore\ndesign language',
                  style: size.isMobile ? type.h1 : type.display,
                ),
                const SizedBox(height: JmSpace.x4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    'Trustworthy, optimistic and proudly Nigerian. Every token '
                    'and component the product is built from, in one place. '
                    'Switch theme and device width from the toolbar.',
                    style: type.bodyL.copyWith(color: jm.textMuted),
                  ),
                ),
                const SizedBox(height: JmSpace.x8),
                Wrap(
                  spacing: JmSpace.x3,
                  runSpacing: JmSpace.x3,
                  children: [
                    for (final (icon, text) in [
                      (
                        PhosphorIconsRegular.stack,
                        '${gallerySections.length} sections',
                      ),
                      (PhosphorIconsRegular.circleHalf, 'Light + dark'),
                      (PhosphorIconsRegular.devices, '375 → 1920 px'),
                      (
                        PhosphorIconsRegular.personSimpleCircle,
                        'WCAG 2.2 AA targets',
                      ),
                    ])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: jm.glass,
                          borderRadius: JmRadius.pill,
                          border: Border.all(color: jm.glassBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 16, color: jm.primary),
                            const SizedBox(width: 6),
                            Text(text, style: type.label),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const new({
    required this.frame,
    required this.compare,
    required this.compact,
    required this.wide,
    required this.onFrame,
    required this.onCompare,
  });

  final _Frame frame;
  final bool compare;
  final bool compact;
  final bool wide;
  final ValueChanged<_Frame> onFrame;
  final ValueChanged<bool> onCompare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jm = context.jm;
    final mode = ref.watch(themeModeProvider);
    final setMode = ref.read(themeModeProvider.notifier).set;

    final themeToggle = _Segmented<ThemeMode>(
      value: mode,
      onChanged: setMode,
      items: const [
        (ThemeMode.light, PhosphorIconsRegular.sun, 'Light'),
        (ThemeMode.dark, PhosphorIconsRegular.moon, 'Dark'),
        (ThemeMode.system, PhosphorIconsRegular.circleHalf, 'System'),
      ],
    );

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: JmSpace.x4),
      decoration: BoxDecoration(
        color: jm.surface,
        border: Border(bottom: BorderSide(color: jm.border)),
      ),
      child: Row(
        children: [
          JmPressable(
            onTap: () => context.go(Routes.home),
            semanticLabel: 'Home',
            scaleOnPress: false,
            builder: (context, _) => JmLogo(size: 30, showWordmark: !compact),
          ),
          if (wide) ...[
            const SizedBox(width: JmSpace.x3),
            Container(width: 1, height: 24, color: jm.border),
            const SizedBox(width: JmSpace.x3),
            Text(
              'Component gallery',
              style: context.type.label.copyWith(color: jm.textMuted),
            ),
          ],
          const SizedBox(width: JmSpace.x3),
          // Controls scroll sideways instead of overflowing when space is
          // tight (narrow tablets, large accessibility text).
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  if (!compact) ...[
                    _Segmented<_Frame>(
                      value: frame,
                      onChanged: onFrame,
                      showLabels: wide,
                      items: [
                        for (final f in _Frame.values) (f, f.icon, f.label),
                      ],
                    ),
                    const SizedBox(width: JmSpace.x3),
                    JmFilterChip(
                      label: 'Light | Dark',
                      icon: PhosphorIconsRegular.columns,
                      selected: compare,
                      onChanged: onCompare,
                    ),
                    const SizedBox(width: JmSpace.x3),
                  ],
                  themeToggle,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.items,
    this.showLabels = false,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<(T, IconData, String)> items;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: jm.surfaceSunken,
        borderRadius: JmRadius.buttonAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (v, icon, label) in items)
            JmPressable(
              onTap: () => onChanged(v),
              selected: v == value,
              semanticLabel: label,
              tooltip: showLabels ? null : label,
              focusRadius: BorderRadius.circular(9),
              builder: (context, s) {
                final on = v == value;
                return AnimatedContainer(
                  duration: JmMotion.micro,
                  height: 34,
                  padding: EdgeInsets.symmetric(
                    horizontal: showLabels ? 10 : 9,
                  ),
                  decoration: BoxDecoration(
                    color: on ? jm.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: on ? jm.shadowSm : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: on ? jm.text : jm.textMuted),
                      if (showLabels) ...[
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: context.type.caption.copyWith(
                            color: on ? jm.text : jm.textMuted,
                            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const new({required this.active, required this.onTap});

  final String active;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Container(
      width: 232,
      decoration: BoxDecoration(
        color: jm.surface,
        border: Border(right: BorderSide(color: jm.border)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(JmSpace.x3),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Text(
              'FOUNDATIONS & COMPONENTS',
              style: context.type.overline.copyWith(
                color: jm.textSubtle,
                fontSize: 10.5,
              ),
            ),
          ),
          for (final s in gallerySections)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: JmPressable(
                onTap: () => onTap(s.id),
                selected: s.id == active,
                semanticLabel: s.title,
                scaleOnPress: false,
                builder: (context, st) {
                  final on = s.id == active;
                  return AnimatedContainer(
                    duration: JmMotion.micro,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: on
                          ? jm.primarySoft
                          : (st.hovered ? jm.surfaceAlt : Colors.transparent),
                      borderRadius: JmRadius.buttonAll,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          s.icon,
                          size: 18,
                          color: on ? jm.onPrimarySoft : jm.textMuted,
                        ),
                        const SizedBox(width: JmSpace.x3),
                        Expanded(
                          child: Text(
                            s.title,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.label.copyWith(
                              color: on ? jm.onPrimarySoft : jm.text,
                              fontWeight: on
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
