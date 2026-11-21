import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/env.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/data/live_data.dart';
import 'package:jobsandmore/features/demo/demo_data.dart';
import 'package:jobsandmore/features/home/presentation/home_screen.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

/// 19 Business Hub – starts with a needs assessment (not a copy of the
/// employer area).
class BusinessHubScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<BusinessHubScreen> createState() => _BusinessHubScreenState();
}

class _BusinessHubScreenState extends State<BusinessHubScreen> {
  int _q = 0;
  String _answer = 'Funding readiness';
  final _saved = <int>{};

  static const _options = [
    'Hiring & HR',
    'Funding readiness',
    'Operations',
    'Visibility & sales',
    'Strategy',
    'Data & analytics',
  ];
  static const List<(String, String, IconData)> _services = [
    (
      'HR & people',
      'Policies, payroll set-up, staff handbooks',
      Icons.groups_2_outlined,
    ),
    (
      'Business strategy',
      'Plans, pricing, market entry',
      Icons.insights_outlined,
    ),
    (
      'Project management',
      'Delivery planning and PMO support',
      Icons.view_timeline_outlined,
    ),
    (
      'Research & analytics',
      'Market research, dashboards',
      Icons.query_stats_rounded,
    ),
    (
      'Risk & compliance',
      'Risk reviews, process controls',
      Icons.verified_user_outlined,
    ),
    (
      'Recruitment services',
      'Managed hiring for SMEs',
      Icons.person_search_outlined,
    ),
    (
      'Training for teams',
      'Custom workshops and courses',
      Icons.school_outlined,
    ),
    (
      'Funding readiness',
      'Pitch decks, financial models',
      Icons.account_balance_outlined,
    ),
  ];
  // Demo opportunities. Real listings always carry their source and deadline.
  static const _opps = [
    ('GRANT', '[Example] Women-led SME growth grant', '[Funder name & link]'),
    (
      'TENDER',
      '[Example] State facility management tender',
      '[Procurement portal]',
    ),
    (
      'ACCELERATOR',
      '[Example] Agritech accelerator cohort',
      '[Programme site]',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final phone = DPage.isPhone(context);

    final hero = DPhotoBackdrop(
      asset: DImages.shopOwner,
      alignment: const Alignment(0.5, -0.3),
      tint: JmBrand.ink,
      child: DContainer(
        padding: EdgeInsets.fromLTRB(24, phone ? 48 : 88, 24, phone ? 48 : 88),
        child: DSplit(
          breakpoint: 940,
          asideWidth: 460,
          gap: 40,
          main: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DEyebrow('Business Hub', color: JmBrand.amber),
              const SizedBox(height: 12),
              Text(
                'What does your business need right now?',
                style: type.h1.copyWith(
                  color: Colors.white,
                  fontSize: phone ? 30 : 40,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Answer 8 short questions and we'll point you to the right services, resources and opportunities. Results are guidance, not professional advice.",
                style: type.bodyL.copyWith(
                  color: DTint.footerMuted,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          aside: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: jm.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Needs assessment',
                        style: type.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      'Question ${_q + 1} of 8',
                      style: type.caption.copyWith(color: jm.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DBar((_q + 1) / 8, height: 6),
                const SizedBox(height: 16),
                Text('Which area is your biggest challenge?', style: type.h4),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final o in _options)
                      DChoicePill(
                        label: o,
                        selected: o == _answer,
                        onTap: () => setState(() => _answer = o),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: DBtn(
                    _q == 7 ? 'See my results' : 'Next',
                    onTap: () {
                      if (_q == 7) {
                        context.to(Routes.businessDashboard);
                      } else {
                        setState(() => _q++);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return DPage(
      active: NavItem.biz,
      footer: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          hero,
          DContainer(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DSectionHead(
                  'Built for businesses like yours',
                  size: 28,
                  subtitle:
                      'From fashion houses to food vendors and corner shops.',
                ),
                const SizedBox(height: 20),
                DGrid(
                  minItemWidth: 260,
                  gap: 16,
                  maxColumns: 3,
                  children: [
                    DPhotoTile(
                      asset: DImages.tailor,
                      title: 'Fashion & tailoring',
                      subtitle:
                          'Find apprentices, grow orders, price your work',
                      height: phone ? 200 : 260,
                    ),
                    DPhotoTile(
                      asset: DImages.chefOwner,
                      title: 'Food & hospitality',
                      subtitle:
                          'Staffing, food-safety training, supplier links',
                      height: phone ? 200 : 260,
                    ),
                    DPhotoTile(
                      asset: DImages.shopOwner,
                      title: 'Retail & trade',
                      subtitle:
                          'Bookkeeping, stock control and funding readiness',
                      height: phone ? 200 : 260,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                DSectionHead(
                  'Consultancy & services',
                  size: 28,
                  action: 'Browse all services',
                  onAction: () {},
                ),
                const SizedBox(height: 20),
                DGrid(
                  minItemWidth: 240,
                  gap: 14,
                  children: [
                    for (final (n, d, ic) in _services)
                      DCard(
                        padding: const EdgeInsets.all(20),
                        onTap: () => showJmToast(
                          context,
                          'Providers for $n are listed in the marketplace.',
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DIconTile(ic, size: 44),
                            const SizedBox(height: 14),
                            Text(
                              n,
                              style: type.label.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d,
                              style: type.small.copyWith(color: jm.textMuted),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 48),
                DSectionHead(
                  'Business opportunities',
                  size: 28,
                  subtitle: 'Grants, competitions, tenders and accelerators – each with its source and closing date.',
                  action: 'All opportunities',
                  onAction: () {},
                ),
                const SizedBox(height: 20),
                for (final (i, (t, n, s)) in _opps.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DCard(
                      radius: 18,
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          DPill(
                            t,
                            radius: 6,
                            bg: DTint.blue(context),
                            fg: DTint.blueText(context),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n,
                                  style: type.label.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Source: $s · Closes [Date]',
                                  style: type.caption.copyWith(
                                    color: jm.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              DLink('Details', onTap: () {}),
                              DBtn(
                                _saved.contains(i) ? 'Saved' : 'Save',
                                style: DBtnStyle.secondary,
                                height: 38,
                                fontSize: 13,
                                icon: _saved.contains(i)
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                onTap: () => setState(
                                  () => _saved.contains(i)
                                      ? _saved.remove(i)
                                      : _saved.add(i),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 38),
                DGrid(
                  minItemWidth: 380,
                  gap: 20,
                  maxColumns: 2,
                  children: [
                    DCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Business directory', style: type.h3),
                          const SizedBox(height: 8),
                          Text(
                            'Find suppliers, partners and service providers. Contact details stay private until both sides agree to connect.',
                            style: type.body.copyWith(color: jm.textMuted),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final c in [
                                'Food & agro',
                                'Retail',
                                'Tech',
                                'Professional services',
                              ])
                                DTag(c),
                            ],
                          ),
                          const SizedBox(height: 14),
                          DLink('Explore directory', arrow: true, onTap: () {}),
                        ],
                      ),
                    ),
                    DCard(
                      color: jm.accentSoft,
                      borderColor: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Need to hire too?', style: type.h3),
                          const SizedBox(height: 8),
                          Text(
                            'Turn on an Employer workspace from your business account – same login, same verified identity.',
                            style: type.body,
                          ),
                          const SizedBox(height: 16),
                          DBtn(
                            'Activate employer workspace',
                            style: DBtnStyle.dark,
                            onTap: () => context.to(Routes.employer),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 20 Business Owner dashboard.
class BusinessDashboardScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;

    final nav = DCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, n) in [
            'Overview',
            'Business profile',
            'Enquiries & projects',
            'Saved services',
            'Opportunities',
            'Connections',
            'Learning',
            'Events',
            'Referrals',
            '+ Employer workspace',
          ].indexed)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => i == 9 ? context.to(Routes.employer) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: i == 0 ? jm.primarySoft : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  n,
                  style: type.small.copyWith(
                    fontWeight: i == 0 || i == 9
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: i == 0 || i == 9 ? jm.onPrimarySoft : jm.text,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    Widget card(String title, Widget child, {String? action}) => DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: type.h4)),
              if (action != null) DLink(action, onTap: () {}),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );

    (Color, Color) status(String s) => switch (s) {
      'Proposal received' => (jm.primarySoft, jm.onPrimarySoft),
      'In progress' => (DTint.blue(context), DTint.blueText(context)),
      _ => (jm.accentSoft, jm.onAccentSoft),
    };

    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tola's Bakery", style: type.h1.copyWith(fontSize: 30)),
                Text(
                  'Food & beverage · Growth stage · Ibadan · ✓ Email & phone verified',
                  style: type.small.copyWith(color: jm.textMuted),
                ),
              ],
            ),
            DBtn('Find support', onTap: () => context.to(Routes.business)),
          ],
        ),
        const SizedBox(height: 20),
        DGrid(
          minItemWidth: 320,
          gap: 20,
          maxColumns: 2,
          children: [
            card(
              'Profile completeness',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const DRing(65, size: 64, stroke: 6),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Add your logo, products and target market to appear in the directory.',
                          style: type.small.copyWith(color: jm.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DLink('Complete profile', onTap: () {}),
                  ),
                ],
              ),
            ),
            card(
              'From your needs assessment',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Guidance based on your answers · 12 Nov',
                    style: type.caption.copyWith(color: jm.textMuted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in [
                        'Funding readiness',
                        'Hiring & HR',
                        'Visibility',
                      ])
                        DPill(t, fontSize: 13),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DLink(
                      'See recommended services',
                      onTap: () => context.to(Routes.business),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        card(
          'Enquiries & projects',
          action: 'View all',
          DTable(
            columns: const [
              ('Request', 5),
              ('Provider', 3),
              ('Sent', 2),
              ('Status', 3),
              ('', 2),
            ],
            rows: [
              for (final (r, p, d, s, a) in [
                (
                  'Financial model for loan application',
                  '[Consultant]',
                  '12 Nov',
                  'Proposal received',
                  'Review',
                ),
                (
                  'Staff handbook & contracts',
                  '[HR firm]',
                  '8 Nov',
                  'In progress',
                  'Open',
                ),
                (
                  'Market research – Lagos expansion',
                  '[Research firm]',
                  '2 Nov',
                  'Awaiting reply',
                  'Nudge',
                ),
              ])
                [
                  Text(r, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(p),
                  Text(d),
                  Builder(
                    builder: (c) {
                      final (bg, fg) = status(s);
                      return DPill(s, bg: bg, fg: fg);
                    },
                  ),
                  DLink(a, onTap: () {}),
                ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        DGrid(
          minItemWidth: 260,
          gap: 20,
          maxColumns: 3,
          children: [
            card(
              'Saved opportunities',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '[Example] SME growth grant',
                    style: type.label.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Closes in 9 days',
                    style: type.caption.copyWith(
                      color: jm.onAccentSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DLink('View 3 saved', onTap: () {}),
                ],
              ),
            ),
            card(
              'Connection requests',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Greenfield Agro',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' wants to connect – supplier interest'),
                      ],
                    ),
                    style: type.small,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      DBtn(
                        'Accept',
                        height: 38,
                        fontSize: 13,
                        onTap: () => showJmToast(
                          context,
                          'Connected with Greenfield Agro',
                          tone: JmTone.success,
                        ),
                      ),
                      DBtn(
                        'Decline',
                        style: DBtnStyle.secondary,
                        height: 38,
                        fontSize: 13,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            card(
              'Learning & events',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Small Business Finance Basics',
                          style: type.small,
                        ),
                      ),
                      Text(
                        '40%',
                        style: type.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const DBar(0.4),
                  const SizedBox(height: 12),
                  Text(
                    'SME Networking Breakfast · [Date] · [Venue]',
                    style: type.caption.copyWith(
                      color: jm.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );

    return DPage(
      active: NavItem.biz,
      mode: NavMode.business,
      mobileTitle: "Tola's Bakery",
      mobileBody: Padding(padding: const EdgeInsets.all(16), child: main),
      body: DContainer(
        maxWidth: 1320,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: DSplit(
          asideOnRight: false,
          asideWidth: 230,
          gap: 24,
          breakpoint: 1080,
          aside: nav,
          main: main,
        ),
      ),
    );
  }
}

/// 21 Academy catalogue.
class AcademyScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends ConsumerState<AcademyScreen> {
  final _on = <String>{
    'Free',
    'Paid',
    'Data & tech',
    'Beginner',
    'Certificate available',
  };
  String _lang = 'English';
  String _sort = 'Most relevant';

  static const _catalogue = [
    DemoCourse(
      id: 'intro-sql',
      title: 'Intro to SQL for Analysts',
      meta: 'Beginner · 8 hrs · Self-paced',
      price: 'Free',
      tint: 0,
    ),
    DemoCourse(
      id: 'power-bi',
      title: 'Power BI Essentials',
      provider: '[Approved provider]',
      meta: 'Beginner · 10 hrs · Video',
      price: '[Price]',
      tint: 1,
    ),
    DemoCourse(
      id: 'excel-data-reporting',
      title: 'Excel for Data Reporting',
      meta: 'Beginner · 6 hrs · Self-paced',
      price: 'Free',
      tint: 2,
    ),
    DemoCourse(
      id: 'data-storytelling',
      title: 'Data Storytelling',
      provider: '[Approved provider]',
      meta: 'Intermediate · Live cohort · 4 wks',
      price: '[Price]',
      tint: 3,
    ),
    DemoCourse(
      id: 'workplace-readiness',
      title: 'Workplace Readiness',
      meta: 'All levels · 3 hrs · Text',
      price: 'Free',
      tint: 0,
    ),
    DemoCourse(
      id: 'python-basics',
      title: 'Python Basics',
      provider: '[Approved provider]',
      meta: 'Beginner · 12 hrs · Video',
      price: '[Price]',
      tint: 1,
    ),
  ];

  List<DemoCourse> get _shown {
    if (!Env.hasSupabase) return _catalogue;
    final all = ref.watch(coursesProvider).valueOrNull ?? const <DemoCourse>[];
    final free = _on.contains('Free');
    final paid = _on.contains('Paid');
    return [
      for (final c in all)
        if ((free && c.priceKobo == 0) ||
            (paid && c.priceKobo > 0) ||
            (!free && !paid))
          c,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;

    Widget group(String legend, List<String> opts) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(legend, style: type.label.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final o in opts)
          DCheck(
            value: _on.contains(o),
            onChanged: (v) => setState(() => v ? _on.add(o) : _on.remove(o)),
            label: Text(o),
          ),
        const SizedBox(height: 18),
      ],
    );

    final filters = DCard(
      radius: 18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          group('Price', ['Free', 'Paid']),
          group('Topic', [
            'Career readiness',
            'Data & tech',
            'Business & entrepreneurship',
            'HR & leadership',
          ]),
          group('Level', ['Beginner', 'Intermediate', 'Advanced']),
          group('Format', [
            'Self-paced video',
            'Live cohort',
            'Text & downloads',
          ]),
          DCheck(
            value: _on.contains('Certificate available'),
            onChanged: (v) => setState(
              () => v
                  ? _on.add('Certificate available')
                  : _on.remove('Certificate available'),
            ),
            label: const Text('Certificate available'),
          ),
          const SizedBox(height: 18),
          DSelect<String>(
            label: 'Language',
            value: _lang,
            items: const ['English', 'Yoruba', 'Hausa', 'Igbo'],
            onChanged: (v) => setState(() => _lang = v),
          ),
        ],
      ),
    );

    final results = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                Env.hasSupabase ? '${_shown.length} courses' : '42 courses',
                style: type.h3,
              ),
            ),
            SizedBox(
              width: 200,
              child: DSelect<String>(
                label: 'Sort',
                showLabel: false,
                height: 42,
                value: _sort,
                items: const ['Most relevant', 'Newest'],
                onChanged: (v) => setState(() => _sort = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DGrid(
          minItemWidth: 260,
          maxColumns: 3,
          children: [for (final c in _shown) DCourseCard(c)],
        ),
        const SizedBox(height: 32),
        DCard(
          color: jm.accentSoft,
          borderColor: Colors.transparent,
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you a training provider?', style: type.h4),
                  Text(
                    'Publish courses, manage cohorts and issue verifiable certificates.',
                    style: type.small,
                  ),
                ],
              ),
              DBtn(
                'Become a provider',
                style: DBtnStyle.dark,
                onTap: () => context.to(Routes.getStarted),
              ),
            ],
          ),
        ),
      ],
    );

    return DPage(
      active: NavItem.academy,
      footer: true,
      mobileTab: MobileTab.learn,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DPhotoBackdrop(
            asset: DImages.classroom,
            alignment: const Alignment(0, -0.2),
            child: DContainer(
              maxWidth: 1280,
              padding: EdgeInsets.fromLTRB(
                24,
                DPage.isPhone(context) ? 40 : 72,
                24,
                DPage.isPhone(context) ? 36 : 64,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DEyebrow('Academy', color: JmBrand.amber),
                  const SizedBox(height: 10),
                  Text(
                    'Learn skills employers ask for.',
                    style: type.h1.copyWith(
                      color: Colors.white,
                      fontSize: DPage.isPhone(context) ? 30 : 48,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      'Courses for careers and businesses, from JobsAndMore and approved training providers.',
                      style: type.bodyL.copyWith(color: DTint.onDarkMuted),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
                      decoration: BoxDecoration(
                        color: jm.surface,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 30,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: jm.textMuted),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search courses, skills or providers',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                              ),
                            ),
                          ),
                          DBtn('Search', height: 44, onTap: () {}),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DContainer(
            maxWidth: 1280,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: DNotice(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended for your skill gaps',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'From your CV analysis for "Operations Analyst": SQL, Power BI, KPI dashboards.',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    children: [
                      DLink(
                        'Intro to SQL · Free',
                        onTap: () => context.to(Routes.course('intro-sql')),
                      ),
                      DLink(
                        'Power BI Essentials · [Price]',
                        onTap: () => context.to(Routes.course('power-bi')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DContainer(
            maxWidth: 1280,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
            child: DSplit(
              asideOnRight: false,
              asideWidth: 260,
              gap: 24,
              breakpoint: 900,
              aside: filters,
              main: results,
            ),
          ),
        ],
      ),
    );
  }
}

/// 22 Course detail.
class CourseDetailScreen extends ConsumerStatefulWidget {
  const new({required this.courseId, super.key});

  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  bool _saved = false;
  bool _busy = false;

  Future<void> _enrol(DemoCourse c) async {
    if (c.uuid == null) return;
    if (c.priceKobo > 0) {
      showJmToast(
        context,
        'Paid courses open once online payments are switched on.',
        tone: JmTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await enrolInCourse(c.uuid!);
      ref
        ..invalidate(myCoursesProvider)
        ..invalidate(isEnrolledProvider(c.uuid!));
      if (!mounted) return;
      showJmToast(
        context,
        'Enrolled. Find it under My learning.',
        tone: JmTone.success,
      );
      context.to(Routes.myCourses);
    } on DataFailure catch (e) {
      if (!mounted) return;
      showJmToast(context, e.message, tone: JmTone.error);
      if (currentUserId == null) context.to(Routes.signIn);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static const _mods = [
    (
      '1. Why analysts use SQL',
      '45 min',
      'Databases, tables and where SQL fits in reporting.',
    ),
    (
      '2. Selecting and filtering',
      '1 hr 20 min',
      'SELECT, WHERE, ORDER BY with a delivery dataset.',
    ),
    (
      '3. Joining tables',
      '1 hr 30 min',
      'INNER and LEFT joins; avoiding duplicates.',
    ),
    (
      '4. Summarising data',
      '1 hr 30 min',
      'GROUP BY, COUNT, SUM, AVG and HAVING.',
    ),
    (
      '5. Dates and KPIs',
      '1 hr 15 min',
      'Weekly and monthly metrics from timestamps.',
    ),
    (
      '6. Final practical task',
      '1 hr 40 min',
      'Build a weekly operations KPI report.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final c = Env.hasSupabase
        ? ref.watch(courseProvider(widget.courseId)).valueOrNull
        : null;
    final modules = c?.uuid == null
        ? const <String>[]
        : (ref.watch(courseModulesProvider(c!.uuid!)).valueOrNull ??
              const <String>[]);
    final enrolled =
        c?.uuid != null &&
        (ref.watch(isEnrolledProvider(c!.uuid!)).valueOrNull ?? false);

    Widget section(String t, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(t, style: type.h3)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );

    final main = DCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          section(
            "What you'll be able to do",
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final o
                    in c != null && c.outcomes.isNotEmpty
                        ? c.outcomes
                        : const [
                            'Write SELECT queries with filters and sorting',
                            'Join two or more tables correctly',
                            'Summarise data with GROUP BY',
                            'Build a weekly KPI query for a report',
                          ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '✓ $o',
                      style: type.body.copyWith(color: jm.onPrimarySoft),
                    ),
                  ),
              ],
            ),
          ),
          section(
            'Syllabus',
            DCard(
              padding: EdgeInsets.zero,
              radius: 18,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: jm.border),
                child: Column(
                  children: [
                    for (final (n, d, c)
                        in c != null && modules.isNotEmpty
                            ? [
                                for (final (i, m) in modules.indexed)
                                  ('${i + 1}. $m', '', ''),
                              ]
                            : _mods)
                      ExpansionTile(
                        title: Text(
                          n,
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: Text(
                          d,
                          style: type.caption.copyWith(color: jm.textMuted),
                        ),
                        expandedAlignment: Alignment.centerLeft,
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          14,
                        ),
                        children: [
                          Text(
                            c,
                            style: type.small.copyWith(color: jm.textMuted),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          section(
            'Prerequisites',
            Text(
              'Basic spreadsheet use. No coding experience needed.',
              style: type.body,
            ),
          ),
          section(
            'Assessment',
            Text(
              'A quiz after each module and a final practical task. 3 attempts per quiz.',
              style: type.body,
            ),
          ),
          section(
            'Certificate criteria',
            Text(
              'Finish all modules and score 70%+ on the final task.',
              style: type.body,
            ),
          ),
          section(
            'Verifiable certificate',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Each certificate has a unique credential ID that employers can check on JobsAndMore. It's added to your profile automatically.",
                  style: type.body,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: JmBrand.amber, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: jm.accentSoft,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Certificate of completion',
                        style: type.overline.copyWith(color: jm.onAccentSoft),
                      ),
                      const SizedBox(height: 8),
                      Text('[Learner name]', style: type.h3),
                      const SizedBox(height: 4),
                      Text(
                        'Intro to SQL for Analysts · JobsAndMore Academy',
                        style: type.small,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed [date] · ID: JAM-XXXX-XXXX',
                        style: type.caption.copyWith(color: jm.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final enrol = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            c?.price ?? 'Free',
            style: type.h1.copyWith(fontSize: 32, color: jm.primary),
          ),
          const SizedBox(height: 14),
          DBtn(
            enrolled
                ? 'Go to My learning'
                : (_busy ? 'Enrolling…' : 'Enrol now'),
            height: 52,
            expand: true,
            onTap: _busy
                ? null
                : () {
                    if (c == null) {
                      showJmToast(
                        context,
                        'Enrolled. Find it under My learning.',
                        tone: JmTone.success,
                      );
                      context.to(Routes.myCourses);
                    } else if (enrolled) {
                      context.to(Routes.myCourses);
                    } else {
                      unawaited(_enrol(c));
                    }
                  },
          ),
          const SizedBox(height: 10),
          DBtn(
            _saved ? 'Saved' : 'Save for later',
            style: DBtnStyle.secondary,
            expand: true,
            icon: _saved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            onTap: () => setState(() => _saved = !_saved),
          ),
          const SizedBox(height: 16),
          for (final f in [
            '6 video modules with captions',
            'Practice dataset (downloadable)',
            'Quizzes and final task',
            'Certificate on completion',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('✓ $f', style: type.small),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: jm.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'Closes your '),
                  TextSpan(
                    text: 'SQL',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' skill gap for 6 saved jobs.'),
                ],
              ),
              style: type.small,
            ),
          ),
        ],
      ),
    );

    return DPage(
      active: NavItem.academy,
      mobileTitle: 'Course',
      footer: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DPhotoBackdrop(
            asset: DImages.womanDesk,
            alignment: const Alignment(0.6, -0.2),
            child: DContainer(
              padding: EdgeInsets.fromLTRB(
                24,
                DPage.isPhone(context) ? 32 : 56,
                24,
                DPage.isPhone(context) ? 36 : 64,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    children: [
                      DLink(
                        'Academy',
                        color: Colors.white,
                        onTap: () => context.to(Routes.academy),
                      ),
                      Text(
                        '  /  Data & tech',
                        style: type.small.copyWith(color: DTint.onDarkMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c?.title ?? 'Intro to SQL for Analysts',
                    style: type.h1.copyWith(
                      color: Colors.white,
                      fontSize: DPage.isPhone(context) ? 30 : 40,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      c?.summary ?? 'Learn to query, filter and summarise business data so you can build reports without waiting on IT.',
                      style: type.bodyL.copyWith(color: DTint.onDarkMuted),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t
                          in c != null
                              ? c.meta.split(' · ')
                              : const [
                                  'Beginner',
                                  '8 hours · 6 modules',
                                  'Self-paced video + quizzes',
                                  'English',
                                  'Certificate',
                                ])
                        DPill(
                          t,
                          bg: Colors.white.withValues(alpha: 0.14),
                          fg: Colors.white,
                          fontSize: 13,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'By JobsAndMore Academy · Last reviewed Oct 2026',
                    style: type.small.copyWith(color: DTint.onDarkMuted),
                  ),
                ],
              ),
            ),
          ),
          DContainer(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
            child: DSplit(
              asideWidth: 340,
              asideFirst: true,
              main: main,
              aside: enrol,
            ),
          ),
        ],
      ),
    );
  }
}
