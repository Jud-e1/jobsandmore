import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/env.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/data/live_data.dart';
import 'package:jobsandmore/features/demo/demo_data.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

class _SaveButton extends ConsumerWidget {
  const new(this.job);

  final DemoJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedJobsProvider).contains(job.id);
    final jm = context.jm;
    return Tooltip(
      message: saved ? 'Remove from saved jobs' : 'Save job',
      child: Material(
        color: saved ? jm.primarySoft : jm.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: saved ? jm.primary : jm.borderStrong),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            unawaited(HapticFeedback.selectionClick());
            try {
              final added = await ref
                  .read(savedJobsProvider.notifier)
                  .toggle(job.id);
              if (!context.mounted) return;
              showJmToast(
                context,
                added ? 'Saved ${job.title}' : 'Removed from saved jobs',
                tone: added ? JmTone.success : JmTone.neutral,
              );
            } on DataFailure catch (e) {
              if (context.mounted) {
                showJmToast(context, e.message, tone: JmTone.error);
              }
            }
          },
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: saved ? jm.primary : jm.text,
              semanticLabel: saved ? 'Saved' : 'Save job',
            ),
          ),
        ),
      ),
    );
  }
}

/// 06 Find Jobs – search results (M05 on phones).
class JobsSearchScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<JobsSearchScreen> createState() => _JobsSearchScreenState();
}

class _JobsSearchScreenState extends ConsumerState<JobsSearchScreen> {
  final _q = TextEditingController(text: Env.hasSupabase ? '' : 'Analyst');
  int _tab = 0;
  String _sort = 'Best match';
  final _arr = Env.hasSupabase
      ? {'On-site', 'Hybrid', 'Remote'}
      : {'On-site', 'Hybrid'};
  final _types = Env.hasSupabase ? <String>{} : {'Full-time'};
  bool _salaryOnly = false;
  bool _verifiedOnly = !Env.hasSupabase;
  bool _includeEmail = false;
  String _exp = '1–3 years';
  String _industry = 'All industries';
  String _loc = 'Lagos + nearby states';

  static const _tabs = [
    'Jobs',
    'Internships',
    'Scholarships',
    'Fellowships & grants',
    'Volunteering',
    'International',
  ];

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<DemoJob> get _results {
    final all = ref.watch(jobListingsProvider).valueOrNull ?? const <DemoJob>[];
    var list = all.where((j) {
      if (_salaryOnly && j.salary.contains('not disclosed')) return false;
      if (_verifiedOnly) {
        final ok =
            j.verification == 'Verified employer' ||
            j.verification == 'Business details reviewed' ||
            (_includeEmail && j.verification == 'Email verified');
        if (!ok) return false;
      }
      final q = _q.text.trim().toLowerCase();
      if (q.isNotEmpty &&
          !j.title.toLowerCase().contains(q) &&
          !j.company.toLowerCase().contains(q) &&
          !j.skills.any((s) => s.toLowerCase().contains(q))) {
        return false;
      }
      if (j.isLive && _arr.isNotEmpty) {
        final arr = j.type.split(' · ').skip(1).firstOrNull;
        if (arr != null && !_arr.contains(arr)) return false;
      }
      if (j.isLive && _types.isNotEmpty) {
        final group = switch (j.listing) {
          'Contract' || 'Temporary' => 'Contract / temporary',
          'Internship' || 'NYSC' => 'Graduate trainee',
          final other => other,
        };
        if (!_types.contains(group)) return false;
      }
      return true;
    }).toList();
    if (_sort == 'Closing soon') {
      list = [...list]
        ..sort(
          (a, b) => (a.closingDate ?? DateTime(2100)).compareTo(
            b.closingDate ?? DateTime(2100),
          ),
        );
    } else if (_sort == 'Newest') {
      list = [...list]
        ..sort(
          (a, b) => (b.publishedAt ?? DateTime(2000)).compareTo(
            a.publishedAt ?? DateTime(2000),
          ),
        );
    } else {
      list = [...list]..sort((a, b) => b.match.compareTo(a.match));
    }
    return list;
  }

  Widget _filters(BuildContext context) {
    final type = context.type;
    Widget group(String title, List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: type.label.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...children,
      ],
    );
    Widget check(String label, Set<String> set, [String? count]) => DCheck(
      value: set.contains(label),
      onChanged: (v) => setState(() => v ? set.add(label) : set.remove(label)),
      label: Text(label),
      trailing: count,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Filters', style: type.h4)),
            DLink(
              'Clear all',
              onTap: () => setState(() {
                _arr.clear();
                _types.clear();
                _salaryOnly = false;
                _verifiedOnly = false;
                _includeEmail = false;
              }),
            ),
          ],
        ),
        const SizedBox(height: 22),
        group('Work arrangement', [
          for (final a in const ['On-site', 'Hybrid', 'Remote'])
            check(
              a,
              _arr,
              Env.hasSupabase
                  ? '${(ref.watch(jobListingsProvider).valueOrNull ?? const <DemoJob>[]).where((j) => j.type.endsWith(a)).length}'
                  : const {'On-site': '48', 'Hybrid': '21', 'Remote': '17'}[a],
            ),
        ]),
        const SizedBox(height: 22),
        group('Job type', [
          for (final t in [
            'Full-time',
            'Part-time',
            'Contract / temporary',
            'Graduate trainee',
            'Freelance',
          ])
            check(t, _types),
        ]),
        const SizedBox(height: 22),
        DSelect<String>(
          label: 'Experience level',
          value: _exp,
          height: 44,
          items: const [
            'Graduate / entry',
            '1–3 years',
            '3–7 years',
            '7+ years',
          ],
          onChanged: (v) => setState(() => _exp = v),
        ),
        const SizedBox(height: 22),
        DSelect<String>(
          label: 'Industry',
          value: _industry,
          height: 44,
          items: const [
            'All industries',
            'Logistics',
            'Banking & finance',
            'Technology',
            'Healthcare',
            'Agriculture',
          ],
          onChanged: (v) => setState(() => _industry = v),
        ),
        const SizedBox(height: 22),
        group('Salary (where disclosed)', [
          const Row(
            children: [
              Expanded(
                child: DField(
                  label: 'Minimum',
                  hint: '₦ min',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DField(
                  label: 'Maximum',
                  hint: '₦ max',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DCheck(
            value: _salaryOnly,
            onChanged: (v) => setState(() => _salaryOnly = v),
            label: const Text('Only show roles with salary'),
          ),
        ]),
        const SizedBox(height: 22),
        group('Employer trust', [
          DCheck(
            value: _verifiedOnly,
            onChanged: (v) => setState(() => _verifiedOnly = v),
            label: const Text('Verified employers only'),
          ),
          DCheck(
            value: _includeEmail,
            onChanged: (v) => setState(() => _includeEmail = v),
            label: const Text('Include "Email verified"'),
          ),
        ]),
      ],
    );
  }

  Widget _resultCard(BuildContext context, DemoJob j, {required bool compact}) {
    final jm = context.jm;
    final type = context.type;
    if (compact) {
      return DCard(
        radius: 18,
        padding: const EdgeInsets.all(14),
        semanticLabel: '${j.title} at ${j.company}, ${j.match}% match',
        onTap: () => context.to(Routes.jobDetail(j.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DInitials(j.ini, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        j.title,
                        style: type.label.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${j.company} · ${j.location}',
                        style: type.caption.copyWith(
                          color: jm.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                DPill(j.isLive && j.match == 0 ? j.listing : '${j.match}%'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '✓ ${j.verification} · ${j.salary.replaceAll(' / month', '')} · Closes ${j.closes}',
              style: type.caption.copyWith(color: jm.textMuted),
            ),
          ],
        ),
      );
    }
    return DCard(
      radius: 18,
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          DInitials(j.ini, size: 52),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => context.to(Routes.jobDetail(j.id)),
                      child: Text(
                        j.title,
                        style: type.label.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (j.sponsored)
                      Tooltip(
                        message: 'This employer paid to promote this listing.',
                        child: DPill(
                          'SPONSORED',
                          radius: 4,
                          fontSize: 11,
                          bg: jm.accentSoft,
                          fg: jm.onAccentSoft,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${j.company} · ${j.location} · ${j.type}',
                  style: type.small.copyWith(color: jm.textMuted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DVerifiedPill(j.verification),
                    Text(
                      j.salary,
                      style: type.caption.copyWith(
                        fontSize: 13,
                        color: jm.text,
                      ),
                    ),
                    Text(
                      '· Posted ${j.posted} · Closes ${j.closes}',
                      style: type.caption.copyWith(
                        fontSize: 13,
                        color: jm.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: jm.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: j.isLive && j.match == 0
                              ? 'Match estimate: '
                              : '${j.match}% match',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: j.isLive
                              ? (j.match == 0
                                    ? 'add your skills and target roles to your profile'
                                    : ' – based on your skills, location and target roles')
                              : ' – ${j.why}',
                        ),
                      ],
                    ),
                    style: type.caption.copyWith(fontSize: 13, color: jm.text),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SaveButton(j),
              const SizedBox(height: 8),
              DBtn(
                'Apply',
                height: 42,
                fontSize: 14,
                onTap: () => context.to(Routes.apply(j.id)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final results = _results;
    final phone = DPage.isPhone(context);

    final mobile = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: jm.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _q,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Search jobs',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Badge(
                    label: const Text('3'),
                    backgroundColor: jm.primary,
                    child: IconButton.outlined(
                      tooltip: 'Filters',
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (_) => StatefulBuilder(
                          builder: (ctx, set) => SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: _filters(ctx),
                          ),
                        ),
                      ).then((_) => setState(() {})),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in ['Lagos + nearby', 'Hybrid', 'Verified only'])
                    InputChip(
                      label: Text(c),
                      onDeleted: () {},
                      deleteButtonTooltipMessage: 'Remove $c',
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  Env.hasSupabase ? '${results.length} jobs' : '86 jobs',
                  style: type.label.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              DLink('+ Save as alert', onTap: () => context.to(Routes.alerts)),
            ],
          ),
        ),
        for (final j in results)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _resultCard(context, j, compact: true),
          ),
      ],
    );

    final desktop = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DPhotoBackdrop(
          asset: DImages.lagos,
          alignment: const Alignment(0, 0.2),
          child: DContainer(
            maxWidth: 1280,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DEyebrow('Jobs', color: JmBrand.amber),
                const SizedBox(height: 10),
                Text(
                  'Find work across Nigeria.',
                  style: type.h1.copyWith(color: Colors.white, fontSize: 46),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verified employers, salary shown where the employer shares it, and no fees to apply – ever.',
                  style: type.bodyL.copyWith(color: DTint.onDarkMuted),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: jm.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 30,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: 420,
                        child: TextField(
                          controller: _q,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Keyword',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: DSelect<String>(
                          label: 'Location',
                          showLabel: false,
                          value: _loc,
                          items: const [
                            'Lagos + nearby states',
                            'Lagos only',
                            'Abuja (FCT)',
                            'Anywhere in Nigeria',
                            'Remote',
                          ],
                          onChanged: (v) => setState(() => _loc = v),
                        ),
                      ),
                      DBtn('Search', onTap: () => setState(() {})),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: jm.surface,
            border: Border(bottom: BorderSide(color: jm.border)),
          ),
          child: DContainer(
            maxWidth: 1280,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DTabs(
                  tabs: _tabs,
                  current: _tab,
                  onTap: (i) => setState(() => _tab = i),
                ),
              ],
            ),
          ),
        ),
        DContainer(
          maxWidth: 1280,
          padding: const EdgeInsets.all(24),
          child: DSplit(
            asideOnRight: false,
            asideWidth: 280,
            gap: 24,
            breakpoint: 940,
            aside: DCard(
              padding: const EdgeInsets.all(20),
              child: _filters(context),
            ),
            main: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DNotice(
                  bg: jm.accentSoft,
                  trailing: DBtn(
                    'Create job alert',
                    style: DBtnStyle.dark,
                    height: 40,
                    fontSize: 14,
                    onTap: () => context.to(Routes.alerts),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Get these jobs by email. ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: 'New matches for "${_q.text}" in $_loc.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 10,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        '${results.length} jobs for "${_q.text}"',
                        style: type.h3,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: DSelect<String>(
                        label: 'Sort by',
                        showLabel: false,
                        height: 40,
                        value: _sort,
                        items: const ['Best match', 'Newest', 'Closing soon'],
                        onChanged: (v) => setState(() => _sort = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_tab != 0)
                  DCard(
                    child: Text(
                      '${_tabs[_tab]} are listed separately from jobs, each with its official source and deadline.',
                      style: type.body.copyWith(color: jm.textMuted),
                    ),
                  )
                else if (results.isEmpty)
                  DCard(
                    child: Column(
                      children: [
                        Text('No jobs match these filters', style: type.h4),
                        const SizedBox(height: 8),
                        DLink(
                          'Clear filters',
                          onTap: () => setState(() {
                            _verifiedOnly = false;
                            _salaryOnly = false;
                          }),
                        ),
                      ],
                    ),
                  )
                else
                  for (final j in results) ...[
                    _resultCard(context, j, compact: false),
                    const SizedBox(height: 14),
                  ],
                const SizedBox(height: 8),
                Center(
                  child: Wrap(
                    spacing: 6,
                    children: [
                      for (final p in ['1', '2', '3'])
                        DBtn(
                          p,
                          height: 44,
                          style: p == '1'
                              ? DBtnStyle.primary
                              : DBtnStyle.secondary,
                          onTap: () {},
                        ),
                      DBtn(
                        'Next →',
                        height: 44,
                        style: DBtnStyle.secondary,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return DPage(
      active: NavItem.jobs,
      mode: NavMode.seeker,
      mobileTab: MobileTab.jobs,
      body: phone ? mobile : desktop,
    );
  }
}

/// 07 Job detail (M06 on phones).
class JobDetailScreen extends ConsumerStatefulWidget {
  const new({required this.jobId, super.key});

  final String jobId;

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  int _tab = 0;

  static const _about =
      "You'll track delivery performance across our Lagos hubs, build weekly reports for the operations lead and help the team cut late deliveries. You'll work closely with dispatch, customer service and finance.";
  static const _resp = [
    'Collect and clean daily delivery and fleet data',
    'Build weekly KPI dashboards and present findings',
    'Identify bottlenecks and recommend process fixes',
    'Support monthly cost reconciliation with finance',
  ];
  static const _req = [
    'BSc/HND in any numerate discipline',
    '1–3 years in operations, logistics or analysis',
    'Strong Excel; SQL or Power BI is an advantage',
    'Clear written and spoken English',
  ];
  static const _benefits = [
    'HMO for employee and one dependant',
    'Transport allowance on on-site days',
    'Paid training budget',
  ];

  void _report() =>
      showJmDialog(
        context: context,
        title: 'Report this listing?',
        message: 'Tell us if this job looks fake, asks for payment or breaks our rules. Our team reviews every report.',
        confirmLabel: 'Report listing',
        icon: Icons.flag_outlined,
      ).then((ok) {
        if ((ok ?? false) && mounted) {
          showJmToast(
            context,
            'Thanks. Our team will review this listing.',
            tone: JmTone.success,
          );
        }
      });

  Widget _section(String title, {String? body, List<String>? bullets}) {
    final type = context.type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: type.h3)),
          const SizedBox(height: 10),
          if (body != null)
            Text(
              body,
              style: type.body.copyWith(color: context.jm.text, height: 1.65),
            ),
          for (final b in bullets ?? const <String>[])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: type.body),
                  Expanded(
                    child: Text(b, style: type.body.copyWith(height: 1.55)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _match(DemoJob job) {
    final jm = context.jm;
    final type = context.type;
    final live = job.isLive;
    final signals = ref.watch(seekerSignalsProvider).valueOrNull;
    final mine = signals?.skills ?? const <String>{};
    final matched = [
      for (final s in job.skills)
        if (mine.contains(s.toLowerCase())) s,
    ];
    final gaps = [
      for (final s in job.skills)
        if (!mine.contains(s.toLowerCase())) s,
    ];
    final pct = live ? job.match : 82;
    return DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Your match', style: type.h4)),
              Text(
                pct > 0 ? '$pct%' : '—',
                style: type.h3.copyWith(color: jm.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DBar(pct / 100),
          const SizedBox(height: 14),
          Text(
            'What matches',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            !live
                ? '✓ Excel and reporting · ✓ 2 yrs operations · ✓ Lagos, hybrid'
                : matched.isEmpty
                ? (signals == null || signals.isEmpty
                      ? 'Add your skills and target roles to your profile to see what matches.'
                      : 'None of the listed skills are on your profile yet.')
                : matched.map((m) => '✓ $m').join(' · '),
            style: type.small.copyWith(color: jm.onPrimarySoft),
          ),
          const SizedBox(height: 10),
          Text('Gaps', style: type.label.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            !live
                ? 'SQL / Power BI not in your profile'
                : gaps.isEmpty
                ? 'No skill gaps against this listing.'
                : '${gaps.join(' / ')} not in your profile',
            style: type.small.copyWith(color: jm.onAccentSoft),
          ),
          const SizedBox(height: 16),
          DBtn(
            'Check my CV against this job',
            style: DBtnStyle.secondary,
            expand: true,
            onTap: () => context.to(Routes.ats),
          ),
          const SizedBox(height: 10),
          Text(
            "Match is an estimate based on your profile. It doesn't predict the employer's decision.",
            style: type.caption.copyWith(color: jm.textMuted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final jobAsync = ref.watch(jobProvider(widget.jobId));
    final job = jobAsync.valueOrNull;
    final phone = DPage.isPhone(context);
    if (job == null) {
      return DPage(
        active: NavItem.jobs,
        mode: NavMode.seeker,
        mobileTitle: 'Job',
        body: Padding(
          padding: const EdgeInsets.all(64),
          child: Center(
            child: jobAsync.isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('This job is no longer available.', style: type.h3),
                      const SizedBox(height: 12),
                      DLink(
                        'Browse open jobs',
                        onTap: () => context.to(Routes.jobs),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }
    final live = job.isLive;
    final about = live ? (job.about ?? job.summary ?? '') : _about;
    final resp = live ? job.responsibilities : _resp;
    final req = live ? job.requirements : _req;
    final benefits = live ? job.benefits : _benefits;
    final daysLeft = job.closingDate?.difference(DateTime.now()).inDays;

    final header = DCard(
      padding: EdgeInsets.all(phone ? 18 : 28),
      child: Wrap(
        spacing: 20,
        runSpacing: 16,
        children: [
          Hero(
            tag: 'job-logo-${job.id}',
            child: DInitials(
              job.ini,
              size: 64,
              bg: jm.accentSoft,
              fg: jm.onAccentSoft,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    job.title,
                    style: type.h1.copyWith(fontSize: phone ? 26 : 34),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DLink(
                      job.company,
                      onTap: () => context.to(
                        Routes.employerProfile(job.orgSlug ?? 'kobo-logistics'),
                      ),
                    ),
                    Text(
                      ' · ${job.location}',
                      style: type.body.copyWith(color: jm.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    DVerifiedPill(job.verification),
                    if (live)
                      for (final t in job.type.split(' · ')) DTag(t)
                    else ...[
                      const DTag('Full-time'),
                      const DTag('Hybrid (3 days on-site)'),
                      const DTag('1–3 years'),
                    ],
                    DTag(job.salary),
                  ],
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: live
                            ? 'Posted ${job.posted} · '
                            : 'Posted 17 Nov 2026 · ',
                      ),
                      TextSpan(
                        text: live
                            ? (daysLeft == null
                                  ? 'Open until filled'
                                  : daysLeft < 0
                                  ? 'Closed ${job.closes}'
                                  : 'Closes ${job.closes} ($daysLeft days left)')
                            : 'Closes ${job.closes} 2026 (23 days left)',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(
                        text: ' · Vacancy reviewed by JobsAndMore',
                      ),
                    ],
                  ),
                  style: type.small.copyWith(color: jm.textMuted),
                ),
              ],
            ),
          ),
          if (!phone)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DBtn(
                  'Apply now',
                  height: 50,
                  onTap: () => context.to(Routes.apply(job.id)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _SaveButton(job),
                    const SizedBox(width: 8),
                    DBtn(
                      'Share',
                      style: DBtnStyle.secondary,
                      icon: Icons.ios_share_rounded,
                      height: 44,
                      onTap: () {
                        unawaited(
                          Clipboard.setData(
                            ClipboardData(
                              text: '${Env.siteUrl}/jobs/${job.id}',
                            ),
                          ),
                        );
                        showJmToast(context, 'Link copied');
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );

    final article = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (about.isNotEmpty) _section('About the role', body: about),
        if (resp.isNotEmpty) _section('Responsibilities', bullets: resp),
        if (req.isNotEmpty) _section('Requirements', bullets: req),
        if (benefits.isNotEmpty) _section('Benefits', bullets: benefits),
        _section(
          'How to apply',
          body: 'Apply on JobsAndMore with your CV and answer 3 short screening questions. Shortlisted candidates hear back within 10 working days of the closing date.',
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: [
            Text(
              'Something wrong with this listing?',
              style: type.small.copyWith(color: jm.textMuted),
            ),
            DBtn(
              'Report listing',
              style: DBtnStyle.secondary,
              icon: Icons.flag_outlined,
              height: 40,
              fontSize: 14,
              onTap: _report,
            ),
          ],
        ),
      ],
    );

    final company = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('About Kobo Logistics', style: type.h4),
          const SizedBox(height: 8),
          Text(
            'Last-mile delivery company · 51–200 staff · Lagos, Ogun, Oyo',
            style: type.small.copyWith(color: jm.textMuted),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: jm.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification checks',
                  style: type.label.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                for (final c in [
                  'Business email verified',
                  'CAC registration reviewed',
                  'Authorised recruiter confirmed',
                ])
                  Text(
                    '✓ $c',
                    style: type.small.copyWith(
                      color: jm.onPrimarySoft,
                      height: 1.7,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  'Last checked 2 Oct 2026',
                  style: type.caption.copyWith(color: jm.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DLink(
            'View company profile · 4 open roles',
            onTap: () => context.to(Routes.employerProfile('kobo-logistics')),
          ),
        ],
      ),
    );

    final safety = DNotice(
      bg: jm.accentSoft,
      child: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Stay safe: ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: 'genuine employers never ask for payment to apply or interview.',
            ),
          ],
        ),
      ),
    );

    if (phone) {
      return Scaffold(
        backgroundColor: jm.background,
        appBar: AppBar(
          backgroundColor: jm.surface,
          leading: BackButton(onPressed: () => context.to(Routes.jobs)),
          actions: [
            IconButton(
              tooltip: 'Share',
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () => showJmToast(context, 'Link copied'),
            ),
            IconButton(
              tooltip: 'More: report listing',
              icon: const Icon(Icons.more_horiz_rounded),
              onPressed: _report,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            header,
            const SizedBox(height: 12),
            DCard(
              padding: const EdgeInsets.all(16),
              color: jm.primarySoft,
              borderColor: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Your match',
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        !live ? '82%' : (job.match > 0 ? '${job.match}%' : '—'),
                        style: type.h4.copyWith(color: jm.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    !live
                        ? 'Matches: Excel, reporting, 2 yrs ops. Gap: SQL.'
                        : job.match > 0
                        ? 'Estimate from your skills, location and target roles.'
                        : 'Add skills and target roles to your profile to see a match estimate.',
                    style: type.small,
                  ),
                  const SizedBox(height: 8),
                  DLink(
                    'Check my CV for this job',
                    onTap: () => context.to(Routes.ats),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DTabs(
              tabs: const ['Role', 'Requirements', 'Company'],
              current: _tab,
              onTap: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 16),
            if (_tab == 0) ...[
              if (about.isNotEmpty) _section('About the role', body: about),
              if (resp.isNotEmpty) _section('Responsibilities', bullets: resp),
            ],
            if (_tab == 1) ...[
              if (req.isNotEmpty) _section('Requirements', bullets: req),
              if (benefits.isNotEmpty) _section('Benefits', bullets: benefits),
            ],
            if (_tab == 2) company,
            const SizedBox(height: 12),
            safety,
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: jm.surface,
              border: Border(top: BorderSide(color: jm.border)),
            ),
            child: Row(
              children: [
                _SaveButton(job),
                const SizedBox(width: 10),
                Expanded(
                  child: DBtn(
                    'Apply now',
                    height: 52,
                    expand: true,
                    onTap: () => context.to(Routes.apply(job.id)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DPage(
      active: NavItem.jobs,
      mode: NavMode.seeker,
      body: DContainer(
        maxWidth: 1200,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DLink('Find Jobs', onTap: () => context.to(Routes.jobs)),
                Text(
                  '  /  Analyst  /  ${job.title}',
                  style: type.small.copyWith(color: jm.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            header,
            const SizedBox(height: 24),
            DSplit(
              asideWidth: 360,
              main: DCard(padding: const EdgeInsets.all(32), child: article),
              aside: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _match(job),
                  const SizedBox(height: 16),
                  company,
                  const SizedBox(height: 16),
                  safety,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 08 Apply – CV, cover letter, screening, review (M07 on phones).
class ApplyScreen extends ConsumerStatefulWidget {
  const new({required this.jobId, super.key});

  final String jobId;

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  int _step = Env.hasSupabase ? 0 : 3;
  int _cv = 0;
  bool _accurate = !Env.hasSupabase;
  bool _share = true;
  bool _onsite = true;
  bool _busy = false;
  bool _uploading = false;
  final _answers = <String, String>{};
  final _letter = TextEditingController(
    text: Env.hasSupabase ? '' : "Dear Hiring Team,\n\nI'm applying for the Operations Analyst role at Kobo Logistics. In my two years at a Lagos distribution firm, I built weekly delivery reports in Excel that helped my team spot late-dispatch patterns…",
  );

  static const _stepNames = [
    'CV',
    'Cover letter',
    'Screening questions',
    'Review & submit',
  ];

  @override
  void dispose() {
    _letter.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_accurate) {
      showJmToast(
        context,
        'Please confirm your information is accurate.',
        tone: JmTone.warning,
      );
      return;
    }
    final job = ref.read(jobProvider(widget.jobId)).valueOrNull;
    if (job == null || !job.isLive) {
      showJmToast(
        context,
        'Application sent to Kobo Logistics',
        tone: JmTone.success,
      );
      context.to(Routes.applications);
      return;
    }
    final unanswered = job.screening.where(
      (q) => (_answers['${q['id']}'] ?? '').trim().isEmpty,
    );
    if (unanswered.isNotEmpty) {
      setState(() => _step = 2);
      showJmToast(
        context,
        'Please answer the screening questions.',
        tone: JmTone.warning,
      );
      return;
    }
    final cvs = ref.read(myCvsProvider).valueOrNull ?? const <CvDoc>[];
    setState(() => _busy = true);
    try {
      await applyToJob(
        jobId: job.id,
        coverLetter: _letter.text,
        answers: _answers,
        cvId: cvs.isEmpty ? null : cvs[_cv.clamp(0, cvs.length - 1)].id,
      );
      ref.invalidate(myApplicationsProvider);
      if (!mounted) return;
      showJmToast(
        context,
        'Application sent to ${job.company}',
        tone: JmTone.success,
      );
      context.to(Routes.applications);
    } on DataFailure catch (e) {
      if (!mounted) return;
      showJmToast(context, e.message, tone: JmTone.error);
      if (currentUserId == null) context.to(Routes.signIn);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _uploadCv() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
    );
    final file = picked.firstOrNull;
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      await uploadCv(await file.xFile.readAsBytes(), file.name);
      ref.invalidate(myCvsProvider);
      if (mounted) {
        setState(() => _cv = 0);
        showJmToast(context, 'CV uploaded', tone: JmTone.success);
      }
    } on DataFailure catch (e) {
      if (mounted) showJmToast(context, e.message, tone: JmTone.error);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Widget _stepper() {
    final jm = context.jm;
    final type = context.type;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < 4; i++)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => setState(() => _step = i),
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
              decoration: BoxDecoration(
                color: i == _step ? jm.primarySoft : jm.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: i == _step ? jm.primary : jm.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i < _step
                          ? jm.primary
                          : (i == _step ? jm.surface : jm.surfaceAlt),
                      shape: BoxShape.circle,
                      border: i == _step
                          ? Border.all(color: jm.primary, width: 2)
                          : null,
                    ),
                    child: Text(
                      i < _step ? '✓' : '${i + 1}',
                      style: type.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: i < _step ? jm.onPrimary : jm.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _stepNames[i],
                    style: type.label.copyWith(
                      fontWeight: i == _step
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _cvSection() {
    final jm = context.jm;
    final type = context.type;
    Widget opt(int i, String name, String meta) => InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _cv = i),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _cv == i ? jm.primary : jm.border,
            width: _cv == i ? 2 : 1,
          ),
          color: _cv == i ? jm.primarySoft : null,
        ),
        child: Row(
          children: [
            Icon(
              _cv == i
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: _cv == i ? jm.primary : jm.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: type.label.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    meta,
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
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('CV to send', style: type.h4)),
            DLink(
              _uploading ? 'Uploading…' : 'Upload a CV',
              onTap: _uploading ? () {} : _uploadCv,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (Env.hasSupabase) ...[
          for (final (i, cv)
              in (ref.watch(myCvsProvider).valueOrNull ?? const <CvDoc>[])
                  .indexed) ...[
            opt(
              i,
              cv.title,
              'Uploaded ${fmtDay(cv.updatedAt)}${cv.primary ? ' · Main CV' : ''}',
            ),
            const SizedBox(height: 8),
          ],
          if ((ref.watch(myCvsProvider).valueOrNull ?? const []).isEmpty)
            DDashedBox(
              child: Column(
                children: [
                  Text(
                    'No CV yet. Upload a PDF or Word file (up to 10 MB).',
                    textAlign: TextAlign.center,
                    style: type.small.copyWith(color: jm.textMuted),
                  ),
                  const SizedBox(height: 10),
                  DBtn(
                    _uploading ? 'Uploading…' : 'Upload CV',
                    icon: Icons.upload_file_rounded,
                    onTap: _uploading ? null : _uploadCv,
                  ),
                ],
              ),
            ),
        ] else ...[
          opt(
            0,
            'Amaka_Okafor_Operations.pdf',
            'Updated 15 Nov · CV check 74/100 (estimate)',
          ),
          const SizedBox(height: 8),
          opt(1, 'Amaka_Okafor_General.docx', 'Updated 2 Sep'),
        ],
      ],
    );
  }

  Widget _letterSection() {
    final jm = context.jm;
    final type = context.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 6,
          children: [
            Text('Cover letter', style: type.h4),
            DPill(
              'Drafted with AI · edited by you',
              bg: jm.infoSoft,
              fg: jm.info,
            ),
          ],
        ),
        const SizedBox(height: 12),
        DField(label: 'Letter text', controller: _letter, maxLines: 7),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            DBtn(
              'Regenerate',
              style: DBtnStyle.secondary,
              icon: Icons.refresh_rounded,
              height: 40,
              fontSize: 14,
              onTap: () => showJmToast(
                context,
                'A new draft would be generated from your profile – nothing invented.',
              ),
            ),
            DBtn(
              'Make it shorter',
              style: DBtnStyle.secondary,
              height: 40,
              fontSize: 14,
              onTap: () {},
            ),
            DBtn(
              'Remove AI draft',
              style: DBtnStyle.secondary,
              height: 40,
              fontSize: 14,
              onTap: () => setState(_letter.clear),
            ),
          ],
        ),
      ],
    );
  }

  Widget _liveScreening(DemoJob job, {required bool editable}) {
    final jm = context.jm;
    final type = context.type;
    if (job.screening.isEmpty) {
      return Text(
        'This employer has no screening questions.',
        style: type.body.copyWith(color: jm.textMuted),
      );
    }
    if (!editable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Screening answers', style: type.h4),
          const SizedBox(height: 8),
          for (final q in job.screening)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${q['question']}\n'),
                    TextSpan(
                      text: (_answers['${q['id']}'] ?? '').isEmpty
                          ? 'Not answered'
                          : _answers['${q['id']}'],
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                style: type.small,
              ),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('A few questions from the employer', style: type.h3),
        const SizedBox(height: 16),
        for (final q in job.screening) ...[
          Text('${q['question']}', style: type.label),
          const SizedBox(height: 8),
          if (q['options'] is List)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in (q['options'] as List))
                  DChoicePill(
                    label: '$o',
                    selected: _answers['${q['id']}'] == '$o',
                    onTap: () => setState(() => _answers['${q['id']}'] = '$o'),
                  ),
              ],
            )
          else
            DField(
              label: 'Your answer',
              initial: _answers['${q['id']}'],
              onChanged: (v) => _answers['${q['id']}'] = v,
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _screening({required bool editable}) {
    final jm = context.jm;
    final type = context.type;
    final liveJob = ref.watch(jobProvider(widget.jobId)).valueOrNull;
    if (liveJob != null && liveJob.isLive) {
      return _liveScreening(liveJob, editable: editable);
    }
    if (editable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('A few questions from the employer', style: type.h3),
          const SizedBox(height: 16),
          Text(
            'Can you work on-site in Yaba 3 days a week?',
            style: type.label,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              DChoicePill(
                label: 'Yes',
                selected: _onsite,
                onTap: () => setState(() => _onsite = true),
              ),
              DChoicePill(
                label: 'No',
                selected: !_onsite,
                onTap: () => setState(() => _onsite = false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const DField(
            label: 'Years of operations experience',
            initial: '2',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const DField(label: 'Earliest start date', initial: '5 January 2027'),
          const SizedBox(height: 12),
          DLink('Need an adjustment to answer these questions?', onTap: () {}),
        ],
      );
    }
    const qa = [
      ('Can you work on-site 3 days a week in Yaba?', 'Yes'),
      ('Years of operations experience', '2 years'),
      ('Earliest start date', '5 January 2027'),
      ('Need an adjustment for the assessment?', 'No'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Screening answers', style: type.h4)),
            DLink('Edit', onTap: () => setState(() => _step = 2)),
          ],
        ),
        const SizedBox(height: 8),
        for (final (q, a) in qa)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: jm.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    q,
                    style: type.small.copyWith(color: jm.textMuted),
                  ),
                ),
                Text(a, style: type.label),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final job = ref.watch(jobProvider(widget.jobId)).valueOrNull;
    final phone = DPage.isPhone(context);
    if (job == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final confirm = Column(
      children: [
        DCheck(
          value: _accurate,
          onChanged: (v) => setState(() => _accurate = v),
          label: const Text(
            'I confirm that the information in my CV, cover letter and answers is accurate.',
          ),
        ),
        const SizedBox(height: 10),
        DCheck(
          value: _share,
          onChanged: (v) => setState(() => _share = v),
          label: Text(
            'Share my career profile (not contact details) with ${job.company.replaceAll(' Ltd', '')} for this application only.',
          ),
        ),
      ],
    );

    if (phone) {
      final content = switch (_step) {
        0 => _cvSection(),
        1 => _letterSection(),
        2 => _screening(editable: true),
        _ => Column(
          children: [
            _cvSection(),
            const SizedBox(height: 20),
            _screening(editable: false),
            const SizedBox(height: 20),
            confirm,
          ],
        ),
      };
      return Scaffold(
        backgroundColor: jm.surface,
        appBar: AppBar(
          backgroundColor: jm.surface,
          leading: IconButton(
            tooltip: 'Close application',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.to(Routes.jobDetail(job.id)),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: type.label.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'Draft saved',
                style: type.caption.copyWith(color: jm.textMuted),
              ),
            ],
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Step ${_step + 1} of 4',
                  style: type.caption.copyWith(color: jm.textMuted),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: DBar((_step + 1) / 4, height: 4),
          ),
        ),
        body: ListView(padding: const EdgeInsets.all(20), children: [content]),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: jm.border)),
            ),
            child: Row(
              children: [
                DBtn(
                  'Back',
                  style: DBtnStyle.ghost,
                  onTap: _step == 0 ? null : () => setState(() => _step--),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DBtn(
                    _step == 3
                        ? 'Submit application'
                        : (_step == 2 ? 'Next: Review' : 'Next'),
                    height: 52,
                    expand: true,
                    onTap: _step == 3
                        ? (_busy ? null : _submit)
                        : () => setState(() => _step++),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_step == 0 || _step == 3) DCard(child: _cvSection()),
        if (_step == 1 || _step == 3) ...[
          const SizedBox(height: 16),
          DCard(child: _letterSection()),
        ],
        if (_step == 2) DCard(child: _screening(editable: true)),
        if (_step == 3) ...[
          const SizedBox(height: 16),
          DCard(child: _screening(editable: false)),
          const SizedBox(height: 16),
          DCard(child: confirm),
        ],
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            DLink(
              'Save and finish later',
              onTap: () {
                showJmToast(context, 'Draft saved');
                context.to(Routes.dashboard);
              },
            ),
            if (_step < 3)
              DBtn('Continue', height: 50, onTap: () => setState(() => _step++))
            else
              DBtn('Submit application', height: 50, onTap: _submit),
          ],
        ),
      ],
    );

    final aside = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applying to',
            style: type.caption.copyWith(
              color: jm.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(job.title, style: type.h4),
          Text(
            'Kobo Logistics · Lagos · Hybrid',
            style: type.small.copyWith(color: jm.textMuted),
          ),
          const SizedBox(height: 6),
          Text(
            'Closes ${job.closes} 2026',
            style: type.small.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: jm.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'After you submit\n',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: "You'll see the status in My Applications and get an email when the employer updates your stage.",
                  ),
                ],
              ),
              style: type.small.copyWith(height: 1.55),
            ),
          ),
        ],
      ),
    );

    return DPage(
      active: NavItem.jobs,
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
                '← Back to job',
                onTap: () => context.to(Routes.jobDetail(job.id)),
              ),
            ),
            const SizedBox(height: 8),
            Text('Apply: ${job.title}', style: type.h1.copyWith(fontSize: 32)),
            Text(
              '${job.company} · Draft saved automatically 2 min ago',
              style: type.small.copyWith(color: jm.textMuted),
            ),
            const SizedBox(height: 20),
            _stepper(),
            const SizedBox(height: 24),
            DSplit(asideWidth: 320, main: main, aside: aside),
          ],
        ),
      ),
    );
  }
}
