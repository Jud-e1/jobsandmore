import 'package:flutter_animate/flutter_animate.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/responsive/breakpoints.dart';
import 'package:jobsandmore/features/demo/demo_data.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

/// 01 Home – public landing page.
class HomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => DPage(
    active: NavItem.home,
    footer: true,
    background: context.jm.surface,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Hero(),
        const _TrustStrip(),
        const _Categories(),
        const _Stories(),
        const _Bento(),
        const _HowItWorks(),
        const _Featured(),
        const _Tools(),
        const _Academy(),
        const _AppPromo(),
        const _Faq(),
      ].animateList(context),
    ),
  );
}

extension on List<Widget> {
  /// Gentle staggered entrance; skipped under reduce-motion.
  List<Widget> animateList(BuildContext context) {
    if (context.reduceMotion) return this;
    return [
      for (var i = 0; i < length; i++)
        this[i]
            .animate(delay: JmMotion.stagger * i)
            .fadeIn(duration: JmMotion.page, curve: JmMotion.ease)
            .slideY(
              begin: 0.03,
              end: 0,
              duration: JmMotion.page,
              curve: JmMotion.ease,
            ),
    ];
  }
}

/// Section with Apple-like generous vertical rhythm.
class _Section extends StatelessWidget {
  const new({required this.child, this.top = 96, this.bottom = 0});

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final phone = context.screenSize.isMobile;
    return ColoredBox(
      color: Colors.transparent,
      child: DContainer(
        padding: EdgeInsets.fromLTRB(
          phone ? 20 : 24,
          phone ? top * 0.6 : top,
          phone ? 20 : 24,
          phone ? bottom * 0.6 : bottom,
        ),
        child: child,
      ),
    );
  }
}

/// Centered Apple-style headline block.
class _Headline extends StatelessWidget {
  const new(this.title, {this.eyebrow, this.subtitle, this.center = true});

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final phone = context.screenSize.isMobile;
    final align = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            textAlign: align,
            style: type.label.copyWith(
              color: context.jm.primary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Semantics(
          header: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Text(
              title,
              textAlign: align,
              style: type.h1.copyWith(
                fontSize: phone ? 34 : 52,
                letterSpacing: phone ? -0.8 : -1.6,
              ),
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              subtitle!,
              textAlign: align,
              style: type.bodyL.copyWith(
                color: context.jm.textMuted,
                fontSize: phone ? 17 : 21,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------------ hero --

class _Hero extends StatefulWidget {
  const new();

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  final _q = TextEditingController();
  String _loc = 'All of Nigeria';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final phone = context.screenSize.isMobile;

    final search = LayoutBuilder(
      // Fully round when on one line; softer corners when stacked.
      builder: (context, outer) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: jm.surface,
          borderRadius: BorderRadius.circular(outer.maxWidth < 572 ? 22 : 999),
          border: Border.all(color: jm.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final keyword = TextField(
              controller: _q,
              onSubmitted: (_) => context.to(Routes.jobs),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Job title, skill or company',
                prefixIcon: Icon(Icons.search_rounded, color: jm.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            );
            final location = DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _loc,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: jm.textMuted,
                ),
                style: type.body.copyWith(color: jm.text),
                items: [
                  for (final l in [
                    'All of Nigeria',
                    'Lagos',
                    'Abuja (FCT)',
                    'Port Harcourt',
                    'Kano',
                    'Ibadan',
                    'Enugu',
                    'Remote',
                  ])
                    DropdownMenuItem(
                      value: l,
                      child: Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: jm.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(l, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _loc = v ?? _loc),
              ),
            );
            final go = DBtn(
              'Search',
              height: 50,
              onTap: () => context.to(Routes.jobs),
            );
            if (c.maxWidth < 560) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  keyword,
                  Divider(height: 1, color: jm.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: location,
                  ),
                  const SizedBox(height: 6),
                  DBtn(
                    'Search jobs',
                    height: 50,
                    expand: true,
                    onTap: () => context.to(Routes.jobs),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(flex: 3, child: keyword),
                Container(width: 1, height: 28, color: jm.border),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: location),
                const SizedBox(width: 6),
                go,
              ],
            );
          },
        ),
      ),
    );

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DPill(
          'New · AI CV check is free this month',
          bg: jm.primarySoft,
          fg: jm.onPrimarySoft,
          fontSize: 13,
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            'Work that moves\nNigeria forward.',
            style: type.display.copyWith(
              fontSize: phone ? 42 : 68,
              letterSpacing: phone ? -1.2 : -2.4,
              height: 1.02,
            ),
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Find verified jobs, hire great people and grow your business – with AI career tools you stay in control of.',
            style: type.bodyL.copyWith(
              color: jm.textMuted,
              fontSize: phone ? 17 : 21,
            ),
          ),
        ),
        const SizedBox(height: 28),
        search,
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Popular:', style: type.small.copyWith(color: jm.textMuted)),
            for (final p in [
              'Data analyst',
              'Accountant',
              'Nurse',
              'Remote',
              'Graduate trainee',
            ])
              ActionChip(
                label: Text(p),
                onPressed: () => context.to(Routes.jobs),
                shape: const StadiumBorder(),
                side: BorderSide(color: jm.border),
                backgroundColor: jm.surface,
                labelStyle: type.small.copyWith(color: jm.text),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            DBtn(
              'Hire talent',
              style: DBtnStyle.dark,
              onTap: () => context.to(Routes.employer),
            ),
            DBtn(
              'Grow your business',
              style: DBtnStyle.secondary,
              onTap: () => context.to(Routes.business),
            ),
          ],
        ),
      ],
    );

    final right = SizedBox(
      height: phone ? 340 : 560,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: DPhoto(
              DImages.heroOffice,
              radius: 32,
              alignment: Alignment(0.35, 0),
              semanticLabel: 'A young professional working on a laptop in a bright Lagos office',
            ),
          ),
          Positioned(
            left: phone ? 12 : -28,
            bottom: phone ? 12 : 40,
            child: DGlassCard(
              width: phone ? 250 : 290,
              child: Row(
                children: [
                  DInitials(
                    'KL',
                    size: 42,
                    bg: jm.accentSoft,
                    fg: jm.onAccentSoft,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operations Analyst',
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Kobo Logistics · Lagos',
                          style: type.caption.copyWith(color: jm.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const DPill('82%'),
                ],
              ),
            ),
          ),
          if (!phone)
            Positioned(
              right: -20,
              top: 48,
              child: DGlassCard(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: jm.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Verified employer',
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '3 checks passed',
                          style: type.caption.copyWith(color: jm.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (!phone)
            Positioned(
              right: 36,
              bottom: -26,
              child: DGlassCard(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DRing(74, size: 44, stroke: 4),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CV check (estimate)',
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '3 quick fixes found',
                          style: type.caption.copyWith(color: jm.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    return ColoredBox(
      color: jm.surface,
      child: DContainer(
        padding: EdgeInsets.fromLTRB(
          phone ? 20 : 24,
          phone ? 32 : 72,
          phone ? 20 : 24,
          phone ? 40 : 88,
        ),
        child: DSplit(
          main: left,
          aside: right,
          asideWidth: 520,
          gap: 64,
          breakpoint: 1000,
        ),
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    Widget item(IconData icon, String title, String body) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: jm.primary, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: type.label.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(body, style: type.small.copyWith(color: jm.textMuted)),
            ],
          ),
        ),
      ],
    );
    return ColoredBox(
      color: jm.background,
      child: DContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: DGrid(
          minItemWidth: 260,
          gap: 28,
          maxColumns: 3,
          children: [
            item(
              Icons.verified_user_outlined,
              'Precise verification labels',
              'Every employer shows exactly which checks it has passed.',
            ),
            item(
              Icons.auto_awesome_outlined,
              'AI you stay in control of',
              'Suggestions are editable, and scores are estimates – never hiring decisions.',
            ),
            item(
              Icons.lock_outline_rounded,
              'Your data, your choice',
              'Decide who sees your profile and CV. Withdraw consent any time.',
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ categories --

/// Photo mosaic: the kinds of people the platform serves.
class _Stories extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final phone = context.screenSize.isMobile;
    final h = phone ? 220.0 : 300.0;
    return _Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Headline(
            'Work looks different for everyone.',
            subtitle: 'Graduates, tailors, chefs, shop owners and growing teams – one platform built around how Nigerians actually work.',
          ),
          const SizedBox(height: 48),
          DGrid(
            minItemWidth: 260,
            gap: 16,
            children: [
              DPhotoTile(
                asset: DImages.womanDesk,
                title: 'Job seekers',
                subtitle: 'Build a CV that gets read',
                height: h,
                alignment: const Alignment(0.4, 0),
                onTap: () => context.to(Routes.getStarted),
              ),
              DPhotoTile(
                asset: DImages.teamMeeting,
                title: 'Employers',
                subtitle: 'Hire with a verified profile',
                height: h,
                onTap: () => context.to(Routes.employer),
              ),
              DPhotoTile(
                asset: DImages.tailor,
                title: 'Businesses',
                subtitle: 'Grow with the Business Hub',
                height: h,
                onTap: () => context.to(Routes.business),
              ),
              DPhotoTile(
                asset: DImages.classroom,
                title: 'Learners',
                subtitle: 'Courses with verifiable certificates',
                height: h,
                onTap: () => context.to(Routes.academy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const new();

  static const _cats = <(IconData, String, String, int)>[
    (Icons.code_rounded, 'Technology', 'Developers, data, product', 0),
    (
      Icons.account_balance_outlined,
      'Finance & accounting',
      'Audit, tax, banking',
      1,
    ),
    (
      Icons.local_hospital_outlined,
      'Healthcare',
      'Nursing, pharmacy, admin',
      2,
    ),
    (
      Icons.local_shipping_outlined,
      'Logistics',
      'Fleet, warehouse, supply chain',
      3,
    ),
    (
      Icons.campaign_outlined,
      'Sales & marketing',
      'Field sales, digital, brand',
      1,
    ),
    (Icons.school_outlined, 'Education', 'Teaching, training, edtech', 0),
    (
      Icons.engineering_outlined,
      'Engineering & energy',
      'Oil & gas, power, HSE',
      3,
    ),
    (
      Icons.storefront_outlined,
      'Retail & hospitality',
      'Stores, hotels, customer care',
      2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final tints = [
      jm.primarySoft,
      jm.accentSoft,
      DTint.blue(context),
      DTint.purple(context),
    ];
    final fgs = [
      jm.primary,
      jm.onAccentSoft,
      DTint.blueText(context),
      DTint.purpleText(context),
    ];
    return _Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Headline(
            'Explore jobs by category.',
            subtitle: 'From Lagos tech teams to Kano manufacturers – find work that fits your skills.',
          ),
          const SizedBox(height: 48),
          DGrid(
            minItemWidth: 250,
            gap: 16,
            children: [
              for (final (icon, name, sub, t) in _cats)
                DCard(
                  radius: 22,
                  padding: const EdgeInsets.all(22),
                  semanticLabel: 'Browse $name jobs',
                  onTap: () => context.to(Routes.jobs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DIconTile(icon, bg: tints[t], fg: fgs[t], size: 52),
                      const SizedBox(height: 18),
                      Text(name, style: type.h4),
                      const SizedBox(height: 4),
                      Text(
                        sub,
                        style: type.small.copyWith(color: jm.textMuted),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Browse jobs ›',
                        style: type.label.copyWith(color: jm.primary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- bento --

class _Bento extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final phone = context.screenSize.isMobile;

    final seekers = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: phone ? 460 : 620,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              DImages.graduate,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.4),
              semanticLabel: 'A smiling graduate on campus',
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0xCC000000),
                  ],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'For job seekers',
                    style: type.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'One profile.\nEvery opportunity.',
                    style: type.h1.copyWith(
                      color: Colors.white,
                      fontSize: phone ? 30 : 40,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Build your CV with AI, get matched to verified jobs and track every application.',
                    style: type.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 18),
                  DBtn(
                    'Start as a job seeker',
                    style: DBtnStyle.white,
                    onTap: () => context.to(Routes.getStarted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    Widget tile({
      required Color bg,
      required Color fg,
      required String eyebrow,
      required String title,
      required String body,
      required String cta,
      required String route,
      required IconData icon,
      DBtnStyle style = DBtnStyle.white,
    }) => Container(
      constraints: BoxConstraints(minHeight: phone ? 0 : 302),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  eyebrow,
                  style: type.label.copyWith(
                    color: fg.withValues(alpha: 0.8),
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(icon, color: fg.withValues(alpha: 0.9), size: 30),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: type.h2.copyWith(
              color: fg,
              fontSize: phone ? 26 : 30,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: type.body.copyWith(color: fg.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 22),
          DBtn(cta, style: style, onTap: () => context.to(route)),
        ],
      ),
    );

    final employers = tile(
      bg: JmBrand.ink,
      fg: Colors.white,
      eyebrow: 'For employers',
      title: 'Hire with confidence.',
      body: 'Get verified, post genuine vacancies and manage applicants with your team in one pipeline.',
      cta: 'Start hiring',
      route: Routes.employer,
      icon: Icons.work_outline_rounded,
    );
    final business = tile(
      bg: JmBrand.amber,
      fg: JmBrand.ink,
      eyebrow: 'For business owners',
      title: 'Grow what you started.',
      body: 'Consultants, grants, tenders and a network of businesses like yours.',
      cta: 'Take the needs assessment',
      route: Routes.business,
      icon: Icons.storefront_outlined,
      style: DBtnStyle.dark,
    );

    return _Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Headline(
            'Built for everyone in the world of work.',
            subtitle: 'Each path has its own onboarding and dashboard, so you only see what matters to you.',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 860) {
                return Column(
                  children: [
                    seekers,
                    const SizedBox(height: 16),
                    employers,
                    const SizedBox(height: 16),
                    business,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: seekers),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        employers,
                        const SizedBox(height: 16),
                        business,
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          if (jm.isDark) const SizedBox.shrink(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- how it works --

class _HowItWorks extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    const steps = [
      (
        '1',
        'Create your profile',
        'Sign up free and build one career profile – or upload the CV you already have.',
        Icons.person_add_alt_1_outlined,
      ),
      (
        '2',
        'Get matched',
        'See verified jobs ranked by fit, with clear reasons and the skills you are missing.',
        Icons.bolt_rounded,
      ),
      (
        '3',
        'Apply and track',
        'Apply in a few taps, answer screening questions and follow every stage live.',
        Icons.timeline_rounded,
      ),
    ];
    return _Section(
      top: 96,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.all(context.screenSize.isMobile ? 24 : 56),
        decoration: BoxDecoration(
          color: jm.background,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Headline(
              'How it works.',
              subtitle:
                  'From sign-up to your first interview in three simple steps.',
            ),
            const SizedBox(height: 44),
            DGrid(
              minItemWidth: 260,
              gap: 20,
              maxColumns: 3,
              children: [
                for (final (n, t, d, icon) in steps)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: jm.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              n,
                              style: type.label.copyWith(
                                color: jm.onPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(icon, color: jm.textMuted),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(t, style: type.h3),
                      const SizedBox(height: 8),
                      Text(d, style: type.body.copyWith(color: jm.textMuted)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: DBtn(
                'Get started – it’s free',
                onTap: () => context.to(Routes.getStarted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- featured --

class _Featured extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return _Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            runSpacing: 12,
            children: [
              const _Headline(
                'Featured opportunities.',
                center: false,
                subtitle: 'Every listing shows exactly which checks the employer has passed.',
              ),
              DLink('View all jobs ›', onTap: () => context.to(Routes.jobs)),
            ],
          ),
          const SizedBox(height: 32),
          DGrid(
            minItemWidth: 270,
            children: [
              for (final (ini, title, co, loc, kind, close, ver)
                  in Demo.featured)
                DCard(
                  padding: const EdgeInsets.all(22),
                  semanticLabel: '$title at $co, $ver',
                  onTap: () => context.to(Routes.jobDetail(Demo.jobs.first.id)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          DInitials(ini, size: 44, bg: jm.surfaceAlt),
                          const Spacer(),
                          Icon(
                            Icons.bookmark_border_rounded,
                            color: jm.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(title, style: type.h4.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(co, style: type.small.copyWith(color: jm.textMuted)),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [DTag(loc), DTag(kind)],
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: jm.border),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Flexible(child: DVerifiedPill(ver)),
                          const SizedBox(width: 8),
                          Text(
                            'Closes $close',
                            style: type.caption.copyWith(color: jm.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- tools --

class _Tools extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final phone = context.screenSize.isMobile;
    const muted = Color(0xFFA1A1A6);
    Widget feature(IconData icon, String t, String d) => Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: JmBrand.emeraldLifted, size: 28),
          const SizedBox(height: 14),
          Text(t, style: type.h4.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Text(d, style: type.small.copyWith(color: muted)),
        ],
      ),
    );

    final scoreCard = Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CV compatibility', style: type.label.copyWith(color: muted)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox.square(
                dimension: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 0.74,
                        strokeWidth: 10,
                        color: JmBrand.emeraldLifted,
                        backgroundColor: Color(0xFF3A3A3C),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '74',
                      style: type.h1.copyWith(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (k, v) in [
                      ('Role relevance', 0.82),
                      ('Keywords', 0.58),
                      ('Structure', 0.88),
                    ]) ...[
                      Text(k, style: type.caption.copyWith(color: muted)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 6,
                          color: v > 0.7
                              ? JmBrand.emeraldLifted
                              : JmBrand.amber,
                          backgroundColor: const Color(0xFF3A3A3C),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Estimate only – not an employer decision.',
            style: type.caption.copyWith(color: muted),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: phone ? 56 : 96),
      child: ColoredBox(
        color: const Color(0xFF000000),
        child: DContainer(
          padding: EdgeInsets.symmetric(
            horizontal: phone ? 20 : 24,
            vertical: phone ? 56 : 96,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'AI Career Tools',
                textAlign: TextAlign.center,
                style: type.label.copyWith(
                  color: JmBrand.emeraldLifted,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prepare smarter.\nYou approve every suggestion.',
                textAlign: TextAlign.center,
                style: type.h1.copyWith(
                  color: Colors.white,
                  fontSize: phone ? 34 : 56,
                  letterSpacing: phone ? -1 : -2,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Text(
                    'Our AI never invents experience or qualifications. Scores are estimates to help you improve – not hiring decisions.',
                    textAlign: TextAlign.center,
                    style: type.bodyL.copyWith(
                      color: muted,
                      fontSize: phone ? 17 : 21,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: DBtn(
                  'Explore career tools',
                  onTap: () => context.to(Routes.tools),
                ),
              ),
              const SizedBox(height: 56),
              DSplit(
                breakpoint: 900,
                asideWidth: 460,
                gap: 20,
                aside: scoreCard,
                main: DGrid(
                  minItemWidth: 230,
                  gap: 16,
                  maxColumns: 2,
                  children: [
                    feature(
                      Icons.description_outlined,
                      'AI CV Review',
                      'Estimated ATS-readiness with prioritised fixes.',
                    ),
                    feature(
                      Icons.edit_note_rounded,
                      'CV Builder',
                      'Build from your profile; export to PDF or DOCX.',
                    ),
                    feature(
                      Icons.track_changes_rounded,
                      'Job Matching',
                      'See why a role fits and which skills are missing.',
                    ),
                    feature(
                      Icons.record_voice_over_outlined,
                      'Interview Coach',
                      'Practise role-specific questions with feedback.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- academy --

/// Course card used by Home and the Academy catalogue: a soft gradient cover
/// with a topic icon (no stock photos).
class DCourseCard extends StatelessWidget {
  const new(this.course, {super.key});

  final DemoCourse course;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final covers = <List<Color>>[
      [const Color(0xFF0E6B47), const Color(0xFF3FBF8A)],
      [const Color(0xFFF2A93B), const Color(0xFFF7D49A)],
      [const Color(0xFF1F4E99), const Color(0xFF6AA8F7)],
      [const Color(0xFF6B2E83), const Color(0xFFC08AD8)],
    ];
    final icons = [
      Icons.bar_chart_rounded,
      Icons.record_voice_over_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.auto_graph_rounded,
    ];
    final c = covers[course.tint % 4];
    return DCard(
      padding: EdgeInsets.zero,
      semanticLabel: course.title,
      onTap: () => context.to(Routes.course(course.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: c,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(21),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -18,
                  child: Icon(
                    icons[course.tint % 4],
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: DPill(course.price, bg: Colors.white, fg: JmBrand.ink),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.provider.toUpperCase(),
                  style: context.type.overline.copyWith(
                    color: jm.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  course.title,
                  style: context.type.h4.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  course.meta,
                  style: context.type.small.copyWith(color: jm.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Academy extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => _Section(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          runSpacing: 12,
          children: [
            const _Headline(
              'Learn the skills employers ask for.',
              center: false,
              eyebrow: 'JobsAndMore Academy',
              subtitle: 'Free and paid courses with verifiable certificates.',
            ),
            DLink('Browse courses ›', onTap: () => context.to(Routes.academy)),
          ],
        ),
        const SizedBox(height: 32),
        DGrid(
          minItemWidth: 300,
          gap: 20,
          maxColumns: 3,
          children: [for (final c in Demo.courses) DCourseCard(c)],
        ),
      ],
    ),
  );
}

// ------------------------------------------------------------- app promo --

class _AppPromo extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final phone = context.screenSize.isMobile;

    // Phone mock-up showing the mobile home screen.
    final device = Container(
      width: 280,
      height: 560,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1F),
        borderRadius: BorderRadius.circular(46),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 50,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: ColoredBox(
          color: const Color(0xFFF5F5F7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 210,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      DImages.graduate,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.6),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xAA000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 14,
                      right: 16,
                      child: Text(
                        'Good morning,\nTunde',
                        style: type.h3.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: JmBrand.forest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'Interview invite from Kobo Logistics – pick a slot',
                        style: type.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final (t, m) in [
                      ('Operations Analyst', '82%'),
                      ('Data Analyst', '76%'),
                      ('Business Analyst', '71%'),
                    ])
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t,
                                style: type.caption.copyWith(
                                  color: JmBrand.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DPill(
                              m,
                              fontSize: 11,
                              bg: const Color(0xFFE6F1EB),
                              fg: JmBrand.forest,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return _Section(
      child: Container(
        padding: EdgeInsets.all(phone ? 24 : 64),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE6F1EB), Color(0xFFF5F5F7)],
          ),
        ),
        child: DSplit(
          breakpoint: 860,
          asideWidth: 320,
          gap: 48,
          main: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JobsAndMore app',
                style: type.label.copyWith(color: jm.primary, fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(
                'Your next job,\nin your pocket.',
                style: type.h1.copyWith(
                  fontSize: phone ? 34 : 52,
                  letterSpacing: -1.6,
                  color: JmBrand.ink,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Get instant alerts for new matches, reply to employers and practise interviews on the go. Works on Android and iPhone.',
                style: type.bodyL.copyWith(color: const Color(0xFF6A6A6F)),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  DBtn(
                    'Get it on Google Play',
                    style: DBtnStyle.dark,
                    icon: Icons.android_rounded,
                    onTap: () {},
                  ),
                  DBtn(
                    'Download on the App Store',
                    style: DBtnStyle.dark,
                    icon: Icons.apple_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          aside: Center(child: device),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- faq --

class _Faq extends StatelessWidget {
  const new();

  static const items = [
    (
      'Is JobsAndMore free for job seekers?',
      'Yes. Profile, search, applications, alerts and selected AI tools are free. Career Plus adds more AI credits and advanced tools.',
    ),
    (
      'What does "Verified employer" mean?',
      'It means the employer passed email, business-details and authorised-representative checks. Partial checks get their own label.',
    ),
    (
      'Will an AI score decide if I get hired?',
      'No. Scores are estimates to help you improve. Employers make decisions, and no one is auto-rejected on an AI score.',
    ),
    (
      'How do I report a suspicious job?',
      'Use "Report listing" on any job. Never pay a fee to apply for a job.',
    ),
  ];

  @override
  Widget build(BuildContext context) => _Section(
    bottom: 112,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Headline('Questions? Answers.'),
            const SizedBox(height: 32),
            for (final (q, a) in items)
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: context.jm.border)),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    title: Text(
                      q,
                      style: context.type.h4.copyWith(fontSize: 18),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 18),
                    expandedAlignment: Alignment.centerLeft,
                    children: [
                      Text(
                        a,
                        style: context.type.body.copyWith(
                          color: context.jm.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class NotFoundScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => DPage(
    body: DContainer(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
      child: Column(
        children: [
          Text('Page not found.', style: context.type.h1),
          const SizedBox(height: 12),
          Text(
            'The link may be broken or the page may have moved.',
            style: context.type.bodyL.copyWith(color: context.jm.textMuted),
          ),
          const SizedBox(height: 28),
          DBtn('Go to homepage', onTap: () => context.to(Routes.home)),
        ],
      ),
    ),
  );
}
