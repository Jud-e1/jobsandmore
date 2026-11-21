import 'dart:ui' as ui;

import 'package:go_router/go_router.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/responsive/breakpoints.dart';
import 'package:jobsandmore/core/widgets/jm_pressable.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

enum NavItem { home, jobs, hire, biz, academy, tools, resources }

enum NavMode { public, seeker, employer, business, admin }

/// Brand logo: the official "Jobs & More ng .com" artwork, with a
/// white-lettered variant on dark backgrounds. Falls back to a text wordmark
/// if the image fails to load.
class DLogo extends StatelessWidget {
  const new({this.onDark = false, this.compact = false, super.key});

  final bool onDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final text = onDark ? Colors.white : context.jm.text;
    final fallback = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onDark
                ? Colors.white.withValues(alpha: 0.12)
                : JmBrand.emerald,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            'J&M',
            style: type.h4.copyWith(color: Colors.white, fontSize: 15),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(
              text: 'JobsAndMore',
              children: [
                TextSpan(
                  text: 'ng',
                  style: TextStyle(
                    color: onDark ? JmBrand.amber : JmBrand.amberText,
                  ),
                ),
              ],
            ),
            style: type.h4.copyWith(fontSize: 20, color: text),
          ),
        ],
      ],
    );
    // Official logo (assets/brand/source/logo_original.jpg). The dark variant
    // has white lettering for dark backgrounds and dark mode.
    final dark = onDark || Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Jobs & More ng',
      excludeSemantics: true,
      child: Image.asset(
        dark ? 'assets/brand/jm_logo_dark.png' : 'assets/brand/jm_logo.png',
        height: compact ? 40 : 52,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

/// Top navigation bar from the design (72px, white, bottom border).
class DTopNav extends StatelessWidget {
  const new({this.active, this.mode = NavMode.public, super.key});

  final NavItem? active;
  final NavMode mode;

  static const items = <(NavItem, String, String)>[
    (NavItem.jobs, 'Find Jobs', Routes.jobs),
    (NavItem.hire, 'Hire Talent', Routes.employer),
    (NavItem.biz, 'Business Hub', Routes.business),
    (NavItem.academy, 'Academy', Routes.academy),
    (NavItem.tools, 'Career Tools', Routes.tools),
    (NavItem.resources, 'Resources', Routes.pricing),
  ];

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    // Frosted, translucent bar (pinned by DPage) so content scrolls softly
    // underneath it.
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: jm.surface.withValues(alpha: 0.78),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: jm.border.withValues(alpha: 0.8)),
              ),
            ),
            child: DContainer(
              maxWidth: 1280,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    JmPressable(
                      onTap: () => context.go(Routes.home),
                      semanticLabel: 'JobsAndMore home',
                      scaleOnPress: false,
                      builder: (_, _) => DLogo(
                        compact: MediaQuery.sizeOf(context).width < 480,
                      ),
                    ),
                    const SizedBox(width: 24),
                    if (wide)
                      // Scrolls rather than overflowing with long translations
                      // or large text sizes.
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final (id, label, route) in items)
                                _NavLink(
                                  label: label,
                                  active: id == active,
                                  onTap: () => context.go(route),
                                ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    if (mode == NavMode.public) ...[
                      if (wide) ...[
                        DBtn(
                          'Sign in',
                          style: DBtnStyle.ghost,
                          height: 44,
                          onTap: () => context.go(Routes.signIn),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (MediaQuery.sizeOf(context).width >= 420)
                        DBtn(
                          'Get started',
                          height: 44,
                          onTap: () => context.go(Routes.getStarted),
                        ),
                    ] else
                      _AccountArea(mode: mode, wide: wide),
                    if (!wide) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Menu',
                        icon: Icon(Icons.menu_rounded, color: jm.text),
                        onPressed: () => _openMenu(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sheet.jm.borderStrong,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (final (id, label, route) in items)
              ListTile(
                title: Text(
                  label,
                  style: sheet.type.label.copyWith(
                    fontSize: 16,
                    color: id == active
                        ? sheet.jm.onPrimarySoft
                        : sheet.jm.text,
                  ),
                ),
                selected: id == active,
                selectedTileColor: sheet.jm.primarySoft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  Navigator.of(sheet).pop();
                  context.go(route);
                },
              ),
            const SizedBox(height: 12),
            if (mode == NavMode.public) ...[
              DBtn(
                'Sign in',
                style: DBtnStyle.secondary,
                expand: true,
                onTap: () {
                  Navigator.of(sheet).pop();
                  context.go(Routes.signIn);
                },
              ),
              const SizedBox(height: 8),
              DBtn(
                'Get started',
                expand: true,
                onTap: () {
                  Navigator.of(sheet).pop();
                  context.go(Routes.getStarted);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const new({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: JmPressable(
        onTap: onTap,
        selected: active,
        semanticLabel: label,
        scaleOnPress: false,
        focusRadius: BorderRadius.circular(8),
        builder: (context, s) => AnimatedContainer(
          duration: JmMotion.micro,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? jm.primarySoft : (s.hovered ? jm.surfaceAlt : null),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: context.type.label.copyWith(
              fontSize: 15,
              color: active ? jm.onPrimarySoft : jm.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountArea extends StatelessWidget {
  const new({required this.mode, required this.wide});

  final NavMode mode;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final (ini, who, home) = switch (mode) {
      NavMode.employer => ('KL', 'Kobo Logistics', Routes.employer),
      NavMode.business => ('TB', 'Tola’s Bakery', Routes.businessDashboard),
      NavMode.admin => ('VO', 'Verification desk', Routes.admin),
      _ => ('AO', 'Amaka O.', Routes.dashboard),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Notifications, 3 unread',
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => context.go(Routes.inbox),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, color: jm.text),
                  Positioned(
                    top: 9,
                    right: 10,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: JmBrand.alert,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        JmPressable(
          onTap: () => context.go(home),
          semanticLabel: 'Account: $who',
          focusRadius: BorderRadius.circular(999),
          builder: (context, s) => Container(
            padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: jm.border),
              color: s.hovered ? jm.surfaceAlt : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DInitials(
                  ini,
                  size: 34,
                  circle: true,
                  bg: jm.accentSoft,
                  fg: jm.onAccentSoft,
                ),
                if (wide) ...[
                  const SizedBox(width: 10),
                  Text(who, style: context.type.label),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Site footer (dark ink).
class DFooter extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    Widget col(String title, List<(String, String)> links) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: type.label.copyWith(
            color: context.jm.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        for (final (label, route) in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => context.go(route),
              child: Text(
                label,
                style: type.small.copyWith(
                  color: context.jm.textMuted,
                  decoration: TextDecoration.none,
                  decorationColor: context.jm.textMuted,
                ),
              ),
            ),
          ),
      ],
    );
    return ColoredBox(
      color: context.jm.background,
      child: Column(
        children: [
          DContainer(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
            child: DGrid(
              minItemWidth: 180,
              gap: 32,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DLogo(),
                    const SizedBox(height: 10),
                    Text(
                      'Employment, learning and business support for Nigeria.',
                      style: type.small.copyWith(
                        color: context.jm.textMuted,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
                col('Job Seekers', [
                  ('Find jobs', Routes.jobs),
                  ('Career tools', Routes.tools),
                  ('Academy', Routes.academy),
                ]),
                col('Employers & Business', [
                  ('Post a vacancy', Routes.postVacancy),
                  ('Plans', Routes.pricing),
                  ('Business Hub', Routes.business),
                ]),
                col('Company', [
                  ('About & contact', Routes.home),
                  ('Help centre', Routes.home),
                  ('Privacy · Terms · Accessibility', Routes.home),
                ]),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.jm.border)),
            ),
            child: DContainer(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '© ${DateTime.now().year} JobsAndMoreng.com',
                  style: type.caption.copyWith(
                    color: context.jm.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum MobileTab { home, jobs, applications, learn, profile }

/// Mobile bottom tab bar (Home, Jobs, Applications, Learn, Profile).
class DMobileTabs extends StatelessWidget {
  const new({required this.current, super.key});

  final MobileTab current;

  static const tabs = <(MobileTab, String, IconData, String)>[
    (MobileTab.home, 'Home', Icons.home_outlined, Routes.dashboard),
    (MobileTab.jobs, 'Jobs', Icons.search_rounded, Routes.jobs),
    (
      MobileTab.applications,
      'Applications',
      Icons.assignment_outlined,
      Routes.applications,
    ),
    (MobileTab.learn, 'Learn', Icons.school_outlined, Routes.myCourses),
    (
      MobileTab.profile,
      'Profile',
      Icons.person_outline_rounded,
      Routes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: current.index,
    height: 68,
    backgroundColor: context.jm.surface,
    indicatorColor: context.jm.primarySoft,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    onDestinationSelected: (i) => context.go(tabs[i].$4),
    destinations: [
      for (final (_, label, icon, _) in tabs)
        NavigationDestination(icon: Icon(icon), label: label),
    ],
  );
}

/// Page scaffold for every design screen.
///
/// * Wide screens: top nav + scrolling body (+ footer on public pages).
/// * Phones (< 700px) on app pages: a compact app bar and the bottom tabs,
///   matching the mobile designs.
class DPage extends StatelessWidget {
  const new({
    required this.body,
    this.active,
    this.mode = NavMode.public,
    this.footer = false,
    this.mobileTab,
    this.mobileTitle,
    this.mobileBody,
    this.mobileActions,
    this.bottomBar,
    this.background,
    this.scroll = true,
    super.key,
  });

  final Widget body;
  final NavItem? active;
  final NavMode mode;
  final bool footer;

  /// When set, phones get the bottom tab bar with this tab selected.
  final MobileTab? mobileTab;
  final String? mobileTitle;

  /// Optional phone-specific layout (from the mobile designs).
  final Widget? mobileBody;
  final List<Widget>? mobileActions;

  /// Sticky bottom action bar (apply flow, job detail).
  final Widget? bottomBar;
  final Color? background;
  final bool scroll;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 700;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final phone = isPhone(context);
    final bg = background ?? jm.background;

    if (phone &&
        (mobileTab != null || mobileBody != null || mobileTitle != null)) {
      final content = mobileBody ?? body;
      return Scaffold(
        backgroundColor: bg,
        appBar: mobileTitle == null
            ? null
            : AppBar(
                title: Text(mobileTitle!),
                backgroundColor: jm.surface,
                actions: mobileActions,
              ),
        body: SafeArea(
          top: mobileTitle == null,
          bottom: false,
          child: scroll
              ? SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: content,
                )
              : content,
        ),
        bottomNavigationBar:
            bottomBar ??
            (mobileTab == null ? null : DMobileTabs(current: mobileTab!)),
      );
    }

    final nav = DTopNav(active: active, mode: mode);
    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        bottom: false,
        child: scroll
            ? CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PinnedNav(nav),
                  ),
                  SliverToBoxAdapter(child: body),
                  if (footer) const SliverToBoxAdapter(child: DFooter()),
                ],
              )
            : Column(
                children: [
                  nav,
                  Expanded(child: body),
                ],
              ),
      ),
    );
  }
}

/// Simple header used by the onboarding screens (logo + step text).
class DSlimHeader extends StatelessWidget {
  const new({this.trailing, super.key});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.jm.surface,
      border: Border(bottom: BorderSide(color: context.jm.border)),
    ),
    child: DContainer(
      maxWidth: 1100,
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            JmPressable(
              onTap: () => context.go(Routes.home),
              semanticLabel: 'JobsAndMore home',
              scaleOnPress: false,
              builder: (_, _) => DLogo(compact: context.screenSize.isMobile),
            ),
            const Spacer(),
            if (trailing != null) Flexible(child: trailing!),
          ],
        ),
      ),
    ),
  );
}

/// Keeps the top nav pinned while the page scrolls under it.
class _PinnedNav extends SliverPersistentHeaderDelegate {
  new(this.child);

  final Widget child;

  @override
  double get minExtent => 65;

  @override
  double get maxExtent => 65;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(_PinnedNav old) => old.child != child;
}
