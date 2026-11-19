import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

/// 13 Job alerts (M12 "New job alert" on phones).
class JobAlertsScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<JobAlertsScreen> createState() => _JobAlertsScreenState();
}

class _JobAlertsScreenState extends State<JobAlertsScreen> {
  int _selected = 0;
  bool _paused = false;
  String _state = 'Lagos';
  String _radius = 'Within 25 km';
  String _freq = 'Daily digest (7am)';
  final _include = {'Ogun', 'Remote (Nigeria)'};
  final _work = {'Full-time', 'Hybrid'};
  final _channels = {'Email', 'In-app & push (mobile app)'};

  static const _alerts = [
    ('Analyst – Lagos + nearby', 'Daily · Email + push · 6 new today', true),
    ('Graduate trainee – Remote', 'Weekly · Email', false),
    ('Scholarships – Economics MSc', 'Weekly · Email · Opportunities', true),
  ];

  Future<void> _askLocation() async {
    final type = context.type;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DIconTile(
              Icons.location_on_outlined,
              size: 52,
              bg: sheet.jm.primarySoft,
            ),
            const SizedBox(height: 14),
            Text('Find jobs within a distance?', style: type.h3),
            const SizedBox(height: 8),
            Text(
              "We'll use your location only to match jobs within your chosen radius. It's never shown to employers, and you can turn it off any time.",
              style: type.body.copyWith(color: sheet.jm.textMuted),
            ),
            const SizedBox(height: 20),
            DBtn(
              'Allow while using the app',
              expand: true,
              onTap: () => Navigator.of(sheet).pop(),
            ),
            const SizedBox(height: 10),
            DBtn(
              'Use my chosen states only',
              style: DBtnStyle.secondary,
              expand: true,
              onTap: () => Navigator.of(sheet).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final phone = DPage.isPhone(context);

    Widget checks(String legend, List<String> opts, Set<String> set) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(legend, style: type.label.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in opts)
              DChoicePill(
                label: o,
                multi: true,
                selected: set.contains(o),
                onTap: () => setState(
                  () => set.contains(o) ? set.remove(o) : set.add(o),
                ),
              ),
          ],
        ),
      ],
    );

    final editor = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  phone ? 'New job alert' : 'Edit alert',
                  style: type.h3,
                ),
              ),
              if (!phone) ...[
                DBtn(
                  _paused ? 'Resume' : 'Pause',
                  style: DBtnStyle.secondary,
                  height: 40,
                  fontSize: 14,
                  onTap: () => setState(() => _paused = !_paused),
                ),
                const SizedBox(width: 8),
                DBtn(
                  'Delete',
                  style: DBtnStyle.danger,
                  height: 40,
                  fontSize: 14,
                  onTap: () => showJmDialog(
                    context: context,
                    title: 'Delete this alert?',
                    message: "You'll stop receiving these jobs. This can't be undone.",
                    confirmLabel: 'Delete alert',
                    destructive: true,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          if (!phone) ...[
            const DField(
              label: 'Alert name',
              initial: 'Analyst – Lagos + nearby',
            ),
            const SizedBox(height: 16),
          ],
          DField(
            label: phone ? 'Keywords' : 'Job titles or keywords',
            initial: phone
                ? 'Analyst'
                : 'Operations Analyst, Data Analyst, Business Analyst',
          ),
          const SizedBox(height: 18),
          Text(
            'Location',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          DGrid(
            minItemWidth: 180,
            gap: 12,
            maxColumns: 3,
            children: [
              DSelect<String>(
                label: 'State',
                value: _state,
                items: const ['Lagos', 'Abuja (FCT)', 'Ogun', 'Oyo', 'Rivers'],
                onChanged: (v) => setState(() => _state = v),
              ),
              const DField(label: 'City / area', initial: 'Yaba'),
              DSelect<String>(
                label: 'Radius',
                value: _radius,
                items: const [
                  'Within 10 km',
                  'Within 25 km',
                  'Within 50 km',
                  'Whole state',
                ],
                onChanged: (v) => setState(() => _radius = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          checks('Also include', const [
            'Ogun',
            'Oyo',
            'Remote (Nigeria)',
          ], _include),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Radius uses the area you typed, not your device location. ',
                style: type.caption.copyWith(color: jm.textMuted, fontSize: 13),
              ),
              DLink('Use my precise location instead', onTap: _askLocation),
            ],
          ),
          const SizedBox(height: 18),
          checks('Work type', const [
            'Full-time',
            'Hybrid',
            'Contract',
            'Internship',
          ], _work),
          const SizedBox(height: 18),
          Text(
            'Frequency',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in [
                'Immediately',
                'Daily digest (7am)',
                'Weekly digest',
              ])
                DChoicePill(
                  label: f,
                  selected: _freq == f,
                  onTap: () => setState(() => _freq = f),
                ),
            ],
          ),
          const SizedBox(height: 18),
          checks('Send to', const [
            'Email',
            'In-app & push (mobile app)',
            'WhatsApp – requires opt-in',
          ], _channels),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: jm.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'Preview: about '),
                  TextSpan(
                    text: '12 new matching jobs a week',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: ' based on the last 30 days. Duplicates and closed roles are removed.',
                  ),
                ],
              ),
              style: type.small,
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: DBtn(
              'Save alert',
              expand: phone,
              height: phone ? 52 : 48,
              onTap: () =>
                  showJmToast(context, 'Alert saved', tone: JmTone.success),
            ),
          ),
        ],
      ),
    );

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (name, meta, active)) in _alerts.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DCard(
              padding: const EdgeInsets.all(16),
              borderColor: i == _selected ? jm.primary : null,
              onTap: () => setState(() => _selected = i),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DPill(
                        active ? 'Active' : 'Paused',
                        bg: active ? jm.primarySoft : jm.surfaceSunken,
                        fg: active ? jm.onPrimarySoft : jm.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
          ),
      ],
    );

    return DPage(
      active: NavItem.jobs,
      mode: NavMode.seeker,
      mobileTitle: 'New job alert',
      mobileBody: Padding(padding: const EdgeInsets.all(16), child: editor),
      body: DContainer(
        maxWidth: 1100,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job alerts', style: type.h1.copyWith(fontSize: 32)),
                    Text(
                      'Alerts use the locations and preferences you choose – we never assume.',
                      style: type.body.copyWith(color: jm.textMuted),
                    ),
                  ],
                ),
                DBtn('+ New alert', onTap: () {}),
              ],
            ),
            const SizedBox(height: 24),
            DSplit(
              asideOnRight: false,
              asideWidth: 340,
              aside: list,
              main: editor,
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice {
  const new(this.cat, this.time, this.title, this.body, {this.unread = false});
  final String cat;
  final String time;
  final String title;
  final String body;
  final bool unread;
}

const _notices = [
  _Notice(
    'Message',
    '09:02',
    'Kobo Logistics invited you to interview',
    'Choose a slot by Fri 21 Nov',
    unread: true,
  ),
  _Notice(
    'Application',
    'Yesterday',
    'Greenfield Agro shortlisted you',
    'Graduate Trainee · next: assessment',
    unread: true,
  ),
  _Notice(
    'Job alert',
    'Yesterday',
    '6 new jobs: Analyst – Lagos + nearby',
    'Top match: Business Analyst (71%)',
    unread: true,
  ),
  _Notice(
    'Course',
    '17 Nov',
    'Quiz due in Excel for Data Reporting',
    'Module 4 · due 30 Nov',
  ),
  _Notice(
    'Account',
    '15 Nov',
    'New sign-in from Chrome on Windows',
    'Not you? Secure your account',
  ),
];

class _SlotPicker extends StatefulWidget {
  const new({this.compact = false});
  final bool compact;

  @override
  State<_SlotPicker> createState() => _SlotPickerState();
}

class _SlotPickerState extends State<_SlotPicker> {
  int _slot = 0;
  static const _slots = [
    'Mon 24 Nov, 10:00',
    'Mon 24 Nov, 14:00',
    'Tue 25 Nov, 11:00',
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (i, s) in _slots.indexed)
            DChoicePill(
              label: widget.compact
                  ? s.replaceAll(' 24 Nov,', '').replaceAll(' 25 Nov,', '')
                  : s,
              selected: i == _slot,
              onTap: () => setState(() => _slot = i),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          DBtn(
            widget.compact ? 'Confirm ${_slots[_slot]}' : 'Confirm slot',
            expand: widget.compact,
            onTap: () => showJmToast(
              context,
              'Interview confirmed for ${_slots[_slot]}',
              tone: JmTone.success,
            ),
          ),
          if (!widget.compact)
            DBtn(
              'Request another time',
              style: DBtnStyle.secondary,
              onTap: () {},
            ),
        ],
      ),
    ],
  );
}

/// 14 Messages & notifications (M13 Notifications on phones).
class InboxScreen extends StatefulWidget {
  const new({this.notificationsOnly = false, super.key});

  final bool notificationsOnly;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  int _filter = 0;
  int _open = 0;
  bool _allRead = false;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final phone = DPage.isPhone(context);

    Widget item(int i, _Notice n) => InkWell(
      onTap: () => setState(() => _open = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: !phone && i == _open ? jm.primarySoft : null,
          border: Border(bottom: BorderSide(color: jm.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: n.unread && !_allRead
                      ? JmBrand.alert
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${n.cat} · ${n.time}',
                    style: type.caption.copyWith(color: jm.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.title,
                    style: type.label.copyWith(
                      fontWeight: n.unread && !_allRead
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  Text(
                    n.body,
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

    if (phone || widget.notificationsOnly) {
      final body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DTabs(
            tabs: const [
              'All',
              'Messages',
              'Applications',
              'Alerts',
              'Courses',
            ],
            current: _filter,
            onTap: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'TODAY',
              style: type.overline.copyWith(color: jm.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          DCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DInitials(
                      'KL',
                      size: 40,
                      bg: jm.accentSoft,
                      fg: jm.onAccentSoft,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interview invitation',
                            style: type.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Kobo Logistics · Operations Analyst · pick by Fri',
                            style: type.caption.copyWith(
                              color: jm.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '09:02',
                      style: type.caption.copyWith(color: jm.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _SlotPicker(compact: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, n) in _notices.skip(1).indexed) item(i + 1, n),
              ],
            ),
          ),
        ],
      );
      return DPage(
        active: NavItem.home,
        mode: NavMode.seeker,
        mobileTitle: 'Notifications',
        mobileActions: [
          TextButton(
            onPressed: () => setState(() => _allRead = true),
            child: const Text('Mark all read'),
          ),
        ],
        mobileBody: Padding(padding: const EdgeInsets.all(16), child: body),
        body: DContainer(
          maxWidth: 760,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: type.h1.copyWith(fontSize: 32),
                    ),
                  ),
                  DLink(
                    'Mark all read',
                    onTap: () => setState(() => _allRead = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              body,
            ],
          ),
        ),
      );
    }

    final filters = DCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Inbox', style: type.h3),
          ),
          for (final (i, (label, count)) in [
            ('All', '3'),
            ('Messages', '1'),
            ('Applications', '1'),
            ('Job alerts', '1'),
            ('Courses', ''),
            ('Account & security', ''),
            ('Notification settings', ''),
          ].indexed)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => i == 6
                  ? context.to(Routes.settings)
                  : setState(() => _filter = i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: i == _filter ? jm.primarySoft : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: type.small.copyWith(
                          fontWeight: i == _filter
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: i == _filter ? jm.onPrimarySoft : jm.text,
                        ),
                      ),
                    ),
                    if (count.isNotEmpty)
                      DPill(
                        count,
                        bg: JmBrand.alert,
                        fg: Colors.white,
                        fontSize: 11,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    final conversation = DCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: jm.border)),
            ),
            child: Row(
              children: [
                DInitials(
                  'KL',
                  size: 44,
                  bg: jm.accentSoft,
                  fg: jm.onAccentSoft,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kobo Logistics · Recruitment',
                        style: type.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Re: Operations Analyst · Verified employer',
                        style: type.caption.copyWith(
                          color: jm.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'More options: report or block',
                  onSelected: (v) => showJmToast(
                    context,
                    v == 'report'
                        ? 'Report sent to our team'
                        : 'Kobo Logistics blocked',
                  ),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'report',
                      child: Text('Report conversation'),
                    ),
                    PopupMenuItem(value: 'block', child: Text('Block sender')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: jm.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi Amaka, thanks for applying. We'd like to invite you to a 30-minute video interview. Please choose a slot below.",
                        style: type.body.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tunde A. · Recruiter · 09:02',
                        style: type.caption.copyWith(color: jm.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: jm.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Interview invitation',
                        style: type.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Video call · 30 min · Panel of 2',
                        style: type.small.copyWith(color: jm.textMuted),
                      ),
                      const SizedBox(height: 12),
                      const _SlotPicker(),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: jm.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Your phone number and email stay hidden until you choose to share them.',
                        style: type.caption.copyWith(
                          color: jm.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: jm.border)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Write a message…',
                      labelText: 'Message',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DBtn('Send', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );

    return DPage(
      active: NavItem.home,
      mode: NavMode.seeker,
      body: DContainer(
        maxWidth: 1280,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: LayoutBuilder(
          builder: (context, c) {
            final listCard = DCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [for (final (i, n) in _notices.indexed) item(i, n)],
              ),
            );
            if (c.maxWidth < 1000) {
              return Column(
                children: [listCard, const SizedBox(height: 16), conversation],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 240, child: filters),
                const SizedBox(width: 16),
                SizedBox(width: 360, child: listCard),
                const SizedBox(width: 16),
                Expanded(child: conversation),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// M14 My courses / Learn tab.
class MyCoursesScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CONTINUE LEARNING',
          style: type.overline.copyWith(color: jm.textMuted),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DTint.forest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Excel for Data Reporting',
                style: type.h4.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 10),
              const DBar(0.6, color: JmBrand.amber),
              const SizedBox(height: 8),
              Text(
                'Module 4 · Pivot tables · 18 min left',
                style: type.small.copyWith(color: DTint.onDarkMuted),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: DBtn(
                  'Resume',
                  style: DBtnStyle.amber,
                  height: 44,
                  onTap: () =>
                      context.to(Routes.course('excel-data-reporting')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DTabs(
          tabs: const ['In progress (2)', 'Completed (1)', 'Saved'],
          current: _tab,
          onTap: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 12),
        if (_tab == 0)
          DCard(
            padding: const EdgeInsets.all(16),
            onTap: () => context.to(Routes.academy),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Intro to SQL for Analysts',
                        style: type.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text('10%', style: type.label),
                  ],
                ),
                const SizedBox(height: 8),
                const DBar(0.1),
                const SizedBox(height: 6),
                Text(
                  'Recommended for your SQL skill gap',
                  style: type.caption.copyWith(
                    color: jm.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          DCard(
            child: Text(
              _tab == 1
                  ? 'Workplace Readiness – completed 3 Oct.'
                  : 'Courses you save appear here.',
              style: type.body.copyWith(color: jm.textMuted),
            ),
          ),
        const SizedBox(height: 20),
        Text('Certificates', style: type.h4),
        const SizedBox(height: 10),
        DCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              DIconTile(
                Icons.workspace_premium_outlined,
                size: 44,
                bg: jm.accentSoft,
                fg: jm.onAccentSoft,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workplace Readiness',
                      style: type.label.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Completed 3 Oct · ID JAM-7Q2K-91XD',
                      style: type.caption.copyWith(
                        color: jm.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              DLink(
                'Share',
                onTap: () => showJmToast(context, 'Verification link copied'),
              ),
            ],
          ),
        ),
      ],
    );
    return DPage(
      active: NavItem.academy,
      mode: NavMode.seeker,
      mobileTab: MobileTab.learn,
      mobileBody: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Learn', style: type.h2.copyWith(fontSize: 26)),
                ),
                DLink(
                  'Browse courses',
                  onTap: () => context.to(Routes.academy),
                ),
              ],
            ),
            const SizedBox(height: 16),
            body,
          ],
        ),
      ),
      body: DContainer(
        maxWidth: 760,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'My learning',
                    style: type.h1.copyWith(fontSize: 32),
                  ),
                ),
                DLink(
                  'Browse courses',
                  onTap: () => context.to(Routes.academy),
                ),
              ],
            ),
            const SizedBox(height: 16),
            body,
          ],
        ),
      ),
    );
  }
}

/// M16 Settings & privacy. Each consent is separate and withdrawable.
class SettingsScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _on = <String, bool>{
    'Application updates': true,
    'Messages from employers': true,
    'Job alerts': true,
    'Course reminders': false,
    'WhatsApp messages': false,
    'Career tips by email': false,
    'Use precise location': false,
    'Help improve AI tools with my anonymised data': false,
  };

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    Widget toggle(String n, {String? sub}) => SwitchListTile(
      title: Text(
        n,
        style: type.small.copyWith(color: jm.text, fontWeight: FontWeight.w600),
      ),
      subtitle: sub == null
          ? null
          : Text(sub, style: type.caption.copyWith(color: jm.textMuted)),
      value: _on[n]!,
      onChanged: (v) => setState(() => _on[n] = v),
    );
    Widget link(String n, String v, {VoidCallback? onTap}) => ListTile(
      title: Text(
        n,
        style: type.small.copyWith(color: jm.text, fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(v, style: type.caption.copyWith(color: jm.textMuted)),
          Icon(Icons.chevron_right_rounded, color: jm.textMuted),
        ],
      ),
      onTap: onTap ?? () {},
    );
    Widget group(String h, List<Widget> rows) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              h.toUpperCase(),
              style: type.overline.copyWith(color: jm.textMuted),
            ),
          ),
          DCard(
            padding: EdgeInsets.zero,
            child: Column(children: rows),
          ),
        ],
      ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        group('Notifications', [
          toggle('Application updates'),
          toggle('Messages from employers'),
          toggle('Job alerts'),
          toggle('Course reminders'),
          link('Quiet hours', '22:00 – 07:00'),
          toggle('WhatsApp messages', sub: 'Only with your explicit opt-in'),
        ]),
        group('Privacy & consent', [
          link('Profile visibility', 'Verified employers'),
          link('CV sharing', 'Only when I apply'),
          toggle('Use precise location', sub: 'For radius job alerts only'),
          toggle('Career tips by email'),
          toggle(
            'Help improve AI tools with my anonymised data',
            sub: 'Optional – off by default',
          ),
        ]),
        group('Account & security', [
          link('Email', 'amaka.o@example.com'),
          link('Password', 'Change'),
          link('Two-step verification', 'Off'),
          link('Download my data', 'Request export'),
        ]),
        Center(
          child: TextButton(
            onPressed: () => showJmDialog(
              context: context,
              title: 'Close your account?',
              message: 'Your profile, CVs and applications will be deleted after 30 days. Employers keep only what the law requires.',
              confirmLabel: 'Close my account',
              destructive: true,
            ),
            child: Text(
              'Close my account',
              style: type.label.copyWith(color: jm.error),
            ),
          ),
        ),
      ],
    );
    return DPage(
      active: NavItem.home,
      mode: NavMode.seeker,
      mobileTitle: 'Settings & privacy',
      mobileBody: Padding(padding: const EdgeInsets.all(16), child: body),
      body: DContainer(
        maxWidth: 720,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Settings & privacy', style: type.h1.copyWith(fontSize: 32)),
            const SizedBox(height: 20),
            body,
          ],
        ),
      ),
    );
  }
}
