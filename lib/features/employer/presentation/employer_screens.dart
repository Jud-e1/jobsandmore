import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/env.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/data/live_data.dart';
import 'package:jobsandmore/features/employer/presentation/live_employer.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

/// Employer workspace side navigation (design 15).
class _EmployerNav extends ConsumerWidget {
  const new({required this.current});

  final int current;

  static const items = <(String, IconData, String?)>[
    ('Overview', Icons.dashboard_outlined, Routes.employer),
    ('Vacancies', Icons.work_outline_rounded, Routes.postVacancy),
    ('Applicants', Icons.people_outline_rounded, Routes.pipeline),
    ('Interviews', Icons.event_outlined, null),
    ('Talent search', Icons.person_search_outlined, null),
    ('Team', Icons.groups_outlined, null),
    ('Analytics', Icons.insights_outlined, null),
    ('Network', Icons.hub_outlined, null),
    ('Billing', Icons.receipt_long_outlined, Routes.pricing),
    ('Company profile', Icons.apartment_outlined, '/employers/kobo-logistics'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jm = context.jm;
    final type = context.type;
    final slug = Env.hasSupabase
        ? ref.watch(myEmployerOrgProvider).valueOrNull?.slug
        : 'kobo-logistics';
    return DCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (label, icon, r)) in items.indexed)
            if (r != '/employers/kobo-logistics' || slug != null)
              Builder(
                builder: (context) {
                  final route = r == '/employers/kobo-logistics'
                      ? '/employers/$slug'
                      : r;
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: route == null
                        ? () => showJmToast(
                            context,
                            '$label is part of a later phase.',
                          )
                        : () => context.to(route),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: i == current ? jm.primarySoft : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: i == current
                                ? jm.onPrimarySoft
                                : jm.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              label,
                              style: type.small.copyWith(
                                fontWeight: i == current
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: i == current
                                    ? jm.onPrimarySoft
                                    : jm.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
}

Widget _employerShell(
  BuildContext context, {
  required int nav,
  required Widget child,
}) => DPage(
  active: NavItem.hire,
  mode: NavMode.employer,
  mobileTitle: Env.hasSupabase ? 'Employer' : 'Kobo Logistics',
  mobileBody: Padding(padding: const EdgeInsets.all(16), child: child),
  body: DContainer(
    maxWidth: 1320,
    padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
    child: DSplit(
      asideOnRight: false,
      asideWidth: 230,
      gap: 24,
      breakpoint: 1080,
      aside: _EmployerNav(current: nav),
      main: child,
    ),
  ),
);

/// 15 Employer dashboard.
class EmployerDashboardScreen extends StatelessWidget {
  const new({super.key});

  static const _kpis = [
    ('Active vacancies', '4', '1 draft · 1 paused'),
    ('New applicants', '37', 'Last 7 days'),
    ('Pending review', '12', 'Oldest: 4 days'),
    ('Interviews', '5', 'This week'),
    ('Offers', '1', 'Awaiting reply'),
    ('Hires', '2', 'This quarter'),
  ];

  static const _vac = [
    ('Operations Analyst', 'Live', '1,240', '58', '9', '12 Dec'),
    ('Fleet Supervisor', 'Live', '860', '31', '4', '28 Nov'),
    ('Customer Service Rep', 'In review', '—', '—', '—', '—'),
    ('Warehouse Lead', 'Paused', '402', '19', '0', '15 Dec'),
  ];

  static const _funnel = [
    ('Applied', 108, 1.0),
    ('Reviewed', 74, 0.69),
    ('Shortlisted', 22, 0.2),
    ('Interviewed', 11, 0.1),
    ('Hired', 2, 0.02),
  ];

  @override
  Widget build(BuildContext context) {
    if (Env.hasSupabase) {
      return _employerShell(
        context,
        nav: 0,
        child: LiveEmployerGate(
          builder: (org) => LiveEmployerDashboard(org: org),
        ),
      );
    }
    final jm = context.jm;
    final type = context.type;

    (Color, Color) statusColors(String s) => switch (s) {
      'Live' => (jm.primarySoft, jm.onPrimarySoft),
      'In review' => (DTint.blue(context), DTint.blueText(context)),
      _ => (jm.surfaceSunken, jm.textMuted),
    };

    return _employerShell(
      context,
      nav: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DPhotoBackdrop(
              asset: DImages.handshake,
              alignment: const Alignment(0.3, 0),
              child: Padding(
                padding: EdgeInsets.all(DPage.isPhone(context) ? 22 : 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, Kobo Logistics',
                      style: type.small.copyWith(color: DTint.onDarkMuted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hiring overview',
                      style: type.h1.copyWith(
                        color: Colors.white,
                        fontSize: DPage.isPhone(context) ? 26 : 36,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '12 applicants are waiting for review. The oldest has waited 4 days.',
                      style: type.body.copyWith(color: DTint.onDarkMuted),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        DBtn(
                          '+ Post a vacancy',
                          style: DBtnStyle.white,
                          onTap: () => context.to(Routes.postVacancy),
                        ),
                        DBtn(
                          'Review applicants',
                          style: DBtnStyle.outlineLight,
                          onTap: () => context.to(Routes.pipeline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          DCard(
            color: jm.primarySoft,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(18),
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Verification status',
                  style: type.label.copyWith(fontWeight: FontWeight.w700),
                ),
                for (final c in [
                  'Email & domain verified',
                  'Business details reviewed',
                  'Authorised recruiter confirmed',
                ])
                  Text(
                    '✓ $c',
                    style: type.small.copyWith(color: jm.onPrimarySoft),
                  ),
                DPill('Verified employer · recheck Oct 2027', bg: jm.surface),
              ],
            ),
          ),
          const SizedBox(height: 20),
          DGrid(
            minItemWidth: 170,
            gap: 12,
            maxColumns: 6,
            children: [
              for (final (l, v, s) in _kpis)
                DCard(
                  radius: 18,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l,
                        style: type.caption.copyWith(
                          color: jm.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(v, style: type.h2.copyWith(fontSize: 28)),
                      Text(
                        s,
                        style: type.caption.copyWith(color: jm.textMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Vacancies', style: type.h4)),
                    DLink('All vacancies', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 8),
                DTable(
                  minWidth: 760,
                  columns: const [
                    ('Role', 4),
                    ('Status', 2),
                    ('Views', 2),
                    ('Applicants', 2),
                    ('New', 1),
                    ('Closes', 2),
                    ('Actions', 5),
                  ],
                  rows: [
                    for (final (role, status, views, apps, n, close) in _vac)
                      [
                        Text(
                          role,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Builder(
                          builder: (c) {
                            final (bg, fg) = statusColors(status);
                            return DPill(status, bg: bg, fg: fg);
                          },
                        ),
                        Text(views),
                        Text(apps),
                        Text(n),
                        Text(close),
                        Wrap(
                          spacing: 4,
                          children: [
                            DLink(
                              'Pipeline',
                              onTap: () => context.to(Routes.pipeline),
                            ),
                            DLink(
                              'Edit',
                              onTap: () => context.to(Routes.postVacancy),
                            ),
                            DLink(
                              'Duplicate',
                              onTap: () => showJmToast(
                                context,
                                'Draft copy of $role created',
                              ),
                            ),
                          ],
                        ),
                      ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          DGrid(
            minItemWidth: 320,
            gap: 20,
            maxColumns: 3,
            children: [
              DCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Upcoming interviews', style: type.h4),
                    const SizedBox(height: 10),
                    for (final (n, r, t) in [
                      (
                        'Amaka Okafor',
                        'Operations Analyst',
                        'Mon 24 Nov, 10:00',
                      ),
                      (
                        'Ibrahim Musa',
                        'Operations Analyst',
                        'Mon 24 Nov, 14:00',
                      ),
                      ('Chioma Eze', 'Fleet Supervisor', 'Wed 26 Nov, 11:00'),
                    ])
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: jm.border)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: n,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: ' · $r'),
                                ],
                              ),
                              style: type.small,
                            ),
                            Text(
                              t,
                              style: type.caption.copyWith(color: jm.textMuted),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              DCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Stage conversion · last 90 days', style: type.h4),
                    const SizedBox(height: 12),
                    for (final (l, v, w) in _funnel)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(l, style: type.small),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: w.clamp(0.04, 1.0),
                                  child: Container(
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: jm.primary.withValues(
                                        alpha: 0.25 + 0.75 * w,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$v',
                                textAlign: TextAlign.right,
                                style: type.label,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      'Time-to-fill shown once 5+ roles have closed.',
                      style: type.caption.copyWith(color: jm.textMuted),
                    ),
                  ],
                ),
              ),
              DCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Plan & billing', style: type.h4),
                    const SizedBox(height: 10),
                    Text(
                      'Employer Professional · renews 1 Jan 2027',
                      style: type.small,
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      const TextSpan(
                        children: [
                          TextSpan(text: 'Vacancy credits: '),
                          TextSpan(
                            text: '3 of 10 left',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: ' · Team seats: 3 of 5'),
                        ],
                      ),
                      style: type.small,
                    ),
                    const SizedBox(height: 10),
                    const DBar(0.3),
                    const SizedBox(height: 12),
                    DLink(
                      'Manage plan & invoices',
                      onTap: () => context.to(Routes.pricing),
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

/// 16 Post a vacancy.
class PostVacancyScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<PostVacancyScreen> createState() => _PostVacancyScreenState();
}

class _PostVacancyScreenState extends State<PostVacancyScreen> {
  Widget _live() => DPage(
    active: NavItem.hire,
    mode: NavMode.employer,
    mobileTitle: 'New vacancy',
    mobileBody: Padding(
      padding: const EdgeInsets.all(16),
      child: LiveEmployerGate(builder: (org) => LivePostVacancy(org: org)),
    ),
    body: DContainer(
      maxWidth: 1320,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
      child: LiveEmployerGate(builder: (org) => LivePostVacancy(org: org)),
    ),
  );

  int _section = 4;
  final _title = TextEditingController(text: 'Operations Analyst');
  String _category = 'Operations & Logistics';
  String _jobType = 'Full-time';
  String _arrangement = 'Hybrid';

  static const _sections = [
    'Basics',
    'Description',
    'Requirements',
    'Pay & benefits',
    'Screening questions',
    'Application method',
    'Promotion (optional)',
  ];
  static const _qs = [
    (
      'Can you work on-site in Yaba 3 days a week?',
      'Yes / No',
      'Knock-out: flag if No',
      true,
    ),
    (
      'How many years of operations experience do you have?',
      'Number',
      'Preferred: 1+',
      false,
    ),
    ('What is your earliest start date?', 'Date', 'Info only', false),
  ];

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Env.hasSupabase) return _live();
    final jm = context.jm;
    final type = context.type;

    final steps = DCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, s) in _sections.indexed)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _section = i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: i == _section ? jm.primarySoft : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${i < 4 ? '✓' : '${i + 1}'}  $s',
                  style: type.small.copyWith(
                    fontWeight: i == _section
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: i < 4 ? jm.onPrimarySoft : jm.text,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final basics = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Basics', style: type.h3),
          const SizedBox(height: 16),
          DGrid(
            minItemWidth: 240,
            gap: 16,
            maxColumns: 2,
            children: [
              DField(label: 'Job title', controller: _title),
              DSelect<String>(
                label: 'Job category',
                value: _category,
                items: const [
                  'Operations & Logistics',
                  'Finance & Accounting',
                  'Technology',
                  'Sales',
                ],
                onChanged: (v) => setState(() => _category = v),
              ),
              DSelect<String>(
                label: 'Job type',
                value: _jobType,
                items: const [
                  'Full-time',
                  'Part-time',
                  'Contract',
                  'Internship',
                  'NYSC',
                ],
                onChanged: (v) => setState(() => _jobType = v),
              ),
              DSelect<String>(
                label: 'Work arrangement',
                value: _arrangement,
                items: const ['On-site', 'Hybrid', 'Remote'],
                onChanged: (v) => setState(() => _arrangement = v),
              ),
              const DField(label: 'Location', initial: 'Yaba, Lagos'),
              const DField(label: 'Closing date', initial: '12 Dec 2026'),
            ],
          ),
        ],
      ),
    );

    final screening = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            children: [
              Text('Screening questions', style: type.h3),
              Text(
                'Up to 5 · keep them job-related',
                style: type.small.copyWith(color: jm.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final (text, kind, rule, ko) in _qs)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: jm.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(text, style: type.label),
                  ),
                  DTag(kind),
                  DPill(
                    rule,
                    radius: 6,
                    bg: ko ? jm.errorSoft : jm.surfaceSunken,
                    fg: ko
                        ? (jm.isDark ? jm.error : const Color(0xFF9A2A12))
                        : jm.textMuted,
                  ),
                  DLink('Edit', onTap: () {}),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: DBtn(
              '+ Add question',
              style: DBtnStyle.secondary,
              height: 40,
              fontSize: 14,
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          DNotice(
            bg: DTint.blue(context),
            child: const Text(
              'Knock-out questions auto-flag, never auto-reject. Candidates can request an accessible alternative.',
            ),
          ),
        ],
      ),
    );

    final preview = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE PREVIEW',
                style: type.overline.copyWith(color: jm.textMuted),
              ),
              const SizedBox(height: 10),
              Text(
                _title.text.isEmpty ? 'Job title' : _title.text,
                style: type.h4,
              ),
              Text(
                'Kobo Logistics · Yaba, Lagos · $_arrangement',
                style: type.small.copyWith(color: jm.textMuted),
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  DVerifiedPill('Verified employer'),
                  DTag('₦350k–₦450k'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Closes 12 Dec 2026',
                style: type.caption.copyWith(color: jm.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Before review', style: type.h4),
              const SizedBox(height: 10),
              for (final (ok, t) in [
                (true, 'No fees requested from candidates'),
                (true, 'Official contact route'),
                (true, 'Salary range disclosed'),
                (false, 'Add 1+ benefit (recommended)'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${ok ? '✓' : '!'} $t',
                    style: type.small.copyWith(
                      color: ok ? jm.onPrimarySoft : jm.onAccentSoft,
                      fontWeight: ok ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                'Our team reviews new vacancies, usually within 1 working day.',
                style: type.caption.copyWith(color: jm.textMuted),
              ),
            ],
          ),
        ),
      ],
    );

    return DPage(
      active: NavItem.hire,
      mode: NavMode.employer,
      mobileTitle: 'New vacancy',
      mobileBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            basics,
            const SizedBox(height: 16),
            screening,
            const SizedBox(height: 16),
            preview,
          ],
        ),
      ),
      body: DContainer(
        maxWidth: 1320,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: DLink(
                '← Overview',
                onTap: () => context.to(Routes.employer),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New vacancy', style: type.h1.copyWith(fontSize: 30)),
                    Text(
                      'Draft saved 09:41 · Uses 1 vacancy credit when published',
                      style: type.small.copyWith(color: jm.textMuted),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    DBtn(
                      'Save draft',
                      style: DBtnStyle.secondary,
                      onTap: () => showJmToast(context, 'Draft saved'),
                    ),
                    DBtn('Preview', style: DBtnStyle.secondary, onTap: () {}),
                    DBtn(
                      'Submit for review',
                      onTap: () => showJmToast(
                        context,
                        'Submitted. Our team usually reviews within 1 working day.',
                        tone: JmTone.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, c) {
                final form = Column(
                  children: [basics, const SizedBox(height: 16), screening],
                );
                if (c.maxWidth < 1100) {
                  return Column(
                    children: [
                      steps,
                      const SizedBox(height: 16),
                      form,
                      const SizedBox(height: 16),
                      preview,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 230, child: steps),
                    const SizedBox(width: 20),
                    Expanded(child: form),
                    const SizedBox(width: 20),
                    SizedBox(width: 320, child: preview),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Cand {
  const new(this.name, this.meta, [this.flag = '']);
  final String name;
  final String meta;
  final String flag;
}

/// 17 Applicant pipeline (M15 on phones). Drag cards between stages; the
/// stage menu in the drawer is the keyboard / screen-reader alternative.
class PipelineScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  final Map<String, List<_Cand>> _cols = {
    'New': [
      const _Cand('Ifeoma N.', '3 yrs · Lagos'),
      const _Cand('Segun B.', '1 yr · Ogun', '! On-site: No'),
      const _Cand('Halima Y.', 'Graduate · Lagos'),
    ],
    'Under review': [
      const _Cand('David O.', '4 yrs · Lagos'),
      const _Cand('Grace A.', '2 yrs · Lagos'),
    ],
    'Shortlisted': [
      const _Cand('Ibrahim M.', '3 yrs · Lagos'),
      const _Cand('Ngozi K.', '2 yrs · Remote'),
    ],
    'Assessment': [const _Cand('Kunle F.', '2 yrs · Lagos', 'Test sent')],
    'Interview': [
      const _Cand('Amaka O.', '2 yrs · Lagos', 'Mon 10:00'),
      const _Cand('Ibrahim M.', '3 yrs · Lagos', 'Mon 14:00'),
    ],
    'Offer': [],
    'Hired': [],
  };
  final Map<String, int> _counts = {
    'New': 9,
    'Under review': 12,
    'Shortlisted': 6,
    'Assessment': 3,
    'Interview': 2,
    'Offer': 0,
    'Hired': 0,
  };
  _Cand? _selected = const _Cand('Amaka O.', '2 yrs · Lagos', 'Mon 10:00');
  String _filter = 'All applicants';
  int _mobileStage = 0;

  String _stageOf(_Cand c) => _cols.entries
      .firstWhere(
        (e) => e.value.contains(c),
        orElse: () => const MapEntry('Interview', []),
      )
      .key;

  void _move(_Cand c, String to) {
    final from = _stageOf(c);
    if (from == to) return;
    setState(() {
      _counts[from] = (_counts[from]! - 1).clamp(0, 9999);
      _counts[to] = _counts[to]! + 1;
      for (final l in _cols.values) {
        l.remove(c);
      }
      _cols[to]!.insert(0, c);
    });
    showJmToast(context, '${c.name} moved to $to', tone: JmTone.success);
  }

  Widget _card(_Cand c, {bool dragging = false}) {
    final jm = context.jm;
    final type = context.type;
    final sel = _selected == c;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _selected = c),
        child: Container(
          width: 196,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: jm.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? jm.primary : jm.border,
              width: sel ? 2 : 1,
            ),
            boxShadow: dragging ? jm.shadowLg : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                style: type.label.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(c.meta, style: type.caption.copyWith(color: jm.textMuted)),
              if (c.flag.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  c.flag,
                  style: type.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.flag.startsWith('!')
                        ? (jm.isDark ? jm.error : const Color(0xFF9A2A12))
                        : jm.onPrimarySoft,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawer() {
    final jm = context.jm;
    final type = context.type;
    final c = _selected;
    if (c == null) return const SizedBox.shrink();
    return DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DInitials(
                c.name.split(' ').map((p) => p[0]).join(),
                size: 48,
                circle: true,
                bg: jm.accentSoft,
                fg: jm.onAccentSoft,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name == 'Amaka O.' ? 'Amaka Okafor' : c.name,
                      style: type.h4,
                    ),
                    Text(
                      'Applied 18 Nov · via job alert',
                      style: type.caption.copyWith(color: jm.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => setState(() => _selected = null),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DSelect<String>(
            label: 'Stage',
            value: _stageOf(c),
            items: _cols.keys.toList(),
            onChanged: (v) => _move(c, v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              DBtn(
                'View CV',
                style: DBtnStyle.secondary,
                height: 40,
                fontSize: 14,
                onTap: () {},
              ),
              DBtn(
                'Full profile',
                style: DBtnStyle.secondary,
                height: 40,
                fontSize: 14,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Screening answers',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final (k, v) in [
            ('On-site 3 days', 'Yes'),
            ('Operations experience', '2 years'),
            ('Earliest start', '5 Jan 2027'),
          ])
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$k: '),
                  TextSpan(
                    text: v,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              style: type.small.copyWith(height: 1.7),
            ),
          const SizedBox(height: 14),
          Text(
            'Team notes (internal)',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: jm.accentSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Strong Excel sample. Probe SQL learning plan. – Tunde A.',
              style: type.small,
            ),
          ),
          const SizedBox(height: 8),
          const TextField(
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a note…',
              labelText: 'Add a note',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Activity',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final a in [
            '19 Nov · Interview invite sent (template)',
            '18 Nov · Moved to Shortlisted by Tunde A.',
            '18 Nov · Applied',
          ])
            Text(
              a,
              style: type.caption.copyWith(color: jm.textMuted, height: 1.8),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DBtn(
                'Schedule interview',
                onTap: () => showJmToast(
                  context,
                  'Interview scheduling opens with your team calendar.',
                ),
              ),
              DBtn(
                'Reject…',
                style: DBtnStyle.danger,
                onTap: () => showJmDialog(
                  context: context,
                  title: 'Not progress ${c.name}?',
                  message: 'Choose a reason and an approved message template. Decisions are made by your team, never by an AI score.',
                  confirmLabel: 'Continue',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Env.hasSupabase) {
      return _employerShell(
        context,
        nav: 2,
        child: LiveEmployerGate(builder: (org) => LivePipeline(org: org)),
      );
    }
    final jm = context.jm;
    final type = context.type;
    final phone = DPage.isPhone(context);

    if (phone) {
      final stages = ['New', 'Under review', 'Shortlisted', 'Interview'];
      final stage = stages[_mobileStage];
      return Scaffold(
        backgroundColor: jm.background,
        appBar: AppBar(
          backgroundColor: jm.surface,
          title: const Text('Employer · Kobo Logistics'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DSelect<String>(
              label: 'Vacancy',
              value: 'Operations Analyst (58)',
              items: const ['Operations Analyst (58)', 'Fleet Supervisor (31)'],
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (i, s) in stages.indexed)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: DChoicePill(
                        label:
                            '${s.replaceAll('Under ', '').replaceAll('listed', 'list')} ${_counts[s]}',
                        selected: i == _mobileStage,
                        onTap: () => setState(() => _mobileStage = i),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final c in _cols[stage]!)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          DInitials(
                            c.name.split(' ').map((p) => p[0]).join(),
                            size: 40,
                            circle: true,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: type.label.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  c.meta,
                                  style: type.caption.copyWith(
                                    color: jm.textMuted,
                                  ),
                                ),
                                if (c.flag.isNotEmpty)
                                  Text(
                                    c.flag,
                                    style: type.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: c.flag.startsWith('!')
                                          ? jm.error
                                          : jm.onPrimarySoft,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          DLink('View CV', onTap: () {}),
                          const Spacer(),
                          DBtn(
                            'Shortlist',
                            height: 40,
                            fontSize: 14,
                            onTap: () => _move(c, 'Shortlisted'),
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            tooltip: 'Not progressing',
                            onPressed: () => showJmDialog(
                              context: context,
                              title: 'Not progress ${c.name}?',
                              message: 'Choose a reason and an approved message template. Decisions are made by your team, never by an AI score.',
                              confirmLabel: 'Continue',
                            ),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 2,
          onDestinationSelected: (i) => context.to(
            [
              Routes.employer,
              Routes.postVacancy,
              Routes.pipeline,
              Routes.inbox,
              Routes.employer,
            ][i],
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline_rounded),
              label: 'Vacancies',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              label: 'Applicants',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_rounded),
              label: 'More',
            ),
          ],
        ),
      );
    }

    final board = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in _cols.entries)
            DragTarget<_Cand>(
              onWillAcceptWithDetails: (d) => !e.value.contains(d.data),
              onAcceptWithDetails: (d) => _move(d.data, e.key),
              builder: (context, incoming, _) => Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(minHeight: 360),
                decoration: BoxDecoration(
                  color: incoming.isNotEmpty
                      ? jm.primarySoft
                      : jm.surfaceSunken,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: incoming.isNotEmpty
                        ? jm.primary
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            style: type.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        DPill(
                          '${_counts[e.key]}',
                          bg: jm.surface,
                          fg: jm.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final c in e.value)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Draggable<_Cand>(
                          data: c,
                          feedback: Transform.rotate(
                            angle: 0.03,
                            child: _card(c, dragging: true),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.35,
                            child: _card(c),
                          ),
                          child: _card(c),
                        ),
                      ),
                    if (e.value.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Drop candidates here',
                          style: type.caption.copyWith(color: jm.textMuted),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    return DPage(
      active: NavItem.hire,
      mode: NavMode.employer,
      body: DContainer(
        maxWidth: 1400,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: DLink(
                '← Vacancies',
                onTap: () => context.to(Routes.employer),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Text(
                  'Operations Analyst · 58 applicants',
                  style: type.h1.copyWith(fontSize: 28),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      child: DSelect<String>(
                        label: 'Filter',
                        showLabel: false,
                        height: 44,
                        value: _filter,
                        items: const ['All applicants', 'Flagged by screening'],
                        onChanged: (v) => setState(() => _filter = v),
                      ),
                    ),
                    DBtn(
                      'Configure stages',
                      style: DBtnStyle.secondary,
                      height: 44,
                      onTap: () {},
                    ),
                    DBtn(
                      'Message selected',
                      height: 44,
                      onTap: () => showJmToast(
                        context,
                        'Bulk messages use approved templates only.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, c) {
                if (c.maxWidth < 1100 || _selected == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      board,
                      if (_selected != null) ...[
                        const SizedBox(height: 16),
                        _drawer(),
                      ],
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: board),
                    const SizedBox(width: 16),
                    SizedBox(width: 360, child: _drawer()),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Also: Reference check (0) · Rejected (14) · Withdrawn (2) — drag cards between stages, or use the stage menu.',
              style: type.caption.copyWith(color: jm.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// 18 Public employer profile.
class EmployerProfileScreen extends StatefulWidget {
  const new({required this.slug, super.key});

  final String slug;

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  int _tab = 0;
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    if (Env.hasSupabase) {
      return DPage(
        active: NavItem.hire,
        footer: true,
        mobileTitle: 'Company',
        mobileBody: Padding(
          padding: const EdgeInsets.all(16),
          child: LiveEmployerProfile(slug: widget.slug),
        ),
        body: DContainer(
          maxWidth: 1200,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
          child: LiveEmployerProfile(slug: widget.slug),
        ),
      );
    }
    final jm = context.jm;
    final type = context.type;

    final header = Container(
      decoration: BoxDecoration(
        color: jm.surface,
        border: Border(bottom: BorderSide(color: jm.border)),
      ),
      child: DContainer(
        maxWidth: 1200,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DPhoto(
              DImages.teamMeeting,
              radius: 24,
              height: DPage.isPhone(context) ? 150 : 260,
              alignment: const Alignment(0, -0.3),
              shadow: false,
              semanticLabel: 'The Kobo Logistics team in a planning meeting',
            ),
            Transform.translate(
              offset: const Offset(24, -40),
              child: Align(
                alignment: Alignment.topLeft,
                heightFactor: 0.62,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: jm.surface,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: DInitials(
                    'KL',
                    size: 84,
                    bg: jm.accentSoft,
                    fg: jm.onAccentSoft,
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 20,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kobo Logistics Ltd',
                        style: type.h1.copyWith(fontSize: 32),
                      ),
                      Text(
                        'Last-mile delivery · Lagos, Ogun, Oyo · 51–200 employees',
                        style: type.body.copyWith(color: jm.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const DVerifiedPill('Verified employer'),
                          DLink(
                            'What does this mean?',
                            onTap: () => setState(() => _tab = 0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    DBtn(
                      _following ? 'Following' : 'Follow',
                      style: _following
                          ? DBtnStyle.secondary
                          : DBtnStyle.primary,
                      icon: _following
                          ? Icons.check_rounded
                          : Icons.add_rounded,
                      onTap: () => setState(() => _following = !_following),
                    ),
                    DBtn(
                      'Share',
                      style: DBtnStyle.secondary,
                      icon: Icons.ios_share_rounded,
                      onTap: () => showJmToast(context, 'Link copied'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            DTabs(
              tabs: const ['About', 'Open roles (4)', 'Updates', 'Reviews (3)'],
              current: _tab,
              onTap: (i) => setState(() => _tab = i),
            ),
          ],
        ),
      ),
    );

    final about = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About us', style: type.h3),
          const SizedBox(height: 10),
          Text(
            "We deliver parcels for online sellers across south-west Nigeria with a fleet of bikes and vans. We're building a team that uses data to make every delivery faster and more reliable.",
            style: type.body.copyWith(height: 1.6),
          ),
          const SizedBox(height: 16),
          Text('Culture & values', style: type.h4),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in [
                'Ownership',
                'Learning budget',
                'Hybrid roles',
                'HMO from day one',
              ])
                DTag(v),
            ],
          ),
        ],
      ),
    );

    final roles = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Open roles', style: type.h3)),
              DLink('See all', onTap: () => context.to(Routes.jobs)),
            ],
          ),
          const SizedBox(height: 10),
          for (final (t, m) in [
            ('Operations Analyst', 'Lagos · Hybrid · closes 12 Dec'),
            ('Fleet Supervisor', 'Ikeja · On-site · closes 28 Nov'),
          ])
            InkWell(
              onTap: () => context.to(Routes.jobDetail('operations-analyst')),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: jm.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t,
                            style: type.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            m,
                            style: type.caption.copyWith(
                              color: jm.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DLink(
                      'View',
                      onTap: () =>
                          context.to(Routes.jobDetail('operations-analyst')),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    final reviews = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            children: [
              Text('Reviews', style: type.h3),
              Text(
                'Moderated · only from verified applicants or staff',
                style: type.caption.copyWith(color: jm.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: jm.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Former applicant · Interview experience · Oct 2026',
                  style: type.caption.copyWith(color: jm.textMuted),
                ),
                const SizedBox(height: 6),
                Text(
                  'Clear process and quick feedback after the interview. The assessment was relevant to the role.',
                  style: type.body.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: jm.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Response from Kobo Logistics: ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: 'Thank you – we aim to reply to every candidate within 10 days.',
                        ),
                      ],
                    ),
                    style: type.small,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DBtn(
                'Write a review',
                style: DBtnStyle.secondary,
                onTap: () => showJmToast(
                  context,
                  'Reviews are checked by our team before they appear.',
                ),
              ),
              DBtn(
                'Report this employer',
                style: DBtnStyle.ghost,
                icon: Icons.flag_outlined,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );

    final details = Column(
      children: [
        DCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Company details', style: type.h4),
              const SizedBox(height: 10),
              for (final (k, v) in [
                ('Industry', 'Logistics & delivery'),
                ('Founded', '2019'),
                ('Operates in', 'Lagos, Ogun, Oyo'),
                ('Website', 'kobologistics.example'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        k,
                        style: type.caption.copyWith(color: jm.textMuted),
                      ),
                      Text(
                        v,
                        style: type.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DCard(
          color: jm.primarySoft,
          borderColor: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Verification checks', style: type.h4),
              const SizedBox(height: 10),
              for (final c in [
                'Business email & domain verified',
                'CAC registration reviewed',
                'Authorised recruiter confirmed',
              ])
                Text(
                  '✓ $c',
                  style: type.small.copyWith(
                    color: jm.onPrimarySoft,
                    height: 1.8,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Verified 2 Oct 2026 by JobsAndMore. Verification is not an endorsement of every job or practice.',
                style: type.caption.copyWith(color: jm.textMuted),
              ),
            ],
          ),
        ),
      ],
    );

    return DPage(
      active: NavItem.jobs,
      mobileTitle: 'Kobo Logistics',
      footer: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          DContainer(
            maxWidth: 1200,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
            child: DSplit(
              asideWidth: 340,
              main: Column(
                children: [
                  if (_tab == 0) ...[
                    about,
                    const SizedBox(height: 16),
                    roles,
                    const SizedBox(height: 16),
                    reviews,
                  ],
                  if (_tab == 1) roles,
                  if (_tab == 2)
                    DCard(
                      child: Text(
                        'Company updates will appear here.',
                        style: type.body.copyWith(color: jm.textMuted),
                      ),
                    ),
                  if (_tab == 3) reviews,
                ],
              ),
              aside: details,
            ),
          ),
        ],
      ),
    );
  }
}
