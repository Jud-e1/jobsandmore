import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

/// 11 Career Tools hub.
class CareerToolsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;

    Widget tool(
      IconData icon,
      Color bg,
      String name,
      String desc,
      String cost,
      String? route,
    ) => DCard(
      padding: const EdgeInsets.all(22),
      semanticLabel: '$name. $desc. $cost',
      onTap: () => route == null
          ? showJmToast(context, '$name opens in a later release.')
          : context.to(route),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DIconTile(icon, size: 52, bg: bg, fg: jm.text),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: type.label.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: type.small.copyWith(color: jm.textMuted, height: 1.45),
                ),
                const SizedBox(height: 8),
                Text(
                  cost,
                  style: type.caption.copyWith(
                    color: jm.onPrimarySoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget group(String title, List<Widget> tools) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text(title, style: type.h3)),
        const SizedBox(height: 14),
        DGrid(minItemWidth: 320, maxColumns: 2, children: tools),
        const SizedBox(height: 32),
      ],
    );

    final green = jm.primarySoft;
    final amber = jm.accentSoft;
    return DPage(
      active: NavItem.tools,
      mode: NavMode.seeker,
      mobileTitle: 'Career Tools',
      body: DContainer(
        maxWidth: 1200,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: DPhotoBackdrop(
                asset: DImages.womanDesk,
                alignment: const Alignment(0.7, -0.3),
                child: Padding(
                  padding: EdgeInsets.all(DPage.isPhone(context) ? 24 : 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DEyebrow('Career Tools', color: JmBrand.amber),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          'Your CV, interviews and next move – sharper.',
                          style: type.h1.copyWith(
                            color: Colors.white,
                            fontSize: DPage.isPhone(context) ? 28 : 42,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          'AI-assisted tools that use your career profile. You can edit, reject or regenerate anything they suggest.',
                          style: type.body.copyWith(color: DTint.onDarkMuted),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text.rich(
                              const TextSpan(
                                children: [
                                  TextSpan(
                                    text: '7 of 10',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' AI credits left this month · ',
                                  ),
                                ],
                              ),
                              style: type.small.copyWith(
                                color: DTint.onDarkMuted,
                              ),
                            ),
                            DLink(
                              'Upgrade',
                              color: JmBrand.amber,
                              onTap: () => context.to(Routes.pricing),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            DNotice(
              bg: DTint.blue(context),
              icon: Icons.info_outline_rounded,
              iconColor: DTint.blueText(context),
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'How our AI works: ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: "it only uses facts you've provided, never invents qualifications, and its scores are estimates – not employer decisions.",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            group('Build & improve your CV', [
              tool(
                Icons.description_outlined,
                green,
                'AI CV Builder',
                'Create a CV from your profile with role-specific tailoring. Export PDF or DOCX.',
                '1 credit per CV',
                null,
              ),
              tool(
                Icons.fact_check_outlined,
                green,
                'CV / ATS Analyser',
                'Estimated ATS-readiness score, missing keywords and prioritised fixes.',
                '1 credit per check',
                Routes.ats,
              ),
              tool(
                Icons.auto_fix_high_rounded,
                green,
                'CV Improvement Assistant',
                'Stronger achievement statements, with before/after you approve.',
                '1 credit',
                null,
              ),
              tool(
                Icons.edit_note_rounded,
                green,
                'Application Assistant',
                'Tailor a cover letter and answers for a specific vacancy.',
                '1 credit',
                Routes.jobs,
              ),
            ]),
            group('Find the right path', [
              tool(
                Icons.track_changes_rounded,
                amber,
                'AI Job Matching',
                'Match percentage with reasons, gaps and suggestions.',
                'Free',
                Routes.jobs,
              ),
              tool(
                Icons.record_voice_over_outlined,
                amber,
                'Interview Coach',
                'Practise role-specific questions; get feedback on structure and relevance.',
                '2 credits per session',
                Routes.interview,
              ),
              tool(
                Icons.stacked_bar_chart_rounded,
                amber,
                'Skills Gap Analyser',
                'Compare your skills to a target role and get linked courses.',
                '1 credit',
                null,
              ),
              tool(
                Icons.route_outlined,
                amber,
                'Career Coach & Pathway',
                'An editable roadmap of roles, skills and milestones – with assumptions shown.',
                'Career Plus',
                null,
              ),
            ]),
            group('Students & graduates', [
              tool(
                Icons.calculate_outlined,
                DTint.blue(context),
                'CGPA Calculator',
                'Calculate CGPA on a clearly stated 5.0 or 4.0 scale.',
                'Free',
                null,
              ),
              tool(
                Icons.workspace_premium_outlined,
                DTint.blue(context),
                'Scholarship Matching',
                'Matches by field, CGPA range, location and deadline – with source links.',
                'Free',
                null,
              ),
              tool(
                Icons.payments_outlined,
                DTint.blue(context),
                'Salary Insights',
                'Indicative ranges only where reliable data exists, with source and sample size.',
                'Free · limited roles',
                null,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

/// 12 CV / ATS compatibility analysis (M10 on phones).
class AtsAnalysisScreen extends StatelessWidget {
  const new({super.key});

  static const _cats = [
    (
      'Role relevance',
      82,
      'Your operations experience aligns well with the responsibilities.',
    ),
    (
      'Keyword alignment',
      58,
      '5 terms from the job description are missing or weak.',
    ),
    ('CV structure', 88, 'Clear headings; dates are consistent.'),
    ('Clarity & readability', 79, 'Some bullet points exceed 2 lines.'),
    ('Evidence of achievements', 61, 'Few results are measured with numbers.'),
  ];

  static const _fixes = [
    (
      'CRITICAL',
      'Quantify your reporting impact',
      'e.g. "Weekly dispatch report used by 4 hub managers" – only if accurate.',
      'Suggest rewrite',
    ),
    (
      'CRITICAL',
      'Add a skills section near the top',
      'Recruiters and parsers look for skills early on page 1.',
      'Add section',
    ),
    (
      'RECOMMENDED',
      'Mention your SQL course (in progress)',
      'If you are enrolled, you can list it as "in progress".',
      'Add to CV',
    ),
    (
      'RECOMMENDED',
      'Shorten long bullet points',
      '4 bullets run past two lines.',
      'Show me',
    ),
    (
      'OPTIONAL',
      'Add a LinkedIn or portfolio link',
      'Helps employers verify your experience.',
      'Add link',
    ),
  ];

  (Color, Color) _levelColors(BuildContext c, String l) => switch (l) {
    'CRITICAL' => (
      c.jm.errorSoft,
      c.jm.isDark ? c.jm.error : const Color(0xFF9A2A12),
    ),
    'RECOMMENDED' => (c.jm.accentSoft, c.jm.onAccentSoft),
    _ => (c.jm.surfaceSunken, c.jm.textMuted),
  };

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final phone = DPage.isPhone(context);

    Widget catRow((String, int, String) c) {
      final (name, v, note) = c;
      final good = v >= 70;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: type.label.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text('$v/100', style: type.label),
              ],
            ),
            const SizedBox(height: 6),
            DBar(v / 100, color: good ? jm.primary : JmBrand.amberText),
            if (!phone) ...[
              const SizedBox(height: 4),
              Text(
                note,
                style: type.caption.copyWith(color: jm.textMuted, fontSize: 13),
              ),
            ],
          ],
        ),
      );
    }

    Widget fixRow((String, String, String, String) f, {bool compact = false}) {
      final (level, title, desc, cta) = f;
      final (bg, fg) = _levelColors(context, level);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: jm.border)),
        ),
        child: Wrap(
          spacing: 14,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: 110,
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                level,
                style: type.caption.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: compact ? 260 : 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: type.label.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (!compact)
                    Text(desc, style: type.small.copyWith(color: jm.textMuted)),
                ],
              ),
            ),
            if (!compact)
              DBtn(
                cta,
                style: DBtnStyle.secondary,
                height: 38,
                fontSize: 13,
                onTap: () => showJmToast(
                  context,
                  'Suggestions are drafts you can edit, accept or reject.',
                ),
              ),
          ],
        ),
      );
    }

    final disclaimer = Text(
      "JobsAndMore does not reproduce any employer's proprietary ATS. Employers can't see this score, and candidates are never auto-rejected on it.",
      style: type.caption.copyWith(
        color: jm.textMuted,
        fontSize: 13,
        height: 1.5,
      ),
    );

    final score = DCard(
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const DRing(
            74,
            size: 120,
            stroke: 10,
            label: 'Estimated ATS-readiness',
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated ATS-readiness', style: type.h3),
                const SizedBox(height: 8),
                Text(
                  "An estimate of how well your CV's structure and content align with this job. It is not a real employer ATS result and does not guarantee an interview.",
                  style: type.small.copyWith(color: jm.textMuted, height: 1.5),
                ),
                const SizedBox(height: 10),
                const DPill(
                  'Up 13 points from v1 (61)',
                  icon: Icons.trending_up_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (phone) {
      return DPage(
        mobileTitle: 'CV compatibility',
        mode: NavMode.seeker,
        body: const SizedBox.shrink(),
        mobileBody: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '19 Nov, 09:12',
                style: type.caption.copyWith(color: jm.textMuted),
              ),
              const SizedBox(height: 10),
              DCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const DRing(74, size: 72, stroke: 7),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated ATS-readiness',
                            style: type.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'vs Operations Analyst · Kobo Logistics',
                            style: type.caption.copyWith(color: jm.textMuted),
                          ),
                          const SizedBox(height: 6),
                          const DPill('+13 since v1'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Breakdown', style: type.h4),
              const SizedBox(height: 10),
              for (final c in _cats) catRow(c),
              Text('Fix first', style: type.h4),
              for (final f in _fixes.take(2)) fixRow(f, compact: true),
              DLink('See all 5 suggestions', onTap: () {}),
              const SizedBox(height: 12),
              Text(
                "An estimate only – not a real employer ATS result. Employers can't see this score.",
                style: type.caption.copyWith(color: jm.textMuted),
              ),
              const SizedBox(height: 16),
              DBtn(
                'Improve my CV',
                expand: true,
                height: 52,
                onTap: () => context.to(Routes.profile),
              ),
            ],
          ),
        ),
      );
    }

    return DPage(
      active: NavItem.tools,
      mode: NavMode.seeker,
      body: DContainer(
        maxWidth: 1100,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: DLink(
                '← Career Tools',
                onTap: () => context.to(Routes.tools),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 12,
              spacing: 12,
              children: [
                Text(
                  'CV compatibility analysis',
                  style: type.h1.copyWith(fontSize: 32),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    DBtn(
                      'Edit CV',
                      style: DBtnStyle.secondary,
                      onTap: () => context.to(Routes.profile),
                    ),
                    DBtn(
                      'Re-run analysis',
                      icon: Icons.refresh_rounded,
                      onTap: () =>
                          showJmToast(context, 'Re-running uses 1 AI credit.'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            DCard(
              radius: 18,
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 40,
                runSpacing: 12,
                children: [
                  for (final (k, v) in [
                    ('CV analysed', 'Amaka_Okafor_Operations.pdf (v2)'),
                    ('Compared with', 'Operations Analyst – Kobo Logistics'),
                    ('Assessed', '19 Nov 2026, 09:12'),
                  ])
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          k,
                          style: type.caption.copyWith(color: jm.textMuted),
                        ),
                        Text(
                          v,
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            score,
            const SizedBox(height: 16),
            DCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Category breakdown', style: type.h3),
                  const SizedBox(height: 16),
                  for (final c in _cats) catRow(c),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Missing or under-represented terms', style: type.h3),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in [
                        'SQL',
                        'Power BI',
                        'KPI dashboards',
                        'last-mile delivery',
                        'cost reconciliation',
                      ])
                        DPill(
                          t,
                          bg: jm.accentSoft,
                          fg: jm.onAccentSoft,
                          fontSize: 13,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Only add a term if it truthfully describes your experience.',
                    style: type.small.copyWith(color: jm.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Prioritised improvements', style: type.h3),
                  const SizedBox(height: 8),
                  for (final f in _fixes) fixRow(f),
                ],
              ),
            ),
            const SizedBox(height: 16),
            disclaimer,
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: DLink('Request a human CV review', onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

/// M11 Interview coach (works on web too).
class InterviewCoachScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<InterviewCoachScreen> createState() => _InterviewCoachScreenState();
}

class _InterviewCoachScreenState extends State<InterviewCoachScreen> {
  int _q = 1;
  final _answer = TextEditingController();

  static const _questions = [
    'Walk me through your experience in operations.',
    'Tell me about a time you used data to solve an operations problem.',
    'How do you prioritise when several hubs report problems at once?',
    'Describe a report you built that changed a decision.',
    'Why do you want to work in last-mile logistics?',
  ];

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;

    Widget bubble(String text, {required bool mine}) => Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: mine ? jm.primarySoft : jm.surface,
            border: mine ? null : Border.all(color: jm.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(text, style: type.body.copyWith(fontSize: 15)),
        ),
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Operations Analyst · Question ${_q + 1} of 5',
          style: type.small.copyWith(color: jm.textMuted),
        ),
        const SizedBox(height: 10),
        DNotice(
          bg: jm.accentSoft,
          child: const Text(
            'Practice feedback only – not an employer assessment',
          ),
        ),
        const SizedBox(height: 16),
        bubble(_questions[_q], mine: false),
        if (_q == 1)
          bubble(
            'At my last job, deliveries in Surulere were often late. I tracked dispatch times in Excel for a month and found most delays came from one loading shift…',
            mine: true,
          ),
        if (_q == 1)
          DCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Feedback',
                  style: type.label.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (final (k, v, good) in [
                  ('Structure (situation → result)', 'Good', true),
                  ('Relevance to the role', 'Strong', true),
                  ('Measurable result', 'Add a number', false),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(k, style: type.small)),
                        Text(
                          v,
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                            color: good ? jm.onPrimarySoft : jm.onAccentSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Try ending with the outcome, e.g. how much late deliveries dropped – only if you know the real figure.',
                  style: type.small.copyWith(color: jm.textMuted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    DBtn(
                      'Try again',
                      style: DBtnStyle.secondary,
                      height: 40,
                      fontSize: 14,
                      onTap: () {},
                    ),
                    DBtn(
                      'Next question',
                      height: 40,
                      fontSize: 14,
                      onTap: () => setState(() => _q = (_q + 1) % 5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _answer,
                decoration: const InputDecoration(
                  hintText: 'Type your answer…',
                  labelText: 'Type your answer',
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Answer by voice',
              onPressed: () => showJmToast(
                context,
                'Voice answers need microphone permission; we only record while you hold the button.',
              ),
              icon: const Icon(Icons.mic_none_rounded),
            ),
          ],
        ),
      ],
    );

    return DPage(
      active: NavItem.tools,
      mode: NavMode.seeker,
      mobileTitle: 'Interview practice',
      mobileBody: Padding(padding: const EdgeInsets.all(16), child: content),
      body: DContainer(
        maxWidth: 760,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: DLink(
                '← Career Tools',
                onTap: () => context.to(Routes.tools),
              ),
            ),
            const SizedBox(height: 8),
            Text('Interview practice', style: type.h1.copyWith(fontSize: 32)),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}
