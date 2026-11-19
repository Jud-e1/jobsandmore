import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The four account purposes offered on "Get started".
enum AccountRole {
  seeker('Job Seeker', 'JS', 'job_seeker'),
  employer('Employer / Recruiter', 'EM', 'employer'),
  business('Business Owner', 'BO', 'business_owner'),
  provider('Training Provider', 'TP', 'training_provider');

  new(this.title, this.initials, this.dbValue);

  final String title;
  final String initials;

  /// Matches the `app_role` enum in the database.
  final String dbValue;
}

/// Answers collected across the onboarding steps. Kept in memory until the
/// account exists, then written to `profiles` (Phase 1 wiring).
class OnboardingDraft {
  const new({
    this.role = AccountRole.seeker,
    this.wantsAnotherRole = false,
    this.roles = const ['Operations Analyst', 'Data Analyst'],
    this.arrangements = const {'On-site', 'Hybrid'},
    this.experience = 'Graduate / under 1 year',
  });

  final AccountRole role;
  final bool wantsAnotherRole;
  final List<String> roles;
  final Set<String> arrangements;
  final String experience;

  OnboardingDraft copyWith({
    AccountRole? role,
    bool? wantsAnotherRole,
    List<String>? roles,
    Set<String>? arrangements,
    String? experience,
  }) => OnboardingDraft(
    role: role ?? this.role,
    wantsAnotherRole: wantsAnotherRole ?? this.wantsAnotherRole,
    roles: roles ?? this.roles,
    arrangements: arrangements ?? this.arrangements,
    experience: experience ?? this.experience,
  );
}

class OnboardingController extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void pickRole(AccountRole r) => state = state.copyWith(role: r);
  void toggleAnotherRole(bool v) => state = state.copyWith(wantsAnotherRole: v);
  void addTargetRole(String r) {
    final t = r.trim();
    if (t.isEmpty || state.roles.contains(t)) return;
    state = state.copyWith(roles: [...state.roles, t]);
  }

  void removeTargetRole(String r) =>
      state = state.copyWith(roles: [...state.roles]..remove(r));
  void toggleArrangement(String a) {
    final s = {...state.arrangements};
    s.contains(a) ? s.remove(a) : s.add(a);
    state = state.copyWith(arrangements: s);
  }

  void setExperience(String e) => state = state.copyWith(experience: e);
}

final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingDraft>(
      OnboardingController.new,
    );
