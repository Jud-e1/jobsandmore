// Live account screens: job alerts, inbox & notifications, my learning,
// privacy choices and the staff verification queue. Built from the design
// kit and connected to the database.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/data/live_data.dart';
import 'package:jobsandmore/features/home/presentation/home_screen.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

Widget _signInFirst(BuildContext context, String what) => DCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Sign in to $what.', style: context.type.h4),
      const SizedBox(height: 12),
      DBtn('Sign in', onTap: () => context.to(Routes.signIn)),
    ],
  ),
);

// --------------------------------------------------------------- alerts ---

class LiveJobAlerts extends ConsumerStatefulWidget {
  const new({super.key});
  @override
  ConsumerState<LiveJobAlerts> createState() => _LiveJobAlertsState();
}

class _LiveJobAlertsState extends ConsumerState<LiveJobAlerts> {
  final _keywords = TextEditingController();
  final _states = <String>{'Lagos'};
  bool _nearby = true;
  String _freq = 'daily';
  final _channels = <String>{'email', 'in_app'};
  bool _busy = false;

  static const _stateOptions = [
    'Lagos',
    'FCT Abuja',
    'Rivers',
    'Oyo',
    'Ogun',
    'Kano',
    'Kaduna',
    'Enugu',
    'Anambra',
    'Delta',
    'Edo',
    'Remote (Nigeria)',
  ];
  static const _codes = {
    'Lagos': 'LA',
    'FCT Abuja': 'FC',
    'Rivers': 'RI',
    'Oyo': 'OY',
    'Ogun': 'OG',
    'Kano': 'KN',
    'Kaduna': 'KD',
    'Enugu': 'EN',
    'Anambra': 'AN',
    'Delta': 'DE',
    'Edo': 'ED',
  };

  @override
  void dispose() {
    _keywords.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final kw = _keywords.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (kw.isEmpty) {
      showJmToast(
        context,
        'Add at least one keyword, e.g. "analyst".',
        tone: JmTone.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await createJobAlert(
        name:
            '${kw.join(', ')} – ${_states.isEmpty ? 'Anywhere' : _states.join(', ')}',
        keywords: kw,
        states: [for (final s in _states) ?_codes[s]],
        nearby: _nearby,
        frequency: _freq,
        channels: _channels.toList(),
      );
      ref.invalidate(jobAlertsProvider);
      _keywords.clear();
      if (mounted) {
        showJmToast(context, 'Job alert created', tone: JmTone.success);
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
    if (currentUserId == null) {
      return _signInFirst(context, 'create job alerts');
    }
    final alerts =
        ref.watch(jobAlertsProvider).valueOrNull ?? const <JobAlert>[];

    final form = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New job alert', style: type.h3),
          const SizedBox(height: 14),
          DField(
            label: 'Keywords (comma separated)',
            controller: _keywords,
            hint: 'analyst, data, operations',
          ),
          const SizedBox(height: 14),
          Text(
            'Locations',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _stateOptions)
                DChoicePill(
                  label: s,
                  selected: _states.contains(s),
                  onTap: () => setState(
                    () => _states.contains(s)
                        ? _states.remove(s)
                        : _states.add(s),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          DCheck(
            value: _nearby,
            onChanged: (v) => setState(() => _nearby = v),
            label: const Text('Include neighbouring states'),
          ),
          const SizedBox(height: 14),
          DSelect<String>(
            label: 'How often',
            value: _freq,
            items: const ['immediate', 'daily', 'weekly'],
            itemLabel: (v) => switch (v) {
              'immediate' => 'As soon as posted',
              'daily' => 'Daily digest',
              _ => 'Weekly digest',
            },
            onChanged: (v) => setState(() => _freq = v),
          ),
          const SizedBox(height: 14),
          Text(
            'Send to',
            style: type.label.copyWith(fontWeight: FontWeight.w700),
          ),
          for (final (k, l) in const [
            ('email', 'Email'),
            ('in_app', 'In-app'),
            ('whatsapp', 'WhatsApp'),
          ])
            DCheck(
              value: _channels.contains(k),
              onChanged: (v) =>
                  setState(() => v ? _channels.add(k) : _channels.remove(k)),
              label: Text(l),
            ),
          const SizedBox(height: 16),
          DBtn(
            _busy ? 'Saving…' : 'Create alert',
            onTap: _busy ? null : _create,
          ),
        ],
      ),
    );

    final list = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your alerts (${alerts.length})', style: type.h4),
          const SizedBox(height: 10),
          if (alerts.isEmpty)
            Text(
              'No alerts yet. Create one and we will tell you about new matching jobs.',
              style: type.small.copyWith(color: jm.textMuted),
            ),
          for (final a in alerts)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: jm.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name,
                          style: type.label.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${a.frequency[0].toUpperCase()}${a.frequency.substring(1)} · ${a.channels.join(' + ')}',
                          style: type.caption.copyWith(color: jm.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: !a.paused,
                    onChanged: (on) async {
                      try {
                        await setAlertPaused(a.id, !on);
                        ref.invalidate(jobAlertsProvider);
                      } on DataFailure catch (e) {
                        if (context.mounted) {
                          showJmToast(context, e.message, tone: JmTone.error);
                        }
                      }
                    },
                  ),
                  IconButton(
                    tooltip: 'Delete alert',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () async {
                      try {
                        await deleteJobAlert(a.id);
                        ref.invalidate(jobAlertsProvider);
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
        ],
      ),
    );

    return DSplit(
      asideWidth: 420,
      gap: 20,
      breakpoint: 980,
      main: list,
      aside: form,
    );
  }
}

// ---------------------------------------------------------------- inbox ---

class LiveInbox extends ConsumerStatefulWidget {
  const new({this.notificationsOnly = false, super.key});
  final bool notificationsOnly;
  @override
  ConsumerState<LiveInbox> createState() => _LiveInboxState();
}

class _LiveInboxState extends ConsumerState<LiveInbox> {
  late int _tab = widget.notificationsOnly ? 1 : 0;
  String? _open;
  final _reply = TextEditingController();

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  IconData _icon(String cat) => switch (cat) {
    'application' => Icons.work_outline_rounded,
    'interview' => Icons.event_outlined,
    'message' => Icons.chat_bubble_outline_rounded,
    'course' => Icons.school_outlined,
    'billing' => Icons.receipt_long_outlined,
    'verification' => Icons.verified_outlined,
    'job_alert' => Icons.notifications_active_outlined,
    _ => Icons.info_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    if (currentUserId == null) {
      return _signInFirst(context, 'see your messages');
    }
    final convs =
        ref.watch(conversationsProvider).valueOrNull ?? const <Conversation>[];
    final notes =
        ref.watch(notificationsProvider).valueOrNull ??
        const <AppNotification>[];
    final unread = notes.where((n) => !n.read).length;

    final notifications = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Notifications', style: type.h4)),
            if (unread > 0)
              DLink(
                'Mark all as read',
                onTap: () async {
                  await markAllNotificationsRead();
                  ref.invalidate(notificationsProvider);
                },
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (notes.isEmpty)
          Text(
            'No notifications yet. Updates on your applications, alerts and courses appear here.',
            style: type.small.copyWith(color: jm.textMuted),
          ),
        for (final n in notes)
          DCard(
            padding: const EdgeInsets.all(14),
            color: n.read ? null : jm.primarySoft,
            borderColor: n.read ? null : Colors.transparent,
            onTap: n.link == null ? null : () => context.to(n.link!),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DIconTile(_icon(n.category), size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: type.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (n.body != null) Text(n.body!, style: type.small),
                      Text(
                        fmtAgo(n.at),
                        style: type.caption.copyWith(color: jm.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    final open = _open == null
        ? null
        : convs.where((c) => c.id == _open).firstOrNull;
    final messages = open == null
        ? const <ChatMessage>[]
        : (ref.watch(messagesProvider(open.id)).valueOrNull ??
              const <ChatMessage>[]);

    final chat = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (convs.isEmpty)
          DCard(
            child: Text(
              'No conversations yet. When an employer contacts you about an application, the conversation appears here.',
              style: type.body.copyWith(color: jm.textMuted),
            ),
          ),
        for (final c in convs)
          DCard(
            padding: const EdgeInsets.all(14),
            color: c.id == _open ? jm.primarySoft : null,
            onTap: () => setState(() => _open = c.id),
            child: Row(
              children: [
                DInitials(initialsOf(c.subject), size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.subject,
                        style: type.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        c.preview ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.small.copyWith(color: jm.textMuted),
                      ),
                    ],
                  ),
                ),
                Text(
                  fmtAgo(c.lastAt),
                  style: type.caption.copyWith(color: jm.textMuted),
                ),
              ],
            ),
          ),
        if (open != null) ...[
          const SizedBox(height: 16),
          DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(open.subject, style: type.h4),
                const SizedBox(height: 12),
                for (final m in messages)
                  Align(
                    alignment: m.mine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: m.mine ? jm.primary : jm.surfaceSunken,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        m.body,
                        style: type.body.copyWith(
                          color: m.mine ? jm.onPrimary : jm.text,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DField(
                        label: 'Reply',
                        controller: _reply,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: DBtn(
                        'Send',
                        onTap: () async {
                          final t = _reply.text.trim();
                          if (t.isEmpty) return;
                          try {
                            await sendMessage(open.id, t);
                            _reply.clear();
                            ref
                              ..invalidate(messagesProvider(open.id))
                              ..invalidate(conversationsProvider);
                          } on DataFailure catch (e) {
                            if (context.mounted) {
                              showJmToast(
                                context,
                                e.message,
                                tone: JmTone.error,
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.notificationsOnly) ...[
          DTabs(
            tabs: [
              'Messages (${convs.length})',
              'Notifications${unread > 0 ? ' ($unread)' : ''}',
            ],
            current: _tab,
            onTap: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 16),
        ],
        if (_tab == 0) chat else notifications,
      ],
    );
  }
}

// ---------------------------------------------------------- my learning ---

class LiveMyCourses extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jm = context.jm;
    final type = context.type;
    if (currentUserId == null) return _signInFirst(context, 'see your courses');
    final courses = ref.watch(myCoursesProvider).valueOrNull ?? const [];
    if (courses.isEmpty) {
      return DCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have not enrolled in a course yet.', style: type.h4),
            const SizedBox(height: 6),
            Text(
              'Free and paid courses with verifiable certificates.',
              style: type.small.copyWith(color: jm.textMuted),
            ),
            const SizedBox(height: 12),
            DBtn('Browse the Academy', onTap: () => context.to(Routes.academy)),
          ],
        ),
      );
    }
    return DGrid(
      minItemWidth: 260,
      maxColumns: 3,
      children: [for (final c in courses) DCourseCard(c)],
    );
  }
}

// ------------------------------------------------------ privacy choices ---

class LiveConsents extends ConsumerWidget {
  const new({super.key});

  static const _items = [
    ('marketing_email', 'Career tips and product news by email'),
    ('whatsapp', 'Job alerts and updates on WhatsApp'),
    ('profile_discoverable', 'Let verified employers find my profile'),
    ('ai_processing', 'Use AI tools on my CV and profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jm = context.jm;
    final type = context.type;
    final p = ref.watch(myProfileProvider).valueOrNull;
    if (p == null) return const SizedBox.shrink();
    bool on(String k) {
      final v = p.consents[k];
      return v is Map ? v['granted'] == true : v == true;
    }

    return DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Privacy choices', style: type.h4),
          const SizedBox(height: 4),
          Text(
            'Each choice is separate and you can change it at any time.',
            style: type.small.copyWith(color: jm.textMuted),
          ),
          const SizedBox(height: 10),
          for (final (k, l) in _items)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l, style: type.body),
              value: on(k),
              onChanged: (v) async {
                try {
                  await setConsent(k, v);
                  ref.invalidate(myProfileProvider);
                } on DataFailure catch (e) {
                  if (context.mounted) {
                    showJmToast(context, e.message, tone: JmTone.error);
                  }
                }
              },
            ),
          const SizedBox(height: 8),
          Text(
            'Signed in as ${p.email}',
            style: type.caption.copyWith(color: jm.textMuted),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------ verification queue ----

class LiveVerificationQueue extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jm = context.jm;
    final type = context.type;
    if (currentUserId == null) {
      return _signInFirst(context, 'use the admin area');
    }
    final staff = ref.watch(isStaffProvider).valueOrNull ?? false;
    if (!staff) {
      return DCard(
        child: Text(
          'This area is for JobsAndMore staff. Ask a super admin to give your account a staff role.',
          style: type.body.copyWith(color: jm.textMuted),
        ),
      );
    }
    final items =
        ref.watch(verificationQueueProvider).valueOrNull ??
        const <VerificationItem>[];

    Future<void> decide(VerificationItem it, String decision) async {
      final reason = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(
            '${decision == 'approved'
                ? 'Approve'
                : decision == 'rejected'
                ? 'Reject'
                : 'Ask for more information'} – ${it.orgName}',
          ),
          content: SizedBox(
            width: 420,
            child: DField(
              label: 'Reason (recorded in the audit log)',
              controller: reason,
              maxLines: 3,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      try {
        await decideVerification(it.id, decision, reason.text);
        ref.invalidate(verificationQueueProvider);
        if (context.mounted) {
          showJmToast(context, 'Decision recorded', tone: JmTone.success);
        }
      } on DataFailure catch (e) {
        if (context.mounted) {
          showJmToast(context, e.message, tone: JmTone.error);
        }
      }
    }

    return DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verification requests (${items.where((i) => i.status == 'pending').length} pending)',
            style: type.h4,
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              'No requests yet.',
              style: type.small.copyWith(color: jm.textMuted),
            ),
          for (final it in items)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: jm.border)),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it.orgName,
                        style: type.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Requested: ${verificationLabel(it.requested)} · ${fmtDay(it.submittedAt)} · ${it.evidenceCount} document(s)',
                        style: type.caption.copyWith(color: jm.textMuted),
                      ),
                    ],
                  ),
                  if (it.status == 'pending')
                    Wrap(
                      spacing: 8,
                      children: [
                        DBtn(
                          'Approve',
                          height: 36,
                          fontSize: 13,
                          onTap: () => decide(it, 'approved'),
                        ),
                        DBtn(
                          'Need info',
                          style: DBtnStyle.secondary,
                          height: 36,
                          fontSize: 13,
                          onTap: () => decide(it, 'needs_info'),
                        ),
                        DBtn(
                          'Reject',
                          style: DBtnStyle.danger,
                          height: 36,
                          fontSize: 13,
                          onTap: () => decide(it, 'rejected'),
                        ),
                      ],
                    )
                  else
                    DPill(it.status.replaceAll('_', ' ')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
