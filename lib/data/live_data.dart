// Live data layer: every screen reads and writes Supabase through these
// providers. When the app runs without a backend (local preview, widget
// tests) the providers fall back to the design's sample content so the UI
// still renders, and write actions explain that nothing was saved.
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/env.dart';
import 'package:jobsandmore/features/auth/data/auth_repository.dart';
import 'package:jobsandmore/features/demo/demo_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------- basics ---

SupabaseClient? get _db => Env.hasSupabase ? Supabase.instance.client : null;

/// The signed-in user's id, or null.
String? get currentUserId => _db?.auth.currentUser?.id;

/// A failure with a message that is safe to show to the user.
class DataFailure implements Exception {
  const new(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Thrown by write actions when the app has no backend connected.
const offline = DataFailure(
  'This preview is not connected to the live database, so nothing was saved.',
);

Future<T> _guard<T>(Future<T> Function(SupabaseClient db) run) async {
  final db = _db;
  if (db == null) throw offline;
  try {
    return await run(db);
  } on PostgrestException catch (e) {
    if (e.code == '23505') {
      throw const DataFailure('You have already done this.');
    }
    if (e.code == '42501' || e.message.contains('row-level security')) {
      throw const DataFailure('You do not have permission to do that.');
    }
    throw DataFailure(e.message);
  } on AuthException catch (e) {
    throw DataFailure(e.message);
  } on DataFailure {
    rethrow;
  } on Object {
    throw const DataFailure(
      'We could not reach JobsAndMore. Check your connection and try again.',
    );
  }
}

String _requireUser() {
  final id = currentUserId;
  if (id == null) throw const DataFailure('Please sign in first.');
  return id;
}

// ------------------------------------------------------------ formatting ---

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String fmtDay(DateTime? d) =>
    d == null ? '—' : '${d.day} ${_months[d.month - 1]}';

String fmtAgo(DateTime? d) {
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} h ago';
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 30) return '${diff.inDays} days ago';
  return fmtDay(d);
}

String _naira(num v) {
  if (v >= 1000000) {
    final m = v / 1000000;
    return '₦${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}m';
  }
  if (v >= 1000) return '₦${(v / 1000).round()}k';
  return '₦${v.round()}';
}

/// Price stored in kobo → "₦4,500" / "Free".
String fmtKobo(int kobo) {
  if (kobo <= 0) return 'Free';
  final n = (kobo / 100).round().toString();
  final b = StringBuffer();
  for (var i = 0; i < n.length; i++) {
    if (i > 0 && (n.length - i) % 3 == 0) b.write(',');
    b.write(n[i]);
  }
  return '₦$b';
}

String verificationLabel(String? level) => switch (level) {
  'verified' => 'Verified employer',
  'details_reviewed' => 'Business details reviewed',
  'email_verified' => 'Email verified',
  _ => 'Not yet verified',
};

String jobTypeLabel(String? t) => switch (t) {
  'full_time' => 'Full-time',
  'part_time' => 'Part-time',
  'contract' => 'Contract',
  'internship' => 'Internship',
  'nysc' => 'NYSC',
  'temporary' => 'Temporary',
  _ => 'Job',
};

String arrangementLabel(String? a) => switch (a) {
  'on_site' => 'On-site',
  'hybrid' => 'Hybrid',
  'remote' => 'Remote',
  _ => '',
};

String stageLabel(String s) => switch (s) {
  'new' => 'Applied',
  'under_review' => 'Under review',
  'shortlisted' => 'Shortlisted',
  'assessment' => 'Assessment',
  'interview' => 'Interview',
  'reference_check' => 'Reference check',
  'offer' => 'Offer',
  'hired' => 'Hired',
  'rejected' => 'Not progressed',
  'withdrawn' => 'Withdrawn',
  _ => s,
};

String initialsOf(String name) {
  final parts = name
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty && RegExp('[A-Za-z]').hasMatch(p[0]))
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

DateTime? _date(Object? v) => v == null ? null : DateTime.tryParse('$v');
List<String> _strings(Object? v) =>
    v is List ? v.map((e) => '$e').toList() : const [];

// ------------------------------------------------------------------ jobs ---

DemoJob jobFromRow(Map<String, dynamic> r, {int match = 0}) {
  final min = r['salary_min'] as num?;
  final max = r['salary_max'] as num?;
  final period = '${r['salary_period'] ?? 'month'}';
  final disclosed =
      r['salary_disclosed'] == true && (min != null || max != null);
  final salary = !disclosed
      ? 'Salary not disclosed'
      : '${[if (min != null) _naira(min), if (max != null) _naira(max)].join('–')} / $period';
  final arr = arrangementLabel(r['arrangement'] as String?);
  final place = [
    r['city'],
    r['state_name'],
  ].whereType<String>().where((s) => s.isNotEmpty).toSet().join(', ');
  final orgName = '${r['org_name'] ?? 'Employer'}';
  return DemoJob(
    id: '${r['id']}',
    ini: initialsOf(orgName),
    title: '${r['title']}',
    company: orgName,
    location: r['arrangement'] == 'remote'
        ? 'Remote'
        : (place.isEmpty ? 'Nigeria' : place),
    type: [
      jobTypeLabel(r['job_type'] as String?),
      if (arr.isNotEmpty) arr,
    ].join(' · '),
    verification: verificationLabel(r['org_verification'] as String?),
    salary: salary,
    posted: fmtAgo(_date(r['published_at'])),
    closes: fmtDay(_date(r['closing_date'])),
    match: match,
    why: '',
    sponsored: r['is_sponsored'] == true,
    listing: jobTypeLabel(r['job_type'] as String?),
    orgId: '${r['org_id']}',
    orgSlug: r['org_slug'] as String?,
    summary: r['summary'] as String?,
    about: r['description'] as String?,
    responsibilities: _strings(r['responsibilities']),
    requirements: _strings(r['requirements']),
    benefits: _strings(r['benefits']),
    skills: _strings(r['skills']),
    screening: (r['screening_questions'] is List)
        ? (r['screening_questions'] as List)
              .whereType<Map<dynamic, dynamic>>()
              .map(Map<String, dynamic>.from)
              .toList()
        : const [],
    closingDate: _date(r['closing_date']),
    externalUrl: r['external_url'] as String?,
    stateCode: r['state'] as String?,
    publishedAt: _date(r['published_at']),
  );
}

/// What the matcher knows about the signed-in seeker.
class SeekerSignals {
  const new({
    this.skills = const {},
    this.states = const {},
    this.roles = const [],
  });
  final Set<String> skills;
  final Set<String> states;
  final List<String> roles;
  bool get isEmpty => skills.isEmpty && states.isEmpty && roles.isEmpty;
}

final seekerSignalsProvider = FutureProvider<SeekerSignals>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  final uid = currentUserId;
  if (db == null || uid == null) return const SeekerSignals();
  try {
    final cp = await db
        .from('candidate_profiles')
        .select('desired_states, desired_roles')
        .eq('user_id', uid)
        .maybeSingle();
    final sk = await db.from('skills').select('name').eq('user_id', uid);
    return SeekerSignals(
      skills: {for (final s in sk) '${s['name']}'.toLowerCase()},
      states: {..._strings(cp?['desired_states'])},
      roles: _strings(cp?['desired_roles'])
          .map((e) => e.toLowerCase())
          .toList(),
    );
  } on Object {
    return const SeekerSignals();
  }
});

/// Transparent match estimate (0 when we know too little to say).
/// Skills overlap counts most, then location, then desired role in title.
int matchScore(Map<String, dynamic> r, SeekerSignals s) {
  if (s.isEmpty) return 0;
  final jobSkills = _strings(r['skills']).map((e) => e.toLowerCase()).toSet();
  var score = 0.0;
  var weight = 0.0;
  if (jobSkills.isNotEmpty && s.skills.isNotEmpty) {
    score += 60 * jobSkills.intersection(s.skills).length / jobSkills.length;
    weight += 60;
  }
  if (s.states.isNotEmpty) {
    final remote = r['arrangement'] == 'remote';
    score += (remote || s.states.contains(r['state'])) ? 25 : 0;
    weight += 25;
  }
  if (s.roles.isNotEmpty) {
    final t = '${r['title']}'.toLowerCase();
    score += s.roles.any((role) => t.contains(role) || role.contains(t))
        ? 15
        : 0;
    weight += 15;
  }
  if (weight == 0) return 0;
  return math.max(1, (100 * score / weight).round());
}

/// All open jobs, newest first (sponsored ones keep their label).
final jobListingsProvider = FutureProvider<List<DemoJob>>((ref) async {
  final db = _db;
  if (db == null) return Demo.jobs;
  final signals = await ref.watch(seekerSignalsProvider.future);
  final rows = await db
      .from('job_cards')
      .select()
      .eq('status', 'published')
      .order('published_at', ascending: false)
      .limit(300);
  return [for (final r in rows) jobFromRow(r, match: matchScore(r, signals))];
});

/// One job by id (uuid) or, for sample content, by slug.
final FutureProviderFamily<DemoJob?, String> jobProvider =
    FutureProvider.family<DemoJob?, String>((ref, id) async {
      final db = _db;
      if (db == null) {
        return Demo.jobs.where((j) => j.id == id).firstOrNull ??
            Demo.jobs.first;
      }
      final list = await ref.watch(jobListingsProvider.future);
      final hit = list.where((j) => j.id == id).firstOrNull;
      if (hit != null) return hit;
      final isUuid = RegExp(r'^[0-9a-f-]{36}$').hasMatch(id);
      final row = await db
          .from('job_cards')
          .select()
          .eq(isUuid ? 'id' : 'slug', id)
          .limit(1)
          .maybeSingle();
      return row == null ? null : jobFromRow(row);
    });

/// Saved jobs for the signed-in user (local only without a backend).
class SavedJobs extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    ref.watch(authStateProvider);
    unawaited(_load());
    return {};
  }

  Future<void> _load() async {
    final db = _db;
    final uid = currentUserId;
    if (db == null || uid == null) return;
    try {
      final rows = await db
          .from('saved_jobs')
          .select('job_id')
          .eq('user_id', uid);
      state = {for (final r in rows) '${r['job_id']}'};
    } on Object {
      // Keep the empty set; saving still works.
    }
  }

  /// Returns true when the job is now saved.
  Future<bool> toggle(String jobId) async {
    final added = !state.contains(jobId);
    state = added ? {...state, jobId} : ({...state}..remove(jobId));
    final db = _db;
    if (db == null) return added;
    final uid = currentUserId;
    if (uid == null) {
      state = added ? ({...state}..remove(jobId)) : {...state, jobId};
      throw const DataFailure('Sign in to save jobs.');
    }
    try {
      if (added) {
        await db.from('saved_jobs').upsert({'user_id': uid, 'job_id': jobId});
      } else {
        await db
            .from('saved_jobs')
            .delete()
            .eq('user_id', uid)
            .eq('job_id', jobId);
      }
    } on Object {
      state = added ? ({...state}..remove(jobId)) : {...state, jobId};
      throw const DataFailure('Could not update saved jobs. Try again.');
    }
    return added;
  }
}

final savedJobsProvider = NotifierProvider<SavedJobs, Set<String>>(
  SavedJobs.new,
);

/// Submits an application. Returns the new application id.
Future<String> applyToJob({
  required String jobId,
  String? coverLetter,
  Map<String, String> answers = const {},
  String source = 'search',
  String? cvId,
}) => _guard((db) async {
  final uid = _requireUser();
  final row = await db
      .from('applications')
      .insert({
        'job_id': jobId,
        'candidate_id': uid,
        'cv_document_id': ?cvId,
        if (coverLetter != null && coverLetter.trim().isNotEmpty)
          'cover_letter': coverLetter.trim(),
        'answers': answers,
        'source': source,
      })
      .select('id')
      .single();
  return '${row['id']}';
});

// ---------------------------------------------------------- applications ---

class MyApplication {
  const new({
    required this.id,
    required this.job,
    required this.stage,
    required this.appliedAt,
    required this.updatedAt,
  });
  final String id;
  final DemoJob job;
  final String stage;
  final DateTime appliedAt;
  final DateTime updatedAt;
  bool get active => !{'hired', 'rejected', 'withdrawn'}.contains(stage);
}

final myApplicationsProvider = FutureProvider<List<MyApplication>>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  final uid = currentUserId;
  if (db == null || uid == null) return const [];
  final apps = await db
      .from('applications')
      .select('id, job_id, stage, created_at, updated_at, withdrawn_at')
      .eq('candidate_id', uid)
      .order('updated_at', ascending: false);
  if (apps.isEmpty) return const [];
  final ids = {for (final a in apps) '${a['job_id']}'}.toList();
  final jobs = await db.from('job_cards').select().inFilter('id', ids);
  final byId = {for (final j in jobs) '${j['id']}': jobFromRow(j)};
  return [
    for (final a in apps)
      if (byId['${a['job_id']}'] != null)
        MyApplication(
          id: '${a['id']}',
          job: byId['${a['job_id']}']!,
          stage: a['withdrawn_at'] != null ? 'withdrawn' : '${a['stage']}',
          appliedAt: _date(a['created_at']) ?? DateTime.now(),
          updatedAt: _date(a['updated_at']) ?? DateTime.now(),
        ),
  ];
});

Future<void> withdrawApplication(String id) => _guard((db) async {
  await db
      .from('applications')
      .update({
        'withdrawn_at': DateTime.now().toUtc().toIso8601String(),
        'stage': 'withdrawn',
      })
      .eq('id', id);
});

// --------------------------------------------------------------- profile ---

class MyProfile {
  const new({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.state,
    this.city,
    this.headline,
    this.about,
    this.roles = const [],
    this.consents = const {},
    this.completion = 0,
    this.openToWork = true,
    this.skills = const [],
    this.referralCode,
    this.points = 0,
  });
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? state;
  final String? city;
  final String? headline;
  final String? about;
  final List<String> roles;
  final Map<String, dynamic> consents;
  final int completion;
  final bool openToWork;
  final List<String> skills;
  final String? referralCode;
  final int points;

  String get firstName =>
      fullName.trim().isEmpty ? 'there' : fullName.trim().split(' ').first;
}

final myProfileProvider = FutureProvider<MyProfile?>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  final user = db?.auth.currentUser;
  if (db == null || user == null) return null;
  final p = await db.from('profiles').select().eq('id', user.id).maybeSingle();
  final cp = await db
      .from('candidate_profiles')
      .select()
      .eq('user_id', user.id)
      .maybeSingle();
  final sk = await db.from('skills').select('name').eq('user_id', user.id);
  final skills = [for (final s in sk) '${s['name']}'];
  var points = 0;
  try {
    final pts = await db
        .from('reward_ledger')
        .select('points')
        .eq('user_id', user.id);
    points = pts.fold<int>(
      0,
      (t, r) => t + ((r['points'] as num?)?.toInt() ?? 0),
    );
  } on Object {
    points = 0;
  }
  final fields = [
    p?['full_name'],
    p?['phone'],
    p?['state'],
    cp?['headline'],
    cp?['about'],
    if (skills.isNotEmpty) 'skills',
  ];
  final completion =
      (100 * fields.where((f) => f != null && '$f'.isNotEmpty).length / 6)
          .round();
  return MyProfile(
    id: user.id,
    email: user.email ?? '',
    fullName: '${p?['full_name'] ?? ''}',
    phone: p?['phone'] as String?,
    state: p?['state'] as String?,
    city: p?['city'] as String?,
    headline: cp?['headline'] as String?,
    about: cp?['about'] as String?,
    roles: _strings(p?['roles']),
    consents: Map<String, dynamic>.from((p?['consents'] as Map?) ?? const {}),
    completion: completion,
    openToWork: cp?['open_to_work'] != false,
    skills: skills,
    referralCode: p?['referral_code'] as String?,
    points: points,
  );
});

class ProfileEntry {
  const new({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.period,
  });
  final String id;
  final String title;
  final String subtitle;
  final String period;
}

String _year(Object? d) => d == null ? '' : '$d'.substring(0, 4);

final myExperienceProvider = FutureProvider<List<ProfileEntry>>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  final uid = currentUserId;
  if (db == null || uid == null) return const [];
  final rows = await db
      .from('experiences')
      .select()
      .eq('user_id', uid)
      .order('start_date', ascending: false);
  return [
    for (final r in rows)
      ProfileEntry(
        id: '${r['id']}',
        title: '${r['title']}',
        subtitle: '${r['company']}',
        period:
            '${_year(r['start_date'])} – ${r['is_current'] == true ? 'present' : _year(r['end_date'])}',
      ),
  ];
});

final myEducationProvider = FutureProvider<List<ProfileEntry>>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  final uid = currentUserId;
  if (db == null || uid == null) return const [];
  final rows = await db
      .from('educations')
      .select()
      .eq('user_id', uid)
      .order('end_date', ascending: false, nullsFirst: true);
  return [
    for (final r in rows)
      ProfileEntry(
        id: '${r['id']}',
        title:
            '${r['qualification']}${r['field_of_study'] == null ? '' : ', ${r['field_of_study']}'}',
        subtitle:
            '${r['institution']}${r['grade'] == null ? '' : ' · ${r['grade']}'}',
        period: [
          _year(r['start_date']),
          _year(r['end_date']),
        ].where((e) => e.isNotEmpty).join(' – '),
      ),
  ];
});

Future<void> addExperience({
  required String title,
  required String company,
  required int startYear,
  int? endYear,
  bool current = false,
  String? description,
}) => _guard((db) async {
  final uid = _requireUser();
  await db.from('experiences').insert({
    'user_id': uid,
    'title': title.trim(),
    'company': company.trim(),
    'start_date': '$startYear-01-01',
    if (!current && endYear != null) 'end_date': '$endYear-12-31',
    'is_current': current,
    'description': ?description,
  });
});

Future<void> addEducation({
  required String institution,
  required String qualification,
  String? field,
  String? grade,
  int? endYear,
}) => _guard((db) async {
  final uid = _requireUser();
  await db.from('educations').insert({
    'user_id': uid,
    'institution': institution.trim(),
    'qualification': qualification.trim(),
    'field_of_study': ?field,
    'grade': ?grade,
    if (endYear != null) 'end_date': '$endYear-07-01',
  });
});

Future<void> deleteProfileEntry(String table, String id) => _guard((db) async {
  await db.from(table).delete().eq('id', id);
});

Future<void> saveProfile({
  String? fullName,
  String? phone,
  String? city,
  String? headline,
  String? about,
  bool? openToWork,
}) => _guard((db) async {
  final uid = _requireUser();
  final p = <String, dynamic>{
    'full_name': ?fullName,
    'phone': ?phone,
    'city': ?city,
  };
  if (p.isNotEmpty) await db.from('profiles').update(p).eq('id', uid);
  final c = <String, dynamic>{
    'headline': ?headline,
    'about': ?about,
    'open_to_work': ?openToWork,
  };
  if (c.isNotEmpty) {
    await db.from('candidate_profiles').upsert({'user_id': uid, ...c});
  }
});

Future<void> addSkill(String name) => _guard((db) async {
  final uid = _requireUser();
  await db.from('skills').insert({'user_id': uid, 'name': name.trim()});
});

Future<void> setConsent(String key, bool granted) => _guard((db) async {
  await db.rpc<dynamic>(
    'set_consent',
    params: {'p_key': key, 'p_granted': granted},
  );
});

// -------------------------------------------------------------- academy ---

DemoCourse courseFromRow(
  Map<String, dynamic> r, {
  double? progress,
  int i = 0,
}) {
  final level = '${r['level'] ?? ''}'.replaceAll('_', ' ');
  final dur = r['duration_label'] as String?;
  return DemoCourse(
    id: '${r['slug']}',
    uuid: '${r['id']}',
    title: '${r['title']}',
    meta: [
      if (level.isNotEmpty) level[0].toUpperCase() + level.substring(1),
      ?dur,
      if (r['has_certificate'] == true) 'Certificate',
    ].join(' · '),
    price: fmtKobo((r['price_kobo'] as num?)?.toInt() ?? 0),
    tint: i % 4,
    provider: '${(r['provider'] as Map?)?['name'] ?? 'JobsAndMore Academy'}',
    progress: progress,
    summary: r['summary'] as String?,
    description: r['description'] as String?,
    outcomes: _strings(r['outcomes']),
    hasCertificate: r['has_certificate'] == true,
    priceKobo: (r['price_kobo'] as num?)?.toInt() ?? 0,
    topic: r['topic'] as String?,
    level: r['level'] as String?,
  );
}

const _courseCols =
    'id, slug, title, summary, description, topic, level, format, duration_label, '
    'price_kobo, has_certificate, outcomes, provider:organisations!courses_provider_org_id_fkey(name)';

final coursesProvider = FutureProvider<List<DemoCourse>>((ref) async {
  final db = _db;
  if (db == null) return Demo.courses;
  final rows = await db
      .from('courses')
      .select(_courseCols)
      .eq('status', 'published')
      .order('published_at', ascending: false);
  return [for (final (i, r) in rows.indexed) courseFromRow(r, i: i)];
});

final FutureProviderFamily<DemoCourse?, String> courseProvider =
    FutureProvider.family<DemoCourse?, String>((ref, slug) async {
      final db = _db;
      if (db == null) return Demo.course(slug);
      final row = await db
          .from('courses')
          .select(_courseCols)
          .eq('slug', slug)
          .maybeSingle();
      return row == null ? null : courseFromRow(row);
    });

/// The signed-in user's enrolments, as courses with progress (0–1).
final myCoursesProvider = FutureProvider<List<DemoCourse>>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  final uid = currentUserId;
  if (db == null) return Demo.courses;
  if (uid == null) return const [];
  final rows = await db
      .from('enrolments')
      .select('progress, course:courses($_courseCols)')
      .eq('user_id', uid)
      .neq('status', 'cancelled')
      .order('enrolled_at', ascending: false);
  return [
    for (final (i, r) in rows.indexed)
      if (r['course'] is Map)
        courseFromRow(
          Map<String, dynamic>.from(r['course'] as Map),
          progress: ((r['progress'] as num?) ?? 0) / 100,
          i: i,
        ),
  ];
});

Future<void> enrolInCourse(String courseUuid) => _guard((db) async {
  final uid = _requireUser();
  await db.from('enrolments').upsert({
    'course_id': courseUuid,
    'user_id': uid,
    'status': 'active',
  }, onConflict: 'course_id,user_id');
});

// ------------------------------------------------------------ employers ---

class MyOrg {
  const new({
    required this.id,
    required this.name,
    required this.type,
    required this.role,
    this.verification,
    this.slug,
  });
  final String id;
  final String name;
  final String type;
  final String role;
  final String? verification;
  final String? slug;
}

final myOrgsProvider = FutureProvider<List<MyOrg>>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  if (db == null || currentUserId == null) return const [];
  final rows = await db.rpc<List<dynamic>>('my_organisations');
  final maps = rows.whereType<Map<dynamic, dynamic>>().toList();
  final slugs = <String, String>{};
  if (maps.isNotEmpty) {
    final s = await db.from('organisations').select('id, slug').inFilter('id', [
      for (final r in maps) '${r['org_id']}',
    ]);
    for (final r in s) {
      slugs['${r['id']}'] = '${r['slug']}';
    }
  }
  return [
    for (final r in maps)
      MyOrg(
        id: '${r['org_id']}',
        name: '${r['name']}',
        type: '${r['type']}',
        role: '${r['role'] ?? 'viewer'}',
        verification: r['verification_level'] as String?,
        slug: slugs['${r['org_id']}'],
      ),
  ];
});

/// The employer workspace in use (first employer organisation).
final myEmployerOrgProvider = FutureProvider<MyOrg?>((ref) async {
  final orgs = await ref.watch(myOrgsProvider.future);
  return orgs.where((o) => o.type == 'employer').firstOrNull ??
      orgs.firstOrNull;
});

Future<MyOrg> createMyOrganisation({
  required String type,
  required String name,
  String? industry,
  String? state,
  String? size,
  String? website,
}) => _guard((db) async {
  _requireUser();
  final r = await db.rpc<Map<String, dynamic>>(
    'create_my_organisation',
    params: {
      'p_type': type,
      'p_name': name,
      'p_industry': industry,
      'p_state': state,
      'p_size': size,
      'p_website': website,
    },
  );
  return MyOrg(
    id: '${r['id']}',
    name: '${r['name']}',
    type: type,
    role: 'owner',
  );
});

final employerOverviewProvider = FutureProvider<Map<String, int>>((ref) async {
  final org = await ref.watch(myEmployerOrgProvider.future);
  final db = _db;
  if (db == null || org == null) return const {};
  final r = await db.rpc<Map<String, dynamic>>(
    'employer_overview',
    params: {'p_org': org.id},
  );
  return {for (final e in r.entries) e.key: (e.value as num).toInt()};
});

class OrgJob {
  const new({
    required this.id,
    required this.title,
    required this.status,
    required this.views,
    required this.applicants,
    required this.newApplicants,
    this.closingDate,
  });
  final String id;
  final String title;
  final String status;
  final int views;
  final int applicants;
  final int newApplicants;
  final DateTime? closingDate;
}

final orgJobsProvider = FutureProvider<List<OrgJob>>((ref) async {
  final org = await ref.watch(myEmployerOrgProvider.future);
  final db = _db;
  if (db == null || org == null) return const [];
  final jobs = await db
      .from('jobs')
      .select('id, title, status, views_count, closing_date')
      .eq('org_id', org.id)
      .isFilter('deleted_at', null)
      .order('created_at', ascending: false);
  final apps = await db.from('applications').select('job_id, stage').inFilter(
    'job_id',
    [for (final j in jobs) '${j['id']}'],
  );
  return [
    for (final j in jobs)
      OrgJob(
        id: '${j['id']}',
        title: '${j['title']}',
        status: '${j['status']}',
        views: (j['views_count'] as num?)?.toInt() ?? 0,
        applicants: apps.where((a) => a['job_id'] == j['id']).length,
        newApplicants: apps
            .where((a) => a['job_id'] == j['id'] && a['stage'] == 'new')
            .length,
        closingDate: _date(j['closing_date']),
      ),
  ];
});

String _slugify(String s) {
  final base = s
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final tail = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  return '${base.isEmpty ? 'job' : base.substring(0, math.min(base.length, 60))}-$tail';
}

/// Creates a vacancy for the employer's organisation. `publish` puts it live.
Future<String> postVacancy({
  required String title,
  required String description,
  required String jobType,
  required String arrangement,
  required String experienceLevel,
  String? summary,
  String? state,
  String? city,
  int? salaryMin,
  int? salaryMax,
  bool salaryDisclosed = false,
  DateTime? closingDate,
  List<String> responsibilities = const [],
  List<String> requirements = const [],
  List<String> benefits = const [],
  List<String> skills = const [],
  List<Map<String, dynamic>> screening = const [],
  bool publish = true,
}) => _guard((db) async {
  final uid = _requireUser();
  final orgs = await db.rpc<List<dynamic>>('my_organisations');
  final org = orgs.whereType<Map<dynamic, dynamic>>().firstOrNull;
  if (org == null) {
    throw const DataFailure(
      'Create your company profile before posting a job.',
    );
  }
  final row = await db
      .from('jobs')
      .insert({
        'org_id': org['org_id'],
        'created_by': uid,
        'title': title.trim(),
        'slug': _slugify(title),
        'summary': ?summary,
        'description': description.trim(),
        'job_type': jobType,
        'arrangement': arrangement,
        'experience_level': experienceLevel,
        'state': ?state,
        'city': ?city,
        'salary_min': ?salaryMin,
        'salary_max': ?salaryMax,
        'salary_disclosed':
            salaryDisclosed && (salaryMin != null || salaryMax != null),
        if (closingDate != null)
          'closing_date': closingDate.toIso8601String().substring(0, 10),
        'responsibilities': responsibilities,
        'requirements': requirements,
        'benefits': benefits,
        'skills': skills,
        'screening_questions': screening,
        'status': publish ? 'published' : 'draft',
        if (publish) 'published_at': DateTime.now().toUtc().toIso8601String(),
      })
      .select('id')
      .single();
  return '${row['id']}';
});

class PipelineCard {
  const new({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.name,
    required this.stage,
    required this.appliedAt,
    this.headline,
  });
  final String id;
  final String jobId;
  final String jobTitle;
  final String name;
  final String stage;
  final DateTime appliedAt;
  final String? headline;
}

final pipelineProvider = FutureProvider<List<PipelineCard>>((ref) async {
  final org = await ref.watch(myEmployerOrgProvider.future);
  final db = _db;
  if (db == null || org == null) return const [];
  final rows = await db
      .from('pipeline_cards')
      .select()
      .eq('org_id', org.id)
      .order('created_at', ascending: false);
  return [
    for (final r in rows)
      PipelineCard(
        id: '${r['id']}',
        jobId: '${r['job_id']}',
        jobTitle: '${r['job_title']}',
        name: '${r['candidate_name']}',
        stage: '${r['stage']}',
        appliedAt: _date(r['created_at']) ?? DateTime.now(),
        headline: r['candidate_headline'] as String?,
      ),
  ];
});

Future<void> setJobStatus(String jobId, String status) => _guard((db) async {
  await db
      .from('jobs')
      .update({
        'status': status,
        if (status == 'published')
          'published_at': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', jobId);
});

/// Public employer page: organisation by slug with its open jobs.
class PublicOrg {
  const new({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.culture,
    this.industry,
    this.size,
    this.website,
    this.state,
    this.verification,
    this.jobs = const [],
  });
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? culture;
  final String? industry;
  final String? size;
  final String? website;
  final String? state;
  final String? verification;
  final List<DemoJob> jobs;
}

final FutureProviderFamily<PublicOrg?, String> publicOrgProvider =
    FutureProvider.family<PublicOrg?, String>((ref, slug) async {
      final db = _db;
      if (db == null) return null;
      final o = await db
          .from('organisations')
          .select()
          .eq('slug', slug)
          .maybeSingle();
      if (o == null) return null;
      final jobs = await db
          .from('job_cards')
          .select()
          .eq('org_id', '${o['id']}')
          .eq('status', 'published')
          .order('published_at', ascending: false);
      return PublicOrg(
        id: '${o['id']}',
        name: '${o['name']}',
        slug: '${o['slug']}',
        description: o['description'] as String?,
        culture: o['culture'] as String?,
        industry: o['industry'] as String?,
        size: o['size'] as String?,
        website: o['website'] as String?,
        state: o['state'] as String?,
        verification: o['verification_level'] as String?,
        jobs: [for (final j in jobs) jobFromRow(j)],
      );
    });

Future<void> updateOrganisation(String id, Map<String, dynamic> fields) =>
    _guard((db) async {
      await db.from('organisations').update(fields).eq('id', id);
    });

/// Asks JobsAndMore staff to verify the organisation.
Future<void> requestVerification(String orgId, String level) =>
    _guard((db) async {
      final uid = _requireUser();
      await db.from('verification_requests').insert({
        'org_id': orgId,
        'submitted_by': uid,
        'requested_level': level,
      });
    });

Future<void> moveApplication(String applicationId, String stage) =>
    _guard((db) async {
      await db
          .from('applications')
          .update({'stage': stage})
          .eq('id', applicationId);
    });

// ------------------------------------------------------------ job alerts ---

class JobAlert {
  const new({
    required this.id,
    required this.name,
    required this.keywords,
    required this.states,
    required this.frequency,
    required this.paused,
    required this.channels,
  });
  final String id;
  final String name;
  final List<String> keywords;
  final List<String> states;
  final String frequency;
  final bool paused;
  final List<String> channels;
}

final jobAlertsProvider = FutureProvider<List<JobAlert>>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  final uid = currentUserId;
  if (db == null || uid == null) return const [];
  final rows = await db
      .from('job_alerts')
      .select()
      .eq('user_id', uid)
      .order('created_at', ascending: false);
  return [
    for (final r in rows)
      JobAlert(
        id: '${r['id']}',
        name: '${r['name']}',
        keywords: _strings(r['keywords']),
        states: _strings(r['states']),
        frequency: '${r['frequency']}',
        paused: r['paused'] == true,
        channels: _strings(r['channels']),
      ),
  ];
});

Future<void> createJobAlert({
  required String name,
  List<String> keywords = const [],
  List<String> states = const [],
  bool nearby = false,
  String frequency = 'daily',
  List<String> channels = const ['email', 'in_app'],
}) => _guard((db) async {
  final uid = _requireUser();
  await db.from('job_alerts').insert({
    'user_id': uid,
    'name': name,
    'keywords': keywords,
    'states': states,
    'include_nearby_states': nearby,
    'frequency': frequency,
    'channels': channels,
  });
});

Future<void> setAlertPaused(String id, bool paused) => _guard((db) async {
  await db.from('job_alerts').update({'paused': paused}).eq('id', id);
});

Future<void> deleteJobAlert(String id) => _guard((db) async {
  await db.from('job_alerts').delete().eq('id', id);
});

// ---------------------------------------------------------- notifications ---

class AppNotification {
  const new({
    required this.id,
    required this.category,
    required this.title,
    required this.at,
    this.body,
    this.link,
    this.read = false,
  });
  final String id;
  final String category;
  final String title;
  final String? body;
  final String? link;
  final DateTime at;
  final bool read;
}

final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  ref.watch(authStateProvider);
  final db = _db;
  final uid = currentUserId;
  if (db == null || uid == null) return const [];
  final rows = await db
      .from('notifications')
      .select()
      .eq('user_id', uid)
      .order('created_at', ascending: false)
      .limit(100);
  return [
    for (final r in rows)
      AppNotification(
        id: '${r['id']}',
        category: '${r['category']}',
        title: '${r['title']}',
        body: r['body'] as String?,
        link: r['link'] as String?,
        at: _date(r['created_at']) ?? DateTime.now(),
        read: r['read_at'] != null,
      ),
  ];
});

Future<void> markAllNotificationsRead() => _guard((db) async {
  final uid = _requireUser();
  await db
      .from('notifications')
      .update({'read_at': DateTime.now().toUtc().toIso8601String()})
      .eq('user_id', uid)
      .isFilter('read_at', null);
});

// --------------------------------------------------------------- messages ---

class Conversation {
  const new({
    required this.id,
    required this.subject,
    required this.kind,
    this.lastAt,
    this.preview,
  });
  final String id;
  final String subject;
  final String kind;
  final DateTime? lastAt;
  final String? preview;
}

class ChatMessage {
  const new({
    required this.id,
    required this.body,
    required this.mine,
    required this.at,
  });
  final String id;
  final String body;
  final bool mine;
  final DateTime at;
}

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  final uid = currentUserId;
  if (db == null || uid == null) return const [];
  final rows = await db
      .from('conversations')
      .select(
        'id, subject, kind, last_message_at, conversation_participants!inner(user_id)',
      )
      .eq('conversation_participants.user_id', uid)
      .order('last_message_at', ascending: false, nullsFirst: false);
  final out = <Conversation>[];
  for (final r in rows) {
    final last = await db
        .from('messages')
        .select('body')
        .eq('conversation_id', '${r['id']}')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    out.add(
      Conversation(
        id: '${r['id']}',
        subject: '${r['subject'] ?? 'Conversation'}',
        kind: '${r['kind']}',
        lastAt: _date(r['last_message_at']),
        preview: last?['body'] as String?,
      ),
    );
  }
  return out;
});

final FutureProviderFamily<List<ChatMessage>, String> messagesProvider =
    FutureProvider.family<List<ChatMessage>, String>((ref, conv) async {
      final db = _db;
      final uid = currentUserId;
      if (db == null || uid == null) return const [];
      final rows = await db
          .from('messages')
          .select('id, body, sender_id, created_at')
          .eq('conversation_id', conv)
          .isFilter('deleted_at', null)
          .order('created_at');
      return [
        for (final r in rows)
          ChatMessage(
            id: '${r['id']}',
            body: '${r['body']}',
            mine: r['sender_id'] == uid,
            at: _date(r['created_at']) ?? DateTime.now(),
          ),
      ];
    });

Future<void> sendMessage(String conversationId, String body) =>
    _guard((db) async {
      final uid = _requireUser();
      await db.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': uid,
        'body': body.trim(),
      });
    });

// ------------------------------------------------------- business hub -----

Future<void> sendEnquiry({
  required String orgId,
  required String subject,
  required String message,
  String? serviceId,
}) => _guard((db) async {
  final uid = _requireUser();
  await db.from('enquiries').insert({
    'org_id': orgId,
    'sender_id': uid,
    'subject': subject,
    'message': message,
    'service_id': ?serviceId,
  });
});

class ServiceListing {
  const new({
    required this.id,
    required this.orgId,
    required this.title,
    required this.category,
    required this.orgName,
    this.priceFrom,
  });
  final String id;
  final String orgId;
  final String title;
  final String category;
  final String orgName;
  final int? priceFrom;
}

final servicesProvider = FutureProvider<List<ServiceListing>>((ref) async {
  final db = _db;
  if (db == null) return const [];
  final rows = await db
      .from('services')
      .select(
        'id, org_id, title, category, price_from_kobo, org:organisations(name)',
      )
      .eq('status', 'published')
      .limit(100);
  return [
    for (final r in rows)
      ServiceListing(
        id: '${r['id']}',
        orgId: '${r['org_id']}',
        title: '${r['title']}',
        category: '${r['category']}',
        orgName: '${(r['org'] as Map?)?['name'] ?? ''}',
        priceFrom: (r['price_from_kobo'] as num?)?.toInt(),
      ),
  ];
});

// ---------------------------------------------------------------- plans ---

class PricePlan {
  const new({
    required this.code,
    required this.name,
    required this.audience,
    required this.priceKobo,
    required this.interval,
    required this.features,
    this.description,
    this.highlighted = false,
  });
  final String code;
  final String name;
  final String audience;
  final int priceKobo;
  final String interval;
  final List<String> features;
  final String? description;
  final bool highlighted;
}

final plansProvider = FutureProvider<List<PricePlan>>((ref) async {
  final db = _db;
  if (db == null) return const [];
  final rows = await db
      .from('plans')
      .select()
      .eq('is_active', true)
      .order('sort_order');
  return [
    for (final r in rows)
      PricePlan(
        code: '${r['code']}',
        name: '${r['name']}',
        audience: '${r['audience']}',
        priceKobo: (r['price_kobo'] as num?)?.toInt() ?? 0,
        interval: '${r['interval']}',
        features: _strings(r['features']),
        description: r['description'] as String?,
        highlighted: r['is_highlighted'] == true,
      ),
  ];
});

// ------------------------------------------------------------ admin -------

class VerificationItem {
  const new({
    required this.id,
    required this.orgId,
    required this.orgName,
    required this.requested,
    required this.status,
    required this.submittedAt,
    this.evidenceCount = 0,
    this.notes,
  });
  final String id;
  final String orgId;
  final String orgName;
  final String requested;
  final String status;
  final DateTime submittedAt;
  final int evidenceCount;
  final String? notes;
}

final verificationQueueProvider = FutureProvider<List<VerificationItem>>((
  ref,
) async {
  ref.watch(authStateProvider);
  final db = _db;
  if (db == null || currentUserId == null) return const [];
  final rows = await db
      .from('verification_requests')
      .select(
        'id, org_id, requested_level, status, created_at, evidence, reviewer_notes, org:organisations(name)',
      )
      .order('created_at');
  return [
    for (final r in rows)
      VerificationItem(
        id: '${r['id']}',
        orgId: '${r['org_id']}',
        orgName: '${(r['org'] as Map?)?['name'] ?? ''}',
        requested: '${r['requested_level']}',
        status: '${r['status']}',
        submittedAt: _date(r['created_at']) ?? DateTime.now(),
        evidenceCount: (r['evidence'] is List)
            ? (r['evidence'] as List).length
            : 0,
        notes: r['reviewer_notes'] as String?,
      ),
  ];
});

/// Staff decision on a verification request ('approved', 'rejected',
/// 'needs_info'). A reason is required and the decision is audit-logged by
/// the database.
Future<void> decideVerification(String id, String decision, String reason) =>
    _guard((db) async {
      final uid = _requireUser();
      if (reason.trim().length < 5) {
        throw const DataFailure('Add a short reason for this decision.');
      }
      await db
          .from('verification_requests')
          .update({
            'status': decision,
            'reviewer_id': uid,
            'reviewer_notes': reason.trim(),
            'decided_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);
    });

/// Whether the signed-in user holds any staff role.
final isStaffProvider = FutureProvider<bool>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  if (db == null || currentUserId == null) return false;
  try {
    final r = await db.rpc<dynamic>('is_staff');
    return r == true;
  } on Object {
    return false;
  }
});

// ------------------------------------------------------------------- CVs ---

class CvDoc {
  const new({
    required this.id,
    required this.title,
    required this.updatedAt,
    this.primary = false,
    this.sizeBytes,
  });
  final String id;
  final String title;
  final DateTime updatedAt;
  final bool primary;
  final int? sizeBytes;
}

final myCvsProvider = FutureProvider<List<CvDoc>>((ref) async {
  ref.watch(authStateProvider);
  final db = _db;
  final uid = currentUserId;
  if (db == null || uid == null) return const [];
  final rows = await db
      .from('cv_documents')
      .select('id, title, updated_at, is_primary, size_bytes')
      .eq('user_id', uid)
      .order('is_primary', ascending: false)
      .order('updated_at', ascending: false);
  return [
    for (final r in rows)
      CvDoc(
        id: '${r['id']}',
        title: '${r['title']}',
        updatedAt: _date(r['updated_at']) ?? DateTime.now(),
        primary: r['is_primary'] == true,
        sizeBytes: (r['size_bytes'] as num?)?.toInt(),
      ),
  ];
});

/// Uploads a PDF or DOCX CV to the private `cvs` bucket and records it.
Future<CvDoc> uploadCv(List<int> bytes, String fileName) => _guard((db) async {
  final uid = _requireUser();
  final lower = fileName.toLowerCase();
  final mime = lower.endsWith('.pdf')
      ? 'application/pdf'
      : lower.endsWith('.docx')
      ? 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      : null;
  if (mime == null) {
    throw const DataFailure('Upload a PDF or Word (.docx) file.');
  }
  if (bytes.length > 10 * 1024 * 1024) {
    throw const DataFailure(
      'That file is over 10 MB. Please upload a smaller CV.',
    );
  }
  final safe = fileName.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
  final path = '$uid/${DateTime.now().millisecondsSinceEpoch}_$safe';
  await db.storage
      .from('cvs')
      .uploadBinary(
        path,
        Uint8List.fromList(bytes),
        fileOptions: FileOptions(contentType: mime),
      );
  final existing = await db
      .from('cv_documents')
      .select('id')
      .eq('user_id', uid)
      .limit(1);
  final row = await db
      .from('cv_documents')
      .insert({
        'user_id': uid,
        'title': fileName,
        'source': 'upload',
        'storage_path': path,
        'mime_type': mime,
        'size_bytes': bytes.length,
        'is_primary': existing.isEmpty,
      })
      .select('id, title, updated_at, is_primary, size_bytes')
      .single();
  return CvDoc(
    id: '${row['id']}',
    title: '${row['title']}',
    updatedAt: _date(row['updated_at']) ?? DateTime.now(),
    primary: row['is_primary'] == true,
    sizeBytes: bytes.length,
  );
});

/// Module titles for a course, in order.
final FutureProviderFamily<List<String>, String> courseModulesProvider =
    FutureProvider.family<List<String>, String>((ref, courseUuid) async {
      final db = _db;
      if (db == null) return const [];
      final rows = await db
          .from('course_modules')
          .select('title')
          .eq('course_id', courseUuid)
          .order('position');
      return [for (final r in rows) '${r['title']}'];
    });

/// Whether the signed-in user is enrolled in a course.
final FutureProviderFamily<bool, String> isEnrolledProvider =
    FutureProvider.family<bool, String>((ref, courseUuid) async {
      ref.watch(authStateProvider);
      final db = _db;
      final uid = currentUserId;
      if (db == null || uid == null) return false;
      final r = await db
          .from('enrolments')
          .select('id')
          .eq('course_id', courseUuid)
          .eq('user_id', uid)
          .neq('status', 'cancelled')
          .maybeSingle();
      return r != null;
    });
