// Live employer workspace: company set-up, dashboard, vacancy form and
// applicant pipeline, all reading and writing the database. Built from the
// same design kit as the sample screens.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/data/live_data.dart';
import 'package:jobsandmore/features/profile/presentation/live_profile.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

const _states = <(String, String)>[
  ('AB', 'Abia'),
  ('AD', 'Adamawa'),
  ('AK', 'Akwa Ibom'),
  ('AN', 'Anambra'),
  ('BA', 'Bauchi'),
  ('BY', 'Bayelsa'),
  ('BE', 'Benue'),
  ('BO', 'Borno'),
  ('CR', 'Cross River'),
  ('DE', 'Delta'),
  ('EB', 'Ebonyi'),
  ('ED', 'Edo'),
  ('EK', 'Ekiti'),
  ('EN', 'Enugu'),
  ('FC', 'FCT Abuja'),
  ('GO', 'Gombe'),
  ('IM', 'Imo'),
  ('JI', 'Jigawa'),
  ('KD', 'Kaduna'),
  ('KN', 'Kano'),
  ('KT', 'Katsina'),
  ('KE', 'Kebbi'),
  ('KO', 'Kogi'),
  ('KW', 'Kwara'),
  ('LA', 'Lagos'),
  ('NA', 'Nasarawa'),
  ('NI', 'Niger'),
  ('OG', 'Ogun'),
  ('ON', 'Ondo'),
  ('OS', 'Osun'),
  ('OY', 'Oyo'),
  ('PL', 'Plateau'),
  ('RI', 'Rivers'),
  ('SO', 'Sokoto'),
  ('TA', 'Taraba'),
  ('YO', 'Yobe'),
  ('ZA', 'Zamfara'),
];

String stateName(String? code) =>
    _states.where((s) => s.$1 == code).firstOrNull?.$2 ?? (code ?? '');

/// Shows [builder] once the signed-in user has an employer workspace,
/// otherwise a short form to create one.
class LiveEmployerGate extends ConsumerWidget {
  const new({required this.builder, super.key});
  final Widget Function(MyOrg org) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = context.type;
    if (currentUserId == null) {
      return DCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign in to use the employer workspace.', style: type.h4),
            const SizedBox(height: 12),
            DBtn('Sign in', onTap: () => context.to(Routes.signIn)),
          ],
        ),
      );
    }
    final async = ref.watch(myEmployerOrgProvider);
    final org = async.valueOrNull;
    if (async.isLoading && org == null) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (org == null) return const _CreateCompany();
    return builder(org);
  }
}

class _CreateCompany extends ConsumerStatefulWidget {
  const new();
  @override
  ConsumerState<_CreateCompany> createState() => _CreateCompanyState();
}

class _CreateCompanyState extends ConsumerState<_CreateCompany> {
  final _name = TextEditingController();
  final _website = TextEditingController();
  String _state = 'LA';
  String _size = '1-10';
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _website.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_name.text.trim().length < 2) {
      showJmToast(context, 'Enter your company name.', tone: JmTone.warning);
      return;
    }
    final site = _website.text.trim();
    setState(() => _busy = true);
    try {
      await createMyOrganisation(
        type: 'employer',
        name: _name.text.trim(),
        state: _state,
        size: _size,
        website: site.isEmpty
            ? null
            : (site.startsWith('http') ? site : 'https://$site'),
      );
      ref.invalidate(myOrgsProvider);
      if (mounted) {
        showJmToast(context, 'Company workspace created', tone: JmTone.success);
      }
    } on DataFailure catch (e) {
      if (mounted) showJmToast(context, e.message, tone: JmTone.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DEyebrow('Employer workspace'),
          const SizedBox(height: 8),
          Text('Set up your company', style: type.h2.copyWith(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            'Create your company profile to post vacancies and manage applicants. You can ask us to verify it afterwards.',
            style: type.body.copyWith(color: jm.textMuted),
          ),
          const SizedBox(height: 20),
          DGrid(
            minItemWidth: 240,
            gap: 14,
            maxColumns: 2,
            children: [
              DField(label: 'Company name', controller: _name),
              DField(
                label: 'Website',
                controller: _website,
                optional: 'optional',
                hint: 'example.com',
              ),
              DSelect<String>(
                label: 'Head office state',
                value: _state,
                items: [for (final s in _states) s.$1],
                itemLabel: stateName,
                onChanged: (v) => setState(() => _state = v),
              ),
              DSelect<String>(
                label: 'Company size',
                value: _size,
                items: const [
                  '1-10',
                  '11-50',
                  '51-200',
                  '201-500',
                  '501-1000',
                  '1000+',
                ],
                onChanged: (v) => setState(() => _size = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: DBtn(
              _busy ? 'Creating…' : 'Create company workspace',
              onTap: _busy ? null : _create,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ dashboard ---

class LiveEmployerDashboard extends ConsumerWidget {
  const new({required this.org, super.key});
  final MyOrg org;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jm = context.jm;
    final type = context.type;
    final o =
        ref.watch(employerOverviewProvider).valueOrNull ??
        const <String, int>{};
    final jobs = ref.watch(orgJobsProvider).valueOrNull ?? const <OrgJob>[];
    final pipe =
        ref.watch(pipelineProvider).valueOrNull ?? const <PipelineCard>[];
    final pending = o['pending_review'] ?? 0;
    final verified = org.verification ?? 'none';

    int atLeast(List<String> stages) =>
        pipe.where((p) => stages.contains(p.stage)).length;
    final applied = pipe.length;
    const after = [
      'under_review',
      'shortlisted',
      'assessment',
      'interview',
      'reference_check',
      'offer',
      'hired',
    ];
    final funnel = <(String, int)>[
      ('Applied', applied),
      ('Reviewed', atLeast(after)),
      ('Shortlisted', atLeast(after.skip(1).toList())),
      (
        'Interviewed',
        atLeast(['interview', 'reference_check', 'offer', 'hired']),
      ),
      ('Hired', atLeast(['hired'])),
    ];

    Future<void> setStatus(OrgJob j, String status) async {
      try {
        await setJobStatus(j.id, status);
        ref
          ..invalidate(orgJobsProvider)
          ..invalidate(employerOverviewProvider)
          ..invalidate(jobListingsProvider);
        if (context.mounted) {
          showJmToast(
            context,
            '${j.title}: ${status == 'published' ? 'live' : status}',
          );
        }
      } on DataFailure catch (e) {
        if (context.mounted) {
          showJmToast(context, e.message, tone: JmTone.error);
        }
      }
    }

    return Column(
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
                    org.name,
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
                    pending == 0
                        ? 'No applicants are waiting for review.'
                        : '$pending applicant${pending == 1 ? ' is' : 's are'} waiting for review.',
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
          color: verified == 'verified' ? jm.primarySoft : jm.accentSoft,
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
              DVerifiedPill(verificationLabel(verified)),
              if (verified != 'verified')
                DLink(
                  'Request verification',
                  onTap: () async {
                    try {
                      await requestVerification(org.id, 'details_reviewed');
                      if (context.mounted) {
                        showJmToast(
                          context,
                          'Request sent. Our team will contact you for your CAC documents.',
                          tone: JmTone.success,
                        );
                      }
                    } on DataFailure catch (e) {
                      if (context.mounted) {
                        showJmToast(context, e.message, tone: JmTone.error);
                      }
                    }
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DGrid(
          minItemWidth: 170,
          gap: 12,
          maxColumns: 6,
          children: [
            for (final (l, v, s) in [
              (
                'Active vacancies',
                o['active_jobs'] ?? 0,
                '${o['draft_jobs'] ?? 0} draft · ${o['paused_jobs'] ?? 0} paused',
              ),
              ('New applicants', o['new_applicants'] ?? 0, 'Last 7 days'),
              ('Pending review', pending, 'New or under review'),
              ('Interviews', o['interviews'] ?? 0, 'At interview stage'),
              ('Offers', o['offers'] ?? 0, 'Awaiting reply'),
              ('Hires', o['hires'] ?? 0, 'All time'),
            ])
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
                    Text('$v', style: type.h2.copyWith(fontSize: 28)),
                    Text(s, style: type.caption.copyWith(color: jm.textMuted)),
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
                  DLink(
                    '+ New vacancy',
                    onTap: () => context.to(Routes.postVacancy),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (jobs.isEmpty)
                Text(
                  'No vacancies yet. Post your first one to start receiving applications.',
                  style: type.small.copyWith(color: jm.textMuted),
                )
              else
                DTable(
                  minWidth: 760,
                  columns: const [
                    ('Role', 4),
                    ('Status', 2),
                    ('Views', 2),
                    ('Applicants', 2),
                    ('New', 1),
                    ('Closes', 2),
                    ('Actions', 4),
                  ],
                  rows: [
                    for (final j in jobs)
                      [
                        Text(
                          j.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Builder(
                          builder: (c) {
                            final live = j.status == 'published';
                            return DPill(
                              live
                                  ? 'Live'
                                  : '${j.status[0].toUpperCase()}${j.status.substring(1)}',
                              bg: live ? jm.primarySoft : jm.surfaceSunken,
                              fg: live ? jm.onPrimarySoft : jm.textMuted,
                            );
                          },
                        ),
                        Text('${j.views}'),
                        Text('${j.applicants}'),
                        Text('${j.newApplicants}'),
                        Text(fmtDay(j.closingDate)),
                        Wrap(
                          spacing: 6,
                          children: [
                            DLink(
                              'Pipeline',
                              onTap: () => context.to(Routes.pipeline),
                            ),
                            if (j.status == 'published')
                              DLink(
                                'Pause',
                                onTap: () => setStatus(j, 'paused'),
                              )
                            else if (j.status == 'draft' ||
                                j.status == 'paused')
                              DLink(
                                'Publish',
                                onTap: () => setStatus(j, 'published'),
                              ),
                            if (j.status != 'closed')
                              DLink(
                                'Close',
                                onTap: () => setStatus(j, 'closed'),
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
                  Text('At interview stage', style: type.h4),
                  const SizedBox(height: 10),
                  if (pipe.where((p) => p.stage == 'interview').isEmpty)
                    Text(
                      'Nobody at interview stage yet.',
                      style: type.small.copyWith(color: jm.textMuted),
                    ),
                  for (final p
                      in pipe.where((p) => p.stage == 'interview').take(5))
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: jm.border)),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' · ${p.jobTitle}'),
                          ],
                        ),
                        style: type.small,
                      ),
                    ),
                ],
              ),
            ),
            DCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Stage conversion', style: type.h4),
                  const SizedBox(height: 12),
                  for (final (l, v) in funnel)
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
                                widthFactor: applied == 0
                                    ? 0.04
                                    : (v / applied).clamp(0.04, 1.0),
                                child: Container(
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: jm.primary.withValues(
                                      alpha:
                                          0.25 +
                                          0.75 *
                                              (applied == 0 ? 0 : v / applied),
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
                    'Starter (free) · 1 active vacancy included',
                    style: type.small,
                  ),
                  const SizedBox(height: 12),
                  DLink('See plans', onTap: () => context.to(Routes.pricing)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------- post a vacancy ---

class LivePostVacancy extends ConsumerStatefulWidget {
  const new({required this.org, super.key});
  final MyOrg org;
  @override
  ConsumerState<LivePostVacancy> createState() => _LivePostVacancyState();
}

class _LivePostVacancyState extends ConsumerState<LivePostVacancy> {
  final _title = TextEditingController();
  final _city = TextEditingController();
  final _summary = TextEditingController();
  final _description = TextEditingController();
  final _resp = TextEditingController();
  final _req = TextEditingController();
  final _benefits = TextEditingController();
  final _skills = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();
  final _closes = TextEditingController();
  String _jobType = 'full_time';
  String _arrangement = 'on_site';
  String _level = 'entry';
  String _state = 'LA';
  bool _disclose = true;
  bool _busy = false;
  final _questions = <(TextEditingController, bool)>[];

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    final d = DateTime.now().add(const Duration(days: 30));
    _closes.text =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _city,
      _summary,
      _description,
      _resp,
      _req,
      _benefits,
      _skills,
      _min,
      _max,
      _closes,
    ]) {
      c.dispose();
    }
    for (final q in _questions) {
      q.$1.dispose();
    }
    super.dispose();
  }

  List<String> _lines(TextEditingController c) => c.text
      .split('\n')
      .map((e) => e.replaceFirst(RegExp(r'^[-•*]\s*'), '').trim())
      .where((e) => e.isNotEmpty)
      .toList();

  int? _money(TextEditingController c) =>
      int.tryParse(c.text.replaceAll(RegExp('[^0-9]'), ''));

  Future<void> _save({required bool publish}) async {
    if (_title.text.trim().length < 3) {
      showJmToast(context, 'Add a job title.', tone: JmTone.warning);
      return;
    }
    if (_description.text.trim().length < 30) {
      showJmToast(
        context,
        'Describe the role in at least a few sentences.',
        tone: JmTone.warning,
      );
      return;
    }
    final min = _money(_min);
    final max = _money(_max);
    if (min != null && max != null && max < min) {
      showJmToast(
        context,
        'The maximum salary must be at least the minimum.',
        tone: JmTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await postVacancy(
        title: _title.text,
        summary: _summary.text.trim().isEmpty ? null : _summary.text.trim(),
        description: _description.text,
        jobType: _jobType,
        arrangement: _arrangement,
        experienceLevel: _level,
        state: _arrangement == 'remote' ? null : _state,
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        salaryMin: min,
        salaryMax: max,
        salaryDisclosed: _disclose,
        closingDate: DateTime.tryParse(_closes.text.trim()),
        responsibilities: _lines(_resp),
        requirements: _lines(_req),
        benefits: _lines(_benefits),
        skills: _skills.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        screening: [
          for (final (i, (c, yesNo)) in _questions.indexed)
            if (c.text.trim().isNotEmpty)
              {
                'id': 'q${i + 1}',
                'question': c.text.trim(),
                'type': yesNo ? 'choice' : 'text',
                if (yesNo) 'options': ['Yes', 'No'],
              },
        ],
        publish: publish,
      );
      ref
        ..invalidate(orgJobsProvider)
        ..invalidate(employerOverviewProvider)
        ..invalidate(jobListingsProvider);
      if (!mounted) return;
      showJmToast(
        context,
        publish ? 'Vacancy is live' : 'Draft saved',
        tone: JmTone.success,
      );
      context.to(Routes.employer);
    } on DataFailure catch (e) {
      if (mounted) showJmToast(context, e.message, tone: JmTone.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;

    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: type.h3),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );

    final form = Column(
      children: [
        section('Basics', [
          DGrid(
            minItemWidth: 240,
            gap: 16,
            maxColumns: 2,
            children: [
              DField(label: 'Job title', controller: _title),
              DSelect<String>(
                label: 'Job type',
                value: _jobType,
                items: const [
                  'full_time',
                  'part_time',
                  'contract',
                  'internship',
                  'nysc',
                  'temporary',
                ],
                itemLabel: jobTypeLabel,
                onChanged: (v) => setState(() => _jobType = v),
              ),
              DSelect<String>(
                label: 'Work arrangement',
                value: _arrangement,
                items: const ['on_site', 'hybrid', 'remote'],
                itemLabel: arrangementLabel,
                onChanged: (v) => setState(() => _arrangement = v),
              ),
              DSelect<String>(
                label: 'Experience level',
                value: _level,
                items: const ['entry', 'mid', 'senior', 'manager', 'executive'],
                itemLabel: (v) => '${v[0].toUpperCase()}${v.substring(1)}',
                onChanged: (v) => setState(() => _level = v),
              ),
              if (_arrangement != 'remote')
                DSelect<String>(
                  label: 'State',
                  value: _state,
                  items: [for (final s in _states) s.$1],
                  itemLabel: stateName,
                  onChanged: (v) => setState(() => _state = v),
                ),
              if (_arrangement != 'remote')
                DField(
                  label: 'City or area',
                  controller: _city,
                  optional: 'optional',
                ),
              DField(label: 'Closing date (YYYY-MM-DD)', controller: _closes),
            ],
          ),
        ]),
        section('Description', [
          DField(
            label: 'One-line summary',
            controller: _summary,
            optional: 'optional',
          ),
          const SizedBox(height: 12),
          DField(
            label: 'About the role',
            controller: _description,
            maxLines: 6,
          ),
          const SizedBox(height: 12),
          DField(
            label: 'Responsibilities (one per line)',
            controller: _resp,
            maxLines: 5,
            optional: 'optional',
          ),
        ]),
        section('Requirements', [
          DField(
            label: 'Requirements (one per line)',
            controller: _req,
            maxLines: 5,
            optional: 'optional',
          ),
          const SizedBox(height: 12),
          DField(
            label: 'Skills (comma separated)',
            controller: _skills,
            hint: 'Excel, SQL, Customer service',
            optional: 'optional',
          ),
        ]),
        section('Pay & benefits', [
          DGrid(
            minItemWidth: 200,
            gap: 16,
            maxColumns: 2,
            children: [
              DField(
                label: 'Minimum monthly pay (₦)',
                controller: _min,
                keyboardType: TextInputType.number,
                optional: 'optional',
              ),
              DField(
                label: 'Maximum monthly pay (₦)',
                controller: _max,
                keyboardType: TextInputType.number,
                optional: 'optional',
              ),
            ],
          ),
          const SizedBox(height: 12),
          DCheck(
            value: _disclose,
            onChanged: (v) => setState(() => _disclose = v),
            label: const Text(
              'Show the salary range on the listing (candidates apply more when they can see pay)',
            ),
          ),
          const SizedBox(height: 12),
          DField(
            label: 'Benefits (one per line)',
            controller: _benefits,
            maxLines: 4,
            optional: 'optional',
          ),
        ]),
        section('Screening questions', [
          Text(
            'Up to 5 · keep them job-related. Answers flag, never auto-reject.',
            style: type.small.copyWith(color: jm.textMuted),
          ),
          const SizedBox(height: 12),
          for (final (i, (c, yesNo)) in _questions.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: DField(label: 'Question ${i + 1}', controller: c),
                  ),
                  const SizedBox(width: 8),
                  DChoicePill(
                    label: yesNo ? 'Yes / No' : 'Text answer',
                    selected: yesNo,
                    onTap: () => setState(() => _questions[i] = (c, !yesNo)),
                  ),
                  IconButton(
                    tooltip: 'Remove question',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () =>
                        setState(() => _questions.removeAt(i).$1.dispose()),
                  ),
                ],
              ),
            ),
          if (_questions.length < 5)
            Align(
              alignment: Alignment.centerLeft,
              child: DBtn(
                '+ Add question',
                style: DBtnStyle.secondary,
                height: 40,
                fontSize: 14,
                onTap: () => setState(
                  () => _questions.add((TextEditingController(), true)),
                ),
              ),
            ),
        ]),
      ],
    );

    final min = _money(_min);
    final max = _money(_max);
    final preview = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LIVE PREVIEW',
            style: type.overline.copyWith(color: jm.textMuted),
          ),
          const SizedBox(height: 10),
          Text(_title.text.isEmpty ? 'Job title' : _title.text, style: type.h4),
          Text(
            [
              widget.org.name,
              if (_arrangement == 'remote') 'Remote' else stateName(_state),
              arrangementLabel(_arrangement),
            ].join(' · '),
            style: type.small.copyWith(color: jm.textMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              DVerifiedPill(verificationLabel(widget.org.verification)),
              DTag(jobTypeLabel(_jobType)),
              if (_disclose && (min != null || max != null))
                DTag(
                  [
                    if (min != null) '₦${(min / 1000).round()}k',
                    if (max != null) '₦${(max / 1000).round()}k',
                  ].join('–'),
                ),
            ],
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: DLink('← Overview', onTap: () => context.to(Routes.employer)),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Text('New vacancy', style: type.h1.copyWith(fontSize: 30)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DBtn(
                  'Save draft',
                  style: DBtnStyle.secondary,
                  onTap: _busy ? null : () => _save(publish: false),
                ),
                DBtn(
                  _busy ? 'Publishing…' : 'Publish vacancy',
                  onTap: _busy ? null : () => _save(publish: true),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        DSplit(
          asideWidth: 320,
          gap: 20,
          breakpoint: 1000,
          main: form,
          aside: preview,
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- pipeline ---

const _columns = <(String, String)>[
  ('new', 'New'),
  ('under_review', 'Under review'),
  ('shortlisted', 'Shortlisted'),
  ('interview', 'Interview'),
  ('offer', 'Offer'),
  ('hired', 'Hired'),
  ('rejected', 'Not progressed'),
];

class LivePipeline extends ConsumerStatefulWidget {
  const new({required this.org, super.key});
  final MyOrg org;
  @override
  ConsumerState<LivePipeline> createState() => _LivePipelineState();
}

class _LivePipelineState extends ConsumerState<LivePipeline> {
  String? _job;

  Future<void> _move(PipelineCard c, String stage) async {
    if (c.stage == stage) return;
    try {
      await moveApplication(c.id, stage);
      ref
        ..invalidate(pipelineProvider)
        ..invalidate(employerOverviewProvider);
      if (mounted) showJmToast(context, '${c.name} → ${stageLabel(stage)}');
    } on DataFailure catch (e) {
      if (mounted) showJmToast(context, e.message, tone: JmTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final all =
        ref.watch(pipelineProvider).valueOrNull ?? const <PipelineCard>[];
    final jobs = {for (final c in all) c.jobId: c.jobTitle};
    final cards = _job == null
        ? all
        : all.where((c) => c.jobId == _job).toList();

    Widget card(PipelineCard c) => Draggable<PipelineCard>(
      data: c,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 220,
          child: DCard(
            padding: const EdgeInsets.all(12),
            child: Text(c.name, style: type.label),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _PipeCard(c: c, onMove: (s) => _move(c, s)),
      ),
      child: _PipeCard(c: c, onMove: (s) => _move(c, s)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          children: [
            Text('Applicants', style: type.h1.copyWith(fontSize: 30)),
            if (jobs.isNotEmpty)
              SizedBox(
                width: 280,
                child: DSelect<String>(
                  label: 'Vacancy',
                  showLabel: false,
                  value: _job ?? '',
                  items: ['', ...jobs.keys],
                  itemLabel: (v) =>
                      v.isEmpty ? 'All vacancies' : (jobs[v] ?? v),
                  onChanged: (v) => setState(() => _job = v.isEmpty ? null : v),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Drag a card to another column, or use its menu, to move a candidate.',
          style: type.small.copyWith(color: jm.textMuted),
        ),
        const SizedBox(height: 16),
        if (all.isEmpty)
          DCard(
            child: Text(
              'No applications yet. They appear here as soon as candidates apply.',
              style: type.body.copyWith(color: jm.textMuted),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (stage, label) in _columns)
                  DragTarget<PipelineCard>(
                    onAcceptWithDetails: (d) => _move(d.data, stage),
                    builder: (context, candidate, _) {
                      final inCol = cards
                          .where((c) => c.stage == stage)
                          .toList();
                      return Container(
                        width: 240,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: candidate.isNotEmpty
                              ? jm.primarySoft
                              : jm.surfaceAlt,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: jm.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: type.label.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                DPill('${inCol.length}', bg: jm.surface),
                              ],
                            ),
                            const SizedBox(height: 10),
                            for (final c in inCol)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: card(c),
                              ),
                            if (inCol.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                child: Text(
                                  '—',
                                  textAlign: TextAlign.center,
                                  style: type.small.copyWith(
                                    color: jm.textMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PipeCard extends StatelessWidget {
  const new({required this.c, required this.onMove});
  final PipelineCard c;
  final ValueChanged<String> onMove;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return DCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DInitials(initialsOf(c.name), size: 34, circle: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: type.label.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  c.headline ?? c.jobTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: type.caption.copyWith(color: jm.textMuted),
                ),
                const SizedBox(height: 4),
                Builder(
                  builder: (ctx) {
                    final (bg, fg) = liveStageColors(ctx, c.stage);
                    return DPill(
                      'Applied ${fmtDay(c.appliedAt)}',
                      bg: bg,
                      fg: fg,
                      fontSize: 11,
                    );
                  },
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Move ${c.name}',
            icon: const Icon(Icons.more_vert_rounded, size: 18),
            onSelected: onMove,
            itemBuilder: (_) => [
              for (final (s, l) in _columns)
                if (s != c.stage)
                  PopupMenuItem(value: s, child: Text('Move to $l')),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------ public company ---

class LiveEmployerProfile extends ConsumerWidget {
  const new({required this.slug, super.key});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jm = context.jm;
    final type = context.type;
    final async = ref.watch(publicOrgProvider(slug));
    final o = async.valueOrNull;
    if (o == null) {
      return Padding(
        padding: const EdgeInsets.all(64),
        child: Center(
          child: async.isLoading
              ? const CircularProgressIndicator()
              : Text('We could not find this company.', style: type.h3),
        ),
      );
    }
    final mine = (ref.watch(myOrgsProvider).valueOrNull ?? const <MyOrg>[]).any(
      (m) => m.id == o.id && (m.role == 'owner' || m.role == 'admin'),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DPhoto(
          DImages.teamMeeting,
          radius: 24,
          height: DPage.isPhone(context) ? 150 : 240,
          alignment: const Alignment(0, -0.3),
          shadow: false,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DInitials(
              initialsOf(o.name),
              size: 72,
              bg: jm.accentSoft,
              fg: jm.onAccentSoft,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.name, style: type.h1.copyWith(fontSize: 32)),
                  Text(
                    [
                      if (o.industry != null) o.industry!.replaceAll('-', ' '),
                      if (o.state != null) stateName(o.state),
                      if (o.size != null) '${o.size} employees',
                    ].join(' · '),
                    style: type.body.copyWith(color: jm.textMuted),
                  ),
                  const SizedBox(height: 8),
                  DVerifiedPill(verificationLabel(o.verification)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        DSplit(
          asideWidth: 360,
          gap: 20,
          breakpoint: 940,
          main: DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About us', style: type.h3),
                const SizedBox(height: 10),
                Text(
                  (o.description ?? '').isEmpty
                      ? 'This company has not added a description yet.'
                      : o.description!,
                  style: type.body.copyWith(height: 1.6),
                ),
                if ((o.culture ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Culture & values', style: type.h4),
                  const SizedBox(height: 8),
                  Text(o.culture!, style: type.body),
                ],
                if (mine) ...[
                  const SizedBox(height: 16),
                  DLink(
                    'Edit company profile',
                    onTap: () => _edit(context, ref, o),
                  ),
                ],
              ],
            ),
          ),
          aside: DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Open roles (${o.jobs.length})', style: type.h4),
                const SizedBox(height: 10),
                if (o.jobs.isEmpty)
                  Text(
                    'No open roles right now.',
                    style: type.small.copyWith(color: jm.textMuted),
                  ),
                for (final j in o.jobs)
                  InkWell(
                    onTap: () => context.to(Routes.jobDetail(j.id)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: jm.border)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            j.title,
                            style: type.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${j.location} · ${j.type} · closes ${j.closes}',
                            style: type.caption.copyWith(color: jm.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, PublicOrg o) async {
    final about = TextEditingController(text: o.description);
    final culture = TextEditingController(text: o.culture);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit company profile'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DField(
                label: 'About the company',
                controller: about,
                maxLines: 6,
              ),
              const SizedBox(height: 12),
              DField(
                label: 'Culture & values',
                controller: culture,
                maxLines: 3,
                optional: 'optional',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await updateOrganisation(o.id, {
        'description': about.text.trim(),
        'culture': culture.text.trim(),
      });
      ref.invalidate(publicOrgProvider(slug));
      if (context.mounted) {
        showJmToast(context, 'Company profile saved', tone: JmTone.success);
      }
    } on DataFailure catch (e) {
      if (context.mounted) showJmToast(context, e.message, tone: JmTone.error);
    }
  }
}
