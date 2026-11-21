import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/env.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/data/live_data.dart';
import 'package:jobsandmore/features/demo/demo_data.dart';
import 'package:jobsandmore/features/profile/presentation/live_profile.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

/// Stage pill colours used across applications.
(Color, Color) stageColors(BuildContext c, String stage) => switch (stage) {
  'Interview' => (DTint.blue(c), DTint.blueText(c)),
  'Under review' => (c.jm.accentSoft, c.jm.onAccentSoft),
  'Shortlisted' => (c.jm.primarySoft, c.jm.onPrimarySoft),
  _ => (c.jm.surfaceSunken, c.jm.textMuted),
};

class _App {
  const new(this.role, this.co, this.date, this.stage, this.upd);
  final String role;
  final String co;
  final String date;
  final String stage;
  final String upd;
}

const _apps = [
  _App('Operations Analyst', 'Kobo Logistics', '18 Nov', 'Interview', 'Today'),
  _App(
    'Inventory Officer',
    'Ola Foods',
    '10 Nov',
    'Under review',
    '3 days ago',
  ),
  _App(
    'Graduate Trainee',
    'Greenfield Agro',
    '2 Nov',
    'Shortlisted',
    '1 week ago',
  ),
  _App(
    'Admin Assistant',
    'Lekki Dental Clinic',
    '20 Oct',
    'Not progressed',
    '4 Nov',
  ),
];

Widget _cardHead(
  BuildContext context,
  String title, {
  String? action,
  VoidCallback? onAction,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 14),
  child: Row(
    children: [
      Expanded(
        child: Semantics(
          header: true,
          child: Text(title, style: context.type.h4),
        ),
      ),
      if (action != null) DLink(action, onTap: onAction ?? () {}),
    ],
  ),
);

/// 09 Job Seeker dashboard (M04 Home on phones).
class SeekerDashboardScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jm = context.jm;
    final type = context.type;
    final phone = DPage.isPhone(context);

    // Live data (falls back to the design's sample content offline).
    final live = Env.hasSupabase;
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final myApps =
        ref.watch(myApplicationsProvider).valueOrNull ??
        const <MyApplication>[];
    final apps = live
        ? [
            for (final a in myApps)
              _App(
                a.job.title,
                a.job.company,
                fmtDay(a.appliedAt),
                stageLabel(a.stage),
                fmtAgo(a.updatedAt),
              ),
          ]
        : _apps;
    final listings =
        ref.watch(jobListingsProvider).valueOrNull ?? const <DemoJob>[];
    final recs = live
        ? ([...listings]..sort((a, b) => b.match.compareTo(a.match)))
        : Demo.jobs;
    final first = live ? (profile?.firstName ?? 'there') : Demo.seekerFirst;
    final fullName = live ? (profile?.fullName ?? '') : Demo.seekerName;
    final completionPct = live ? (profile?.completion ?? 0) : 72;
    final cvs = ref.watch(myCvsProvider).valueOrNull ?? const <CvDoc>[];
    final interview = myApps.where((a) => a.stage == 'interview').firstOrNull;
    final (nextText, nextCta, nextRoute) = !live
        ? (
            'Kobo Logistics invited you to an interview – pick a time slot by Fri 21 Nov.',
            'Choose a slot',
            Routes.inbox,
          )
        : interview != null
        ? (
            '${interview.job.company} moved you to the interview stage for ${interview.job.title}. Check your messages.',
            'Open messages',
            Routes.inbox,
          )
        : cvs.isEmpty
        ? (
            'Upload your CV so you can apply to jobs in a few taps.',
            'Add my CV',
            Routes.profile,
          )
        : completionPct < 80
        ? (
            'Your profile is $completionPct% complete. Add skills and experience to get better match estimates.',
            'Complete profile',
            Routes.profile,
          )
        : (
            'New jobs are posted every day. Find your next role.',
            'Find jobs',
            Routes.jobs,
          );
    final tips = live
        ? <(String, String)>[
            if (cvs.isEmpty) ('Upload your CV', 'Add'),
            if ((profile?.skills ?? const []).isEmpty)
              ('Add your skills', 'Add'),
            if ((profile?.headline ?? '').isEmpty) ('Write a headline', 'Add'),
            if ((profile?.phone ?? '').isEmpty) ('Add a phone number', 'Add'),
            if ((profile?.about ?? '').isEmpty)
              ('Tell employers about you', 'Add'),
          ].take(3).toList()
        : const [
            ('Add certificates & awards', '+10%'),
            ('Add a second skill set', '+8%'),
            ('Add languages', '+5%'),
          ];
    final myCourses = live
        ? (ref.watch(myCoursesProvider).valueOrNull ?? const <DemoCourse>[])
        : const <DemoCourse>[];
    final alerts =
        ref.watch(jobAlertsProvider).valueOrNull ?? const <JobAlert>[];
    final savedCount = ref.watch(savedJobsProvider).length;

    final nextAction = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DTint.forest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 14,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DEyebrow('Next best action', color: JmBrand.amber),
                const SizedBox(height: 6),
                Text(
                  nextText,
                  style: type.label.copyWith(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          DBtn(
            nextCta,
            style: DBtnStyle.amber,
            onTap: () => context.to(nextRoute),
          ),
        ],
      ),
    );

    final completion = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHead(
            context,
            'Profile completion',
            action: 'Edit profile',
            onAction: () => context.to(Routes.profile),
          ),
          Row(
            children: [
              DRing(
                completionPct,
                size: 80,
                stroke: 8,
                label: 'Profile completion',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'This measures how complete your profile is – not how employable you are.',
                  style: type.small.copyWith(color: jm.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final (t, p) in tips)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: jm.border)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(t, style: type.small)),
                  DLink(p, onTap: () => context.to(Routes.profile)),
                ],
              ),
            ),
        ],
      ),
    );

    final recommended = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHead(
            context,
            'Recommended jobs',
            action: live ? 'See all ${listings.length}' : 'See all 24',
            onAction: () => context.to(Routes.jobs),
          ),
          if (live && recs.isEmpty)
            Text(
              'No open jobs right now. New jobs appear here as employers post them.',
              style: type.small.copyWith(color: jm.textMuted),
            ),
          for (final j in recs.take(3))
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => context.to(Routes.jobDetail(j.id)),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
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
                            j.title,
                            style: type.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${j.company.replaceAll(' Ltd', '')} · ${j.location} · closes ${j.closes}',
                            style: type.caption.copyWith(
                              color: jm.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DPill(j.match > 0 ? '${j.match}%' : j.listing),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    final applications = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHead(
            context,
            'My applications',
            action: 'View history',
            onAction: () => context.to(Routes.applications),
          ),
          if (live && apps.isEmpty)
            Text(
              'You have not applied for a job yet. When you do, you can follow every step here.',
              style: type.small.copyWith(color: jm.textMuted),
            )
          else
            DTable(
              columns: const [
                ('Role', 3),
                ('Employer', 3),
                ('Applied', 2),
                ('Stage', 3),
                ('Last update', 2),
              ],
              rows: [
                for (final a in apps)
                  [
                    Text(
                      a.role,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(a.co),
                    Text(a.date),
                    Builder(
                      builder: (c) {
                        final (bg, fg) = stageColors(c, a.stage);
                        return DPill(a.stage, bg: bg, fg: fg);
                      },
                    ),
                    Text(a.upd),
                  ],
              ],
            ),
        ],
      ),
    );

    final assistant = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHead(context, 'AI Career Assistant'),
          DGrid(
            minItemWidth: 140,
            gap: 10,
            children: [
              for (final (t, r) in [
                ('Check my CV', Routes.ats),
                ('Build a CV', Routes.tools),
                ('Write a cover letter', Routes.tools),
                ('Practise interview', Routes.interview),
              ])
                DBtn(
                  t,
                  style: DBtnStyle.secondary,
                  expand: true,
                  height: 46,
                  fontSize: 14,
                  onTap: () => context.to(r),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                live
                    ? 'AI suggestions are always editable · '
                    : 'AI credits this month: 7 of 10 left · ',
                style: type.small.copyWith(color: jm.textMuted),
              ),
              DLink(
                'Get more with Career Plus',
                onTap: () => context.to(Routes.pricing),
              ),
            ],
          ),
        ],
      ),
    );

    final courses = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHead(
            context,
            'My courses',
            action: 'Browse',
            onAction: () => context.to(Routes.academy),
          ),
          if (live) ...[
            if (myCourses.isEmpty)
              Text(
                'You have not enrolled in a course yet.',
                style: type.small.copyWith(color: jm.textMuted),
              ),
            for (final c in myCourses.take(3)) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c.title,
                      style: type.label.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    (c.progress ?? 0) == 0
                        ? 'Not started'
                        : '${((c.progress ?? 0) * 100).round()}%',
                    style: type.label,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DBar(c.progress ?? 0),
              const SizedBox(height: 14),
            ],
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Excel for Data Reporting',
                    style: type.label.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text('60%', style: type.label),
              ],
            ),
            const SizedBox(height: 8),
            const DBar(0.6),
            const SizedBox(height: 6),
            Text(
              'Next: Module 4 – Pivot tables · Quiz due 30 Nov',
              style: type.caption.copyWith(color: jm.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Intro to SQL',
                    style: type.label.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  'Not started',
                  style: type.caption.copyWith(color: jm.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const DBar(0),
            const SizedBox(height: 6),
            Text(
              'Recommended to close your SQL skill gap',
              style: type.caption.copyWith(color: jm.textMuted, fontSize: 13),
            ),
          ],
        ],
      ),
    );

    final saved = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHead(
            context,
            'Saved jobs & alerts',
            action: 'Manage',
            onAction: () => context.to(Routes.alerts),
          ),
          for (final (t, tag, on)
              in live
                  ? [
                      (
                        savedCount == 1
                            ? '1 saved job'
                            : '$savedCount saved jobs',
                        'View',
                        savedCount > 0,
                      ),
                      for (final a in alerts.take(3))
                        (
                          '"${a.name}" · ${a.frequency[0].toUpperCase()}${a.frequency.substring(1)}',
                          a.paused ? 'Paused' : 'On',
                          !a.paused,
                        ),
                      if (alerts.isEmpty)
                        ('No job alerts yet', 'Create', false),
                    ]
                  : const [
                      ('5 saved jobs · 1 closing in 2 days', 'View', true),
                      ('"Analyst – Lagos + nearby" · Daily', '6 new', true),
                      ('"Graduate trainee – Remote" · Weekly', 'Paused', false),
                    ])
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: jm.border)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(t, style: type.small)),
                  DPill(
                    tag,
                    bg: on ? jm.primarySoft : jm.surfaceSunken,
                    fg: on ? jm.onPrimarySoft : jm.textMuted,
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    final rewards = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHead(context, 'Rewards & referrals'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                live ? '${profile?.points ?? 0}' : '120',
                style: type.h1.copyWith(color: jm.primary),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    live ? 'points' : 'points · 2 friends joined',
                    style: type.small.copyWith(color: jm.textMuted),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            children: [
              Text(
                'Points expire 12 months after earning. ',
                style: type.caption.copyWith(color: jm.textMuted, fontSize: 13),
              ),
              DLink('Read the rules', onTap: () {}),
            ],
          ),
          const SizedBox(height: 12),
          DBtn(
            'Copy referral link',
            style: DBtnStyle.secondary,
            icon: Icons.link_rounded,
            onTap: () {
              final code = profile?.referralCode;
              if (live && code != null) {
                unawaited(
                  Clipboard.setData(
                    ClipboardData(text: '${Env.siteUrl}/get-started?ref=$code'),
                  ),
                );
              }
              showJmToast(context, 'Referral link copied');
            },
          ),
        ],
      ),
    );

    if (phone) {
      return DPage(
        mobileTab: MobileTab.home,
        mode: NavMode.seeker,
        body: const SizedBox.shrink(),
        mobileBody: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  DInitials(
                    live
                        ? initialsOf(fullName.isEmpty ? first : fullName)
                        : 'AO',
                    size: 44,
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
                          'Good morning',
                          style: type.small.copyWith(color: jm.textMuted),
                        ),
                        Text(first, style: type.h2.copyWith(fontSize: 24)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Notifications, 3 unread',
                    onPressed: () => context.to(Routes.notifications),
                    icon: const Badge(
                      smallSize: 9,
                      backgroundColor: JmBrand.alert,
                      child: Icon(Icons.notifications_none_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.to(Routes.jobs),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: jm.surface,
                    border: Border.all(color: jm.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: jm.textMuted),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Search jobs, skills, companies',
                          style: type.body.copyWith(color: jm.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DTint.forest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DEyebrow('Next step', color: JmBrand.amber),
                    const SizedBox(height: 6),
                    Text(
                      live ? nextText : 'Kobo Logistics invited you to interview. Pick a slot by Fri.',
                      style: type.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DBtn(
                      live ? nextCta : 'Choose a time',
                      style: DBtnStyle.amber,
                      height: 44,
                      onTap: () =>
                          context.to(live ? nextRoute : Routes.notifications),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DCard(
                padding: const EdgeInsets.all(14),
                onTap: () => context.to(Routes.profile),
                child: Row(
                  children: [
                    DRing(completionPct, size: 48, stroke: 5),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complete your profile',
                            style: type.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            live
                                ? (tips.isEmpty
                                      ? 'Looking good'
                                      : tips.first.$1)
                                : 'Add certificates (+10%)',
                            style: type.caption.copyWith(
                              color: jm.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: jm.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Text('Recommended', style: type.h4)),
                  DLink('See all', onTap: () => context.to(Routes.jobs)),
                ],
              ),
              const SizedBox(height: 10),
              for (final j in recs.take(2))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => context.to(Routes.jobDetail(j.id)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DInitials(j.ini, size: 40),
                            const Spacer(),
                            DPill(
                              j.match > 0 ? '${j.match}% match' : j.listing,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          j.title,
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${j.company.replaceAll(' Ltd', '')} · ${j.location}',
                          style: type.caption.copyWith(
                            color: jm.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DVerifiedPill(j.verification),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Text('Career tools', style: type.h4),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final (ini, t, r) in [
                    ('CV', 'CV check', Routes.ats),
                    ('+', 'Build CV', Routes.tools),
                    ('IC', 'Interview', Routes.interview),
                    ('!', 'Alerts', Routes.alerts),
                  ])
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.to(r),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              DInitials(ini, size: 48),
                              const SizedBox(height: 6),
                              Text(
                                t,
                                style: type.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return DPage(
      active: NavItem.home,
      mode: NavMode.seeker,
      body: DContainer(
        maxWidth: 1280,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: DPhotoBackdrop(
                asset: DImages.lagos,
                alignment: const Alignment(0, 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    runSpacing: 16,
                    spacing: 16,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning, $first',
                            style: type.h1.copyWith(
                              fontSize: 34,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Here's what needs your attention today.",
                            style: type.body.copyWith(color: DTint.onDarkMuted),
                          ),
                        ],
                      ),
                      DBtn(
                        'Find jobs',
                        style: DBtnStyle.white,
                        icon: Icons.search_rounded,
                        onTap: () => context.to(Routes.jobs),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            nextAction,
            const SizedBox(height: 20),
            DSplit(
              asideWidth: 380,
              gap: 20,
              breakpoint: 1000,
              main: Column(
                children: [
                  recommended,
                  const SizedBox(height: 20),
                  applications,
                  const SizedBox(height: 20),
                  assistant,
                ],
              ),
              aside: Column(
                children: [
                  completion,
                  const SizedBox(height: 20),
                  courses,
                  const SizedBox(height: 20),
                  saved,
                  const SizedBox(height: 20),
                  rewards,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// M08 My applications (also reachable on web from "View history").
class ApplicationsScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    const timeline = [
      ('Applied · 18 Nov', true),
      ('Shortlisted · 18 Nov', true),
      ('Interview – choose a slot', false),
      ('Decision', false),
    ];

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DTabs(
          tabs: const ['Active (3)', 'Closed', 'Drafts (1)'],
          current: _tab,
          onTap: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 16),
        if (_tab == 0) ...[
          DCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operations Analyst',
                            style: type.label.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Kobo Logistics · applied 18 Nov',
                            style: type.caption.copyWith(
                              color: jm.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (c) {
                        final (bg, fg) = stageColors(c, 'Interview');
                        return DPill('Interview', bg: bg, fg: fg);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final (i, (t, done)) in timeline.indexed)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(
                            done
                                ? Icons.check_circle_rounded
                                : (i == 2
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded),
                            size: 20,
                            color: done || i == 2
                                ? jm.primary
                                : jm.borderStrong,
                          ),
                          if (i < timeline.length - 1)
                            Container(
                              width: 2,
                              height: 18,
                              color: done ? jm.primary : jm.border,
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          t,
                          style: type.small.copyWith(
                            fontWeight: i == 2
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: done || i == 2 ? jm.text : jm.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                DBtn(
                  'Choose interview slot',
                  expand: true,
                  onTap: () => context.to(Routes.notifications),
                ),
              ],
            ),
          ),
          for (final a in _apps.skip(1).take(2))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: DCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.role,
                            style: type.label.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${a.co} · updated ${a.upd}',
                            style: type.caption.copyWith(
                              color: jm.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (c) {
                        final (bg, fg) = stageColors(c, a.stage);
                        return DPill(a.stage, bg: bg, fg: fg);
                      },
                    ),
                  ],
                ),
              ),
            ),
        ] else
          DCard(
            child: Text(
              _tab == 1
                  ? 'Applications that were not progressed or withdrawn appear here.'
                  : 'You have 1 draft: Business Analyst – Pinnacle Bank Services.',
              style: type.body.copyWith(color: jm.textMuted),
            ),
          ),
      ],
    );

    final shownList = Env.hasSupabase ? const LiveApplicationsList() : list;
    return DPage(
      active: NavItem.home,
      mode: NavMode.seeker,
      mobileTab: MobileTab.applications,
      mobileBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!Env.hasSupabase)
              const DNotice(
                icon: Icons.check_circle_outline_rounded,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Application sent',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' to Kobo Logistics.'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text('My applications', style: type.h2.copyWith(fontSize: 26)),
            const SizedBox(height: 12),
            shownList,
          ],
        ),
      ),
      body: DContainer(
        maxWidth: 860,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('My applications', style: type.h1.copyWith(fontSize: 32)),
            const SizedBox(height: 16),
            shownList,
          ],
        ),
      ),
    );
  }
}

/// 10 Career Profile (M09 on phones).
class CareerProfileScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<CareerProfileScreen> createState() => _CareerProfileScreenState();
}

enum _Done { complete, partial, empty }

class _CareerProfileScreenState extends State<CareerProfileScreen> {
  int _section = 1;
  String _visibility = 'Visible to verified employers';
  bool _suggestionVisible = true;
  bool _certsNa = false;
  final _headline = TextEditingController(
    text: 'Operations analyst who turns delivery data into faster, cheaper logistics',
  );
  final _summary = TextEditingController(
    text: "I have two years' experience in distribution operations in Lagos, where I built weekly Excel reports on dispatch times and stock levels…",
  );

  static const _sections = <(String, _Done, String)>[
    ('Overview', _Done.complete, '—'),
    ('About Me', _Done.partial, '10%'),
    ('Employment & Availability', _Done.complete, '10%'),
    ('Experience & Education', _Done.complete, '20%'),
    ('Skills & preferences', _Done.partial, '15%'),
    ('Associations', _Done.empty, '5%'),
    ('Certificates & Awards', _Done.empty, '5%'),
    ('Languages', _Done.empty, '5%'),
    ('Cover Letters', _Done.complete, '—'),
    ('Portfolio & CV', _Done.complete, '15%'),
    ('Account Settings', _Done.complete, '5%'),
  ];

  static const _suggestion =
      'Operations analyst with 2 years in Lagos distribution. Built weekly Excel dispatch reports that helped the team spot late deliveries. Now learning SQL to scale analysis.';

  @override
  void dispose() {
    _headline.dispose();
    _summary.dispose();
    super.dispose();
  }

  Color _dot(_Done d) => switch (d) {
    _Done.complete => context.jm.primary,
    _Done.partial => const Color(0xFFE0A030),
    _Done.empty => context.jm.borderStrong,
  };

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final phone = DPage.isPhone(context);

    final nav = DCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Profile sections', style: type.h4)),
              Text('72%', style: type.h4.copyWith(color: jm.primary)),
            ],
          ),
          const SizedBox(height: 8),
          const DBar(0.72, height: 6),
          const SizedBox(height: 12),
          for (final (i, (name, done, w)) in _sections.indexed)
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
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _dot(done),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        style: type.small.copyWith(
                          fontWeight: i == _section
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: i == _section ? jm.onPrimarySoft : jm.text,
                        ),
                      ),
                    ),
                    Text(w, style: type.caption.copyWith(color: jm.textMuted)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            'Green = complete · Amber = partly done · Grey = not started. Mark sections "Not applicable" so they don\'t count against you.',
            style: type.caption.copyWith(color: jm.textMuted, height: 1.5),
          ),
        ],
      ),
    );

    final header = DCard(
      child: Wrap(
        spacing: 18,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DInitials(
            'AO',
            size: 72,
            circle: true,
            bg: jm.accentSoft,
            fg: jm.onAccentSoft,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Demo.seekerName, style: type.h2.copyWith(fontSize: 28)),
                Text(
                  'Operations & data reporting · 2 yrs experience',
                  style: type.body,
                ),
                const SizedBox(height: 4),
                Text(
                  'Yaba, Lagos · Available from Jan 2027 · Open to Operations Analyst, Data Analyst',
                  style: type.small.copyWith(color: jm.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DSelect<String>(
                  label: 'Profile visibility',
                  value: _visibility,
                  items: const [
                    'Visible to verified employers',
                    'Only employers I apply to',
                    'Hidden',
                  ],
                  onChanged: (v) => setState(() => _visibility = v),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DLink('Preview as employer', onTap: () {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final about = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('About Me', style: type.h3)),
              Text(
                'Counts for 10% of completion',
                style: type.caption.copyWith(color: jm.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DField(label: 'Professional headline', controller: _headline),
          const SizedBox(height: 16),
          DField(
            label: 'Professional summary',
            controller: _summary,
            maxLines: 5,
          ),
          if (_suggestionVisible) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DTint.blue(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        size: 18,
                        color: DTint.blueText(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI suggestion – review before saving',
                        style: type.label.copyWith(
                          color: DTint.blueText(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"$_suggestion"',
                    style: type.body.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based only on facts in your profile. Nothing has been added.',
                    style: type.caption.copyWith(color: jm.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      DBtn(
                        'Use this',
                        height: 40,
                        fontSize: 14,
                        onTap: () => setState(() {
                          _summary.text = _suggestion;
                          _suggestionVisible = false;
                        }),
                      ),
                      DBtn(
                        'Regenerate',
                        style: DBtnStyle.secondary,
                        height: 40,
                        fontSize: 14,
                        onTap: () => showJmToast(
                          context,
                          'A new suggestion would be generated from your profile facts.',
                        ),
                      ),
                      DBtn(
                        'Dismiss',
                        style: DBtnStyle.ghost,
                        height: 40,
                        fontSize: 14,
                        onTap: () => setState(() => _suggestionVisible = false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DBtn('Cancel', style: DBtnStyle.ghost, onTap: () {}),
              const SizedBox(width: 8),
              DBtn(
                'Save section',
                onTap: () => showJmToast(
                  context,
                  'About Me saved',
                  tone: JmTone.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    Widget entry(String title, String sub, String body) => Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: jm.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Text(sub, style: type.small.copyWith(color: jm.textMuted)),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(body, style: type.small),
                ],
              ],
            ),
          ),
          DLink('Edit', onTap: () {}),
        ],
      ),
    );

    final experience = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Experience & Education', style: type.h3)),
              DBtn(
                '+ Add',
                style: DBtnStyle.secondary,
                height: 40,
                fontSize: 14,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          entry(
            'Operations Assistant',
            'Mainland Distribution Co. · Lagos · Oct 2024 – present',
            'Built weekly dispatch reports; reduced stock-count errors by introducing a shared tracker.',
          ),
          entry(
            'BSc Economics, Second Class Upper',
            'University of Lagos · 2019 – 2023',
            '',
          ),
        ],
      ),
    );

    final certs = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Certificates & Awards', style: type.h3),
          const SizedBox(height: 8),
          Text(
            _certsNa
                ? 'Marked as not applicable – this section no longer counts against your completion.'
                : 'Add credential ID and issue date so employers can verify them.',
            style: type.small.copyWith(color: jm.textMuted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DBtn(
                _certsNa ? 'Undo not applicable' : 'Mark as not applicable',
                style: DBtnStyle.secondary,
                height: 40,
                fontSize: 14,
                onTap: () => setState(() => _certsNa = !_certsNa),
              ),
              DBtn('+ Add certificate', height: 40, fontSize: 14, onTap: () {}),
            ],
          ),
        ],
      ),
    );

    final cv = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Portfolio & CV', style: type.h3)),
              DBtn(
                'Upload CV',
                icon: Icons.upload_rounded,
                height: 40,
                fontSize: 14,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 14),
          DDashedBox(
            child: Center(
              child: Text(
                'Drag a PDF or DOCX here (max 5 MB). Files are virus-scanned on upload.',
                textAlign: TextAlign.center,
                style: type.small.copyWith(color: jm.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final (name, date, def) in [
            ('Amaka_Okafor_Operations.pdf', '15 Nov 2026', true),
            ('Amaka_Okafor_General.docx', '2 Sep 2026', false),
          ])
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: jm.border)),
              ),
              child: Row(
                children: [
                  Icon(Icons.description_outlined, color: jm.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (def) const TextSpan(text: ' · default'),
                        ],
                      ),
                      style: type.small,
                    ),
                  ),
                  Text(date, style: type.caption.copyWith(color: jm.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );

    if (Env.hasSupabase) {
      return const DPage(
        active: NavItem.home,
        mode: NavMode.seeker,
        mobileTab: MobileTab.profile,
        mobileTitle: 'My profile',
        mobileBody: Padding(
          padding: EdgeInsets.all(16),
          child: LiveCareerProfile(),
        ),
        body: DContainer(
          maxWidth: 1280,
          padding: EdgeInsets.fromLTRB(24, 32, 24, 64),
          child: LiveCareerProfile(),
        ),
      );
    }

    if (phone) {
      return DPage(
        mobileTab: MobileTab.profile,
        mode: NavMode.seeker,
        body: const SizedBox.shrink(),
        mobileBody: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  DInitials(
                    'AO',
                    size: 56,
                    circle: true,
                    bg: jm.accentSoft,
                    fg: jm.onAccentSoft,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Demo.seekerName, style: type.h3),
                        Text(
                          'Operations & data reporting · Lagos',
                          style: type.caption.copyWith(
                            color: jm.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () => context.to(Routes.settings),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Profile 72% complete',
                            style: type.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          'Completeness, not a rating',
                          style: type.caption.copyWith(color: jm.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const DBar(0.72),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Visible to verified employers',
                    style: type.label,
                  ),
                  value: _visibility == 'Visible to verified employers',
                  onChanged: (v) => setState(
                    () => _visibility = v
                        ? 'Visible to verified employers'
                        : 'Only employers I apply to',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final (name, done, _) in _sections.skip(1))
                      ListTile(
                        leading: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _dot(done),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          name,
                          style: type.small.copyWith(color: jm.text),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              switch (done) {
                                _Done.complete => 'Done',
                                _Done.partial => 'In progress',
                                _Done.empty => 'Add',
                              },
                              style: type.caption.copyWith(color: jm.textMuted),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: jm.textMuted,
                            ),
                          ],
                        ),
                        onTap: () {},
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DPage(
      active: NavItem.home,
      mode: NavMode.seeker,
      body: DContainer(
        maxWidth: 1280,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: DSplit(
          asideOnRight: false,
          asideWidth: 300,
          gap: 24,
          breakpoint: 980,
          aside: nav,
          main: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: 20),
              about,
              const SizedBox(height: 20),
              experience,
              const SizedBox(height: 20),
              certs,
              const SizedBox(height: 20),
              cv,
            ],
          ),
        ),
      ),
    );
  }
}
