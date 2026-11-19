import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

class _Plan {
  const new(
    this.name,
    this.who,
    this.price,
    this.per,
    this.features,
    this.cta, {
    this.popular = false,
  });
  final String name;
  final String who;
  final String price;
  final String per;
  final List<String> features;
  final String cta;
  final bool popular;
}

/// 23 Plans & pricing. Prices are configured by admins (plans table); the
/// "[₦ price]" values below are the design's placeholders until confirmed.
class PricingScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  int _tab = 1;

  static const _audiences = [
    'Job Seekers',
    'Employers',
    'Business Owners',
    'Training Providers',
  ];
  static const _sets = <List<_Plan>>[
    [
      _Plan('Starter', 'Everyone looking for work', 'Free', '', [
        'Career profile & applications',
        'Job alerts by email & app',
        '10 AI credits / month',
        'Selected free courses',
      ], 'Get started free'),
      _Plan(
        'Career Plus',
        'Active job seekers & graduates',
        '[₦ price]',
        '/ month',
        [
          'Everything in Starter',
          'Expanded AI credits',
          'Multiple CV versions & advanced CV analysis',
          'Career roadmap & interview coach',
          'Premium course discounts',
        ],
        'Try Career Plus',
        popular: true,
      ),
    ],
    [
      _Plan('Starter', 'Trial & occasional hiring', 'Free', '', [
        'Basic company profile',
        '1 active vacancy',
        'Applicant list for that role',
        'Email support',
      ], 'Start free'),
      _Plan(
        'Employer Professional',
        'SMEs and growing teams',
        '[₦ price]',
        '/ month',
        [
          '10 vacancy credits / month',
          'Full ATS pipeline & screening',
          '5 team seats',
          'Analytics & branded page',
        ],
        'Choose Professional',
        popular: true,
      ),
      _Plan(
        'Employer Enterprise',
        'Large organisations & agencies',
        'Custom',
        '',
        [
          'Unlimited seats & permissions',
          'Candidate search',
          'Integrations & reporting',
          'Dedicated support',
        ],
        'Talk to sales',
      ),
    ],
    [
      _Plan('Starter', 'New & small businesses', 'Free', '', [
        'Basic business profile',
        'Selected resources',
        'Service enquiries',
        'Limited directory access',
      ], 'Start free'),
      _Plan(
        'Business Growth',
        'SMEs and founders',
        '[₦ price]',
        '/ month',
        [
          'Enhanced showcase listing',
          'Opportunity alerts',
          'Premium business courses',
          'Priority consultancy access',
        ],
        'Choose Growth',
        popular: true,
      ),
    ],
    [
      _Plan('Pilot', 'Approved new providers', 'Free', '', [
        'Provider profile',
        'Up to 2 course listings',
        'Basic learner list',
      ], 'Apply as provider'),
      _Plan(
        'Provider Pro',
        'Training organisations',
        '[₦ price]',
        '/ month',
        [
          'Paid course sales',
          'Cohorts & bulk enrolment',
          'Learner analytics',
          'Certificate workflows',
        ],
        'Choose Provider Pro',
        popular: true,
      ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final plans = _sets[_tab];

    Widget planCard(_Plan p) => Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: jm.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: p.popular ? jm.primary : jm.border,
          width: p.popular ? 2 : 1,
        ),
        boxShadow: p.popular
            ? [
                BoxShadow(
                  color: jm.primary.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (p.popular) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: DPill('Most popular', bg: jm.primary, fg: jm.onPrimary),
            ),
            const SizedBox(height: 12),
          ],
          Text(p.name, style: type.h3),
          Text(p.who, style: type.small.copyWith(color: jm.textMuted)),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: p.price, style: type.h1.copyWith(fontSize: 34)),
                if (p.per.isNotEmpty)
                  TextSpan(
                    text: ' ${p.per}',
                    style: type.body.copyWith(color: jm.textMuted),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final f in p.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_rounded, size: 18, color: jm.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f, style: type.small)),
                ],
              ),
            ),
          const SizedBox(height: 14),
          DBtn(
            p.cta,
            expand: true,
            style: p.popular ? DBtnStyle.primary : DBtnStyle.secondary,
            onTap: () => context.to(Routes.getStarted),
          ),
        ],
      ),
    );

    return DPage(
      active: NavItem.resources,
      footer: true,
      mobileTitle: 'Plans',
      body: DContainer(
        maxWidth: 1100,
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Plans that grow with you.',
              textAlign: TextAlign.center,
              style: type.h1.copyWith(
                fontSize: DPage.isPhone(context) ? 32 : 52,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The free plan stays genuinely useful. Upgrade only when you need more.',
              textAlign: TextAlign.center,
              style: type.bodyL.copyWith(color: jm.textMuted),
            ),
            const SizedBox(height: 24),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: jm.surface,
                    border: Border.all(color: jm.border),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final (i, a) in _audiences.indexed)
                        Semantics(
                          selected: i == _tab,
                          button: true,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => setState(() => _tab = i),
                            child: AnimatedContainer(
                              duration: JmMotion.micro,
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: i == _tab ? jm.primary : null,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Center(
                                widthFactor: 1,
                                child: Text(
                                  a,
                                  style: type.label.copyWith(
                                    color: i == _tab ? jm.onPrimary : jm.text,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            DGrid(
              minItemWidth: 280,
              gap: 20,
              maxColumns: 3,
              children: [for (final p in plans) planCard(p)],
            ),
            const SizedBox(height: 24),
            Text(
              'Prices and entitlements are placeholders pending commercial testing. Payments are processed by a secure payment provider; we never store card details. VAT receipts are issued for every payment.',
              textAlign: TextAlign.center,
              style: type.caption.copyWith(color: jm.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 40),
            DGrid(
              minItemWidth: 280,
              gap: 16,
              maxColumns: 3,
              children: [
                for (final (q, a) in [
                  (
                    'Can I cancel anytime?',
                    'Yes. You keep paid features until the end of your billing period.',
                  ),
                  (
                    'Are sponsored jobs labelled?',
                    'Always. Paid placement never appears as organic relevance.',
                  ),
                  (
                    'Refunds?',
                    'See our refund policy; unused vacancy credits are handled case by case.',
                  ),
                ])
                  DCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q,
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a,
                          style: type.small.copyWith(color: jm.textMuted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 40),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: DPhotoBackdrop(
                asset: DImages.teamMeeting,
                alignment: const Alignment(0, -0.2),
                child: Padding(
                  padding: EdgeInsets.all(DPage.isPhone(context) ? 24 : 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DEyebrow('Enterprise', color: JmBrand.amber),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Text(
                          'Hiring for a large team or several branches?',
                          style: type.h2.copyWith(
                            color: Colors.white,
                            fontSize: DPage.isPhone(context) ? 26 : 34,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Text(
                          'Get unlimited seats, candidate search and reporting, with a dedicated contact for your account.',
                          style: type.body.copyWith(color: DTint.onDarkMuted),
                        ),
                      ),
                      const SizedBox(height: 22),
                      DBtn(
                        'Talk to sales',
                        style: DBtnStyle.white,
                        onTap: () => context.to(Routes.getStarted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 24 Admin – verification queue. Every decision needs a reason and is logged.
class AdminVerificationScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  int _row = 0;
  String _typeFilter = 'All types';
  String _status = 'Awaiting review';
  String _decision = 'Request more information';
  final _checks = <String>{'Business registration reviewed'};
  final _reason = TextEditingController(
    text: 'Please verify a phone call with the signatory on the letter of authority, or provide a business email address.',
  );

  static const _rows = [
    (
      'Sunrise Staffing Ltd',
      'Employer',
      '18 Nov',
      'Free email domain',
      'Due today',
    ),
    ("Tola's Bakery", 'Business', '18 Nov', '—', '1 day'),
    ('BrightPath Training', 'Provider', '17 Nov', '—', 'Due today'),
    ('Ayo Software Studio', 'Employer', '16 Nov', 'Info requested', 'Paused'),
  ];

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final selected = _rows[_row];

    final nav = Container(
      decoration: BoxDecoration(
        color: JmBrand.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (n, c)) in [
            ('Dashboard', ''),
            ('Users', ''),
            ('Verification', '14'),
            ('Job moderation', '6'),
            ('Content', ''),
            ('Courses', ''),
            ('Payments', ''),
            ('Rewards', ''),
            ('Support desk', ''),
            ('Reports', ''),
            ('Settings', ''),
          ].indexed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: i == 2 ? Colors.white.withValues(alpha: 0.12) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      n,
                      style: type.small.copyWith(
                        color: Colors.white,
                        fontWeight: i == 2 ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (c.isNotEmpty)
                    DPill(c, bg: JmBrand.amber, fg: JmBrand.ink, fontSize: 11),
                ],
              ),
            ),
        ],
      ),
    );

    final queue = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Text('Verification queue', style: type.h2.copyWith(fontSize: 26)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: 170,
                    child: DSelect<String>(
                      label: 'Type',
                      showLabel: false,
                      height: 42,
                      value: _typeFilter,
                      items: const [
                        'All types',
                        'Employers',
                        'Businesses',
                        'Training providers',
                      ],
                      onChanged: (v) => setState(() => _typeFilter = v),
                    ),
                  ),
                  SizedBox(
                    width: 190,
                    child: DSelect<String>(
                      label: 'Status',
                      showLabel: false,
                      height: 42,
                      value: _status,
                      items: const [
                        'Awaiting review',
                        'Info requested',
                        'Decided',
                      ],
                      onChanged: (v) => setState(() => _status = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          DTable(
            selectedRow: _row,
            onRowTap: (i) => setState(() => _row = i),
            columns: const [
              ('Organisation', 4),
              ('Type', 2),
              ('Submitted', 2),
              ('Flags', 3),
              ('SLA', 2),
            ],
            rows: [
              for (final (o, t, s, f, sla) in _rows)
                [
                  Text(o, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(t),
                  Text(s),
                  if (f == '—')
                    const Text('—')
                  else
                    DPill(f, bg: jm.accentSoft, fg: jm.onAccentSoft),
                  Text(
                    sla,
                    style: TextStyle(
                      color: sla == 'Due today' ? jm.error : jm.text,
                      fontWeight: sla == 'Due today'
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
            ],
          ),
        ],
      ),
    );

    final review = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(selected.$1, style: type.h3),
          const SizedBox(height: 10),
          for (final l in [
            'Contact: Musa D., HR Manager',
            'Email: sunrise.staffing@[free-mail].com · free domain',
            'Website: none provided',
            'RC number: RC-XXXXXXX',
          ])
            Text(l, style: type.small.copyWith(height: 1.7)),
          const SizedBox(height: 14),
          Text(
            'Evidence',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          DLink('CAC certificate.pdf (scanned, clean)', onTap: () {}),
          DLink('Letter of authority.pdf (scanned, clean)', onTap: () {}),
          const SizedBox(height: 14),
          Text(
            'Audit trail',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          for (final a in [
            '18 Nov 10:14 · Submitted by Musa D.',
            '18 Nov 10:15 · Auto-flag: free email domain',
          ])
            Text(
              a,
              style: type.caption.copyWith(color: jm.textMuted, height: 1.8),
            ),
          const SizedBox(height: 14),
          Text(
            'Checks passed',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final c in [
            'Email / domain verified',
            'Business registration reviewed',
            'Authorised representative confirmed',
          ])
            DCheck(
              value: _checks.contains(c),
              onChanged: (v) =>
                  setState(() => v ? _checks.add(c) : _checks.remove(c)),
              label: Text(c),
            ),
          const SizedBox(height: 14),
          DSelect<String>(
            label: 'Decision',
            value: _decision,
            items: const [
              'Request more information',
              'Approve – Business details reviewed',
              'Approve – Verified employer',
              'Reject',
            ],
            onChanged: (v) => setState(() => _decision = v),
          ),
          const SizedBox(height: 14),
          DField(
            label: 'Reason (required, sent to applicant)',
            controller: _reason,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DBtn(
            'Record decision',
            expand: true,
            onTap: () {
              if (_reason.text.trim().isEmpty) {
                showJmToast(
                  context,
                  'A reason is required for every decision.',
                  tone: JmTone.error,
                );
                return;
              }
              if (_decision == 'Approve – Verified employer' &&
                  _checks.length < 3) {
                showJmToast(
                  context,
                  '"Verified employer" needs all three checks passed.',
                  tone: JmTone.warning,
                );
                return;
              }
              showJmToast(
                context,
                'Decision recorded and added to the audit log.',
                tone: JmTone.success,
              );
            },
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: jm.background,
      appBar: AppBar(
        backgroundColor: JmBrand.ink,
        foregroundColor: Colors.white,
        title: Text(
          'JobsAndMore Admin',
          style: type.h4.copyWith(color: Colors.white),
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width >= 700)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Bisi K. · Verification Officer · MFA on',
                  style: type.small.copyWith(color: DTint.footerMuted),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 1100) {
              return Column(
                children: [queue, const SizedBox(height: 16), review],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 220, child: nav),
                const SizedBox(width: 20),
                Expanded(child: queue),
                const SizedBox(width: 20),
                SizedBox(width: 400, child: review),
              ],
            );
          },
        ),
      ),
    );
  }
}
