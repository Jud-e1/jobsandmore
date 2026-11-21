// Live versions of the job seeker's "My applications" list and career
// profile. Built from the same design kit as the sample screens; shown when
// the app is connected to the database.
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/data/live_data.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

/// Stage pill colours (live stage values).
(Color, Color) liveStageColors(BuildContext c, String stage) => switch (stage) {
  'interview' || 'assessment' => (DTint.blue(c), DTint.blueText(c)),
  'under_review' || 'new' => (c.jm.accentSoft, c.jm.onAccentSoft),
  'shortlisted' ||
  'offer' ||
  'hired' ||
  'reference_check' => (c.jm.primarySoft, c.jm.onPrimarySoft),
  _ => (c.jm.surfaceSunken, c.jm.textMuted),
};

const _flow = [
  'new',
  'under_review',
  'shortlisted',
  'interview',
  'offer',
  'hired',
];

class LiveApplicationsList extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LiveApplicationsList> createState() =>
      _LiveApplicationsListState();
}

class _LiveApplicationsListState extends ConsumerState<LiveApplicationsList> {
  int _tab = 0;

  Future<void> _withdraw(MyApplication a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: Text(
          'You will no longer be considered for ${a.job.title} at ${a.job.company}. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await withdrawApplication(a.id);
      ref.invalidate(myApplicationsProvider);
      if (mounted) showJmToast(context, 'Application withdrawn');
    } on DataFailure catch (e) {
      if (mounted) showJmToast(context, e.message, tone: JmTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final async = ref.watch(myApplicationsProvider);
    final all = async.valueOrNull ?? const <MyApplication>[];
    final active = all.where((a) => a.active).toList();
    final closed = all.where((a) => !a.active).toList();
    final shown = _tab == 0 ? active : closed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DTabs(
          tabs: ['Active (${active.length})', 'Closed (${closed.length})'],
          current: _tab,
          onTap: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 16),
        if (async.isLoading && all.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (shown.isEmpty)
          DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tab == 0 ? 'No active applications yet.' : 'Applications that were not progressed, withdrawn or filled appear here.',
                  style: type.body.copyWith(color: jm.textMuted),
                ),
                if (_tab == 0) ...[
                  const SizedBox(height: 12),
                  DBtn('Find jobs', onTap: () => context.to(Routes.jobs)),
                ],
              ],
            ),
          ),
        for (final a in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DCard(
              padding: const EdgeInsets.all(16),
              onTap: () => context.to(Routes.jobDetail(a.job.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      DInitials(a.job.ini, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.job.title,
                              style: type.label.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${a.job.company} · applied ${fmtDay(a.appliedAt)} · updated ${fmtAgo(a.updatedAt)}',
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
                          final (bg, fg) = liveStageColors(c, a.stage);
                          return DPill(stageLabel(a.stage), bg: bg, fg: fg);
                        },
                      ),
                    ],
                  ),
                  if (a.active) ...[
                    const SizedBox(height: 14),
                    _Timeline(stage: a.stage),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: DLink(
                        'Withdraw application',
                        onTap: () => _withdraw(a),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const new({required this.stage});
  final String stage;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final at = _flow.indexOf(stage).clamp(0, _flow.length - 1);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (i, s) in _flow.indexed) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                i < at
                    ? Icons.check_circle_rounded
                    : (i == at
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded),
                size: 18,
                color: i <= at ? jm.primary : jm.borderStrong,
              ),
              const SizedBox(width: 4),
              Text(
                stageLabel(s),
                style: type.caption.copyWith(
                  fontWeight: i == at ? FontWeight.w700 : FontWeight.w500,
                  color: i <= at ? jm.text : jm.textMuted,
                ),
              ),
            ],
          ),
          if (i < _flow.length - 1)
            Container(
              width: 14,
              height: 2,
              color: i < at ? jm.primary : jm.border,
            ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------- career profile ---

class LiveCareerProfile extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LiveCareerProfile> createState() => _LiveCareerProfileState();
}

class _LiveCareerProfileState extends ConsumerState<LiveCareerProfile> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _headline = TextEditingController();
  final _about = TextEditingController();
  final _skill = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  bool _uploading = false;
  bool _openToWork = true;

  @override
  void dispose() {
    for (final c in [_name, _phone, _city, _headline, _about, _skill]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(MyProfile p) {
    if (_loaded) return;
    _loaded = true;
    _name.text = p.fullName;
    _phone.text = p.phone ?? '';
    _city.text = p.city ?? '';
    _headline.text = p.headline ?? '';
    _about.text = p.about ?? '';
    _openToWork = p.openToWork;
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _saving = true);
    try {
      await action();
      ref.invalidate(myProfileProvider);
      ref.invalidate(seekerSignalsProvider);
      if (mounted) showJmToast(context, done, tone: JmTone.success);
    } on DataFailure catch (e) {
      if (mounted) showJmToast(context, e.message, tone: JmTone.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _upload() async {
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
      if (mounted) showJmToast(context, 'CV uploaded', tone: JmTone.success);
    } on DataFailure catch (e) {
      if (mounted) showJmToast(context, e.message, tone: JmTone.error);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _addExperience() async {
    final title = TextEditingController();
    final company = TextEditingController();
    final start = TextEditingController();
    final end = TextEditingController();
    var current = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: const Text('Add work experience'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DField(label: 'Job title', controller: title),
                const SizedBox(height: 12),
                DField(label: 'Company', controller: company),
                const SizedBox(height: 12),
                DField(
                  label: 'Start year',
                  controller: start,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DCheck(
                  value: current,
                  onChanged: (v) => set(() => current = v),
                  label: const Text('I work here now'),
                ),
                if (!current) ...[
                  const SizedBox(height: 12),
                  DField(
                    label: 'End year',
                    controller: end,
                    keyboardType: TextInputType.number,
                  ),
                ],
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
      ),
    );
    if (ok != true) return;
    final sy = int.tryParse(start.text.trim());
    if (title.text.trim().isEmpty ||
        company.text.trim().isEmpty ||
        sy == null) {
      if (mounted) {
        showJmToast(
          context,
          'Add a job title, company and start year.',
          tone: JmTone.warning,
        );
      }
      return;
    }
    await _run(
      () => addExperience(
        title: title.text,
        company: company.text,
        startYear: sy,
        endYear: int.tryParse(end.text.trim()),
        current: current,
      ),
      'Experience added',
    );
    ref.invalidate(myExperienceProvider);
  }

  Future<void> _addEducation() async {
    final school = TextEditingController();
    final qual = TextEditingController();
    final field = TextEditingController();
    final grade = TextEditingController();
    final year = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add education'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DField(label: 'School or institution', controller: school),
              const SizedBox(height: 12),
              DField(
                label: 'Qualification (e.g. B.Sc., HND, SSCE)',
                controller: qual,
              ),
              const SizedBox(height: 12),
              DField(
                label: 'Course of study',
                controller: field,
                optional: 'optional',
              ),
              const SizedBox(height: 12),
              DField(label: 'Grade', controller: grade, optional: 'optional'),
              const SizedBox(height: 12),
              DField(
                label: 'Year finished',
                controller: year,
                keyboardType: TextInputType.number,
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
    if (school.text.trim().isEmpty || qual.text.trim().isEmpty) {
      if (mounted) {
        showJmToast(
          context,
          'Add the institution and qualification.',
          tone: JmTone.warning,
        );
      }
      return;
    }
    await _run(
      () => addEducation(
        institution: school.text,
        qualification: qual.text,
        field: field.text.trim().isEmpty ? null : field.text.trim(),
        grade: grade.text.trim().isEmpty ? null : grade.text.trim(),
        endYear: int.tryParse(year.text.trim()),
      ),
      'Education added',
    );
    ref.invalidate(myEducationProvider);
  }

  Widget _entries(String table, List<ProfileEntry> items, String empty) {
    final jm = context.jm;
    final type = context.type;
    if (items.isEmpty) {
      return Text(empty, style: type.small.copyWith(color: jm.textMuted));
    }
    return Column(
      children: [
        for (final e in items)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
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
                        e.title,
                        style: type.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        [
                          e.subtitle,
                          e.period,
                        ].where((x) => x.trim().isNotEmpty).join(' · '),
                        style: type.caption.copyWith(
                          color: jm.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    await _run(
                      () => deleteProfileEntry(table, e.id),
                      'Removed',
                    );
                    ref
                      ..invalidate(myExperienceProvider)
                      ..invalidate(myEducationProvider);
                  },
                ),
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
    final async = ref.watch(myProfileProvider);
    final p = async.valueOrNull;
    if (p == null) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: async.isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign in to build your career profile.',
                      style: type.h4,
                    ),
                    const SizedBox(height: 12),
                    DBtn('Sign in', onTap: () => context.to(Routes.signIn)),
                  ],
                ),
        ),
      );
    }
    _fill(p);
    final cvs = ref.watch(myCvsProvider).valueOrNull ?? const <CvDoc>[];
    final exp =
        ref.watch(myExperienceProvider).valueOrNull ?? const <ProfileEntry>[];
    final edu =
        ref.watch(myEducationProvider).valueOrNull ?? const <ProfileEntry>[];

    final header = DCard(
      child: Wrap(
        spacing: 20,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DInitials(
            initialsOf(p.fullName.isEmpty ? p.email : p.fullName),
            size: 80,
            circle: true,
            bg: jm.accentSoft,
            fg: jm.onAccentSoft,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.fullName.isEmpty ? 'Your name' : p.fullName,
                  style: type.h2.copyWith(fontSize: 28),
                ),
                if ((p.headline ?? '').isNotEmpty)
                  Text(
                    p.headline!,
                    style: type.body.copyWith(color: jm.textMuted),
                  ),
                Text(
                  [
                    p.city,
                    p.state,
                  ].whereType<String>().where((e) => e.isNotEmpty).join(', '),
                  style: type.small.copyWith(color: jm.textMuted),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DRing(
                p.completion,
                size: 64,
                stroke: 6,
                label: 'Profile completion',
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 150,
                child: Text(
                  'Profile completion – not a measure of how employable you are.',
                  style: type.caption.copyWith(color: jm.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final basics = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('About you', style: type.h4),
          const SizedBox(height: 14),
          DGrid(
            minItemWidth: 240,
            gap: 12,
            maxColumns: 3,
            children: [
              DField(label: 'Full name', controller: _name),
              DField(
                label: 'Phone',
                controller: _phone,
                keyboardType: TextInputType.phone,
                optional: 'optional',
              ),
              DField(label: 'City', controller: _city, optional: 'optional'),
            ],
          ),
          const SizedBox(height: 12),
          DField(
            label: 'Headline',
            controller: _headline,
            hint: 'e.g. Operations analyst with 2 years in logistics',
          ),
          const SizedBox(height: 12),
          DField(
            label: 'Summary',
            controller: _about,
            maxLines: 5,
            optional: 'optional',
          ),
          const SizedBox(height: 12),
          DCheck(
            value: _openToWork,
            onChanged: (v) => setState(() => _openToWork = v),
            label: const Text(
              'Open to work – verified employers can find my profile',
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: DBtn(
              _saving ? 'Saving…' : 'Save changes',
              onTap: _saving
                  ? null
                  : () => _run(
                      () => saveProfile(
                        fullName: _name.text.trim(),
                        phone: _phone.text.trim().isEmpty
                            ? null
                            : _phone.text.trim(),
                        city: _city.text.trim(),
                        headline: _headline.text.trim(),
                        about: _about.text.trim(),
                        openToWork: _openToWork,
                      ),
                      'Profile saved',
                    ),
            ),
          ),
        ],
      ),
    );

    final skills = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Skills', style: type.h4),
          const SizedBox(height: 4),
          Text(
            'Skills power your match estimates and job recommendations.',
            style: type.small.copyWith(color: jm.textMuted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in p.skills) DTag(s),
              if (p.skills.isEmpty)
                Text(
                  'No skills yet.',
                  style: type.small.copyWith(color: jm.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DField(
                  label: 'Add a skill',
                  controller: _skill,
                  hint: 'e.g. Excel, SQL, Customer service',
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: DBtn(
                  'Add',
                  style: DBtnStyle.secondary,
                  onTap: () async {
                    final v = _skill.text.trim();
                    if (v.isEmpty) return;
                    await _run(() => addSkill(v), 'Skill added');
                    _skill.clear();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final cvCard = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('CVs', style: type.h4)),
              DBtn(
                _uploading ? 'Uploading…' : 'Upload CV',
                style: DBtnStyle.secondary,
                icon: Icons.upload_file_rounded,
                height: 40,
                fontSize: 14,
                onTap: _uploading ? null : _upload,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (cvs.isEmpty)
            Text(
              'Upload a PDF or Word CV (up to 10 MB). Employers only see a CV you send with an application.',
              style: type.small.copyWith(color: jm.textMuted),
            ),
          for (final cv in cvs)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: jm.border)),
              ),
              child: Row(
                children: [
                  Icon(Icons.description_outlined, color: jm.textMuted),
                  const SizedBox(width: 10),
                  Expanded(child: Text(cv.title, style: type.label)),
                  Text(
                    '${fmtDay(cv.updatedAt)}${cv.primary ? ' · Main' : ''}',
                    style: type.caption.copyWith(color: jm.textMuted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    final history = DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Work experience', style: type.h4)),
              DLink('+ Add', onTap: _addExperience),
            ],
          ),
          const SizedBox(height: 8),
          _entries(
            'experiences',
            exp,
            'No work experience added. NYSC, internships and volunteering count too.',
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: Text('Education', style: type.h4)),
              DLink('+ Add', onTap: _addEducation),
            ],
          ),
          const SizedBox(height: 8),
          _entries('educations', edu, 'No education added yet.'),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 20),
        DSplit(
          asideWidth: 380,
          gap: 20,
          breakpoint: 1000,
          main: Column(children: [basics, const SizedBox(height: 20), history]),
          aside: Column(children: [skills, const SizedBox(height: 20), cvCard]),
        ),
      ],
    );
  }
}
