import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/core/widgets/jm_pressable.dart';
import 'package:jobsandmore/features/auth/application/onboarding_controller.dart';
import 'package:jobsandmore/features/auth/data/auth_repository.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

const _steps = [
  'Choose account',
  'Create account',
  'Personalise',
  'Complete profile',
  'Activate',
];

/// Phone header for onboarding: back button, progress bar, "2/5".
class _MobileStepHeader extends StatelessWidget {
  const new({required this.step, required this.onBack});

  final int step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Material(
            color: jm.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: jm.border),
            ),
            child: IconButton(
              tooltip: 'Back',
              onPressed: onBack,
              icon: Icon(Icons.chevron_left_rounded, color: jm.text),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: DBar((step + 1) / 5, height: 6)),
          const SizedBox(width: 12),
          Text(
            '${step + 1}/5',
            style: context.type.caption.copyWith(
              color: jm.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// M01 Welcome (phones). On wide screens this route shows the home page.
class WelcomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    Widget card(Widget child, {double angle = 0, double left = 0}) => Padding(
      padding: EdgeInsets.only(left: left),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.jm.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: child,
        ),
      ),
    );
    return Scaffold(
      backgroundColor: DTint.forest,
      body: _WelcomeBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight - 64),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: DLogo(onDark: true),
                        ),
                        const SizedBox(height: 40),
                        card(
                          angle: -0.035,
                          Row(
                            children: [
                              DInitials(
                                'KL',
                                size: 40,
                                bg: context.jm.accentSoft,
                                fg: context.jm.onAccentSoft,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Operations Analyst',
                                      style: type.label.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Lagos · ✓ Verified employer',
                                      style: type.caption.copyWith(
                                        color: context.jm.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const DPill('82%'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        card(
                          angle: 0.035,
                          left: 28,
                          Row(
                            children: [
                              const DRing(74, size: 40, stroke: 4),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CV check (estimate)',
                                      style: type.label.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      '3 quick fixes found',
                                      style: type.caption.copyWith(
                                        color: context.jm.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Your next job, skills and business support – in your pocket.',
                          style: type.h1.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Verified employers. AI tools you control. Free to start.',
                          style: type.body.copyWith(color: DTint.onDarkMuted),
                        ),
                        const SizedBox(height: 28),
                        DBtn(
                          'Get started',
                          style: DBtnStyle.amber,
                          height: 54,
                          fontSize: 16,
                          expand: true,
                          onTap: () => context.to(Routes.getStarted),
                        ),
                        const SizedBox(height: 10),
                        DBtn(
                          'I already have an account',
                          style: DBtnStyle.outlineLight,
                          expand: true,
                          onTap: () => context.to(Routes.signIn),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 03 Get started – choose account type (M02 on phones).
class GetStartedScreen extends ConsumerWidget {
  const new({super.key});

  static const Map<AccountRole, (String, String)> _desc = {
    AccountRole.seeker: (
      'Find jobs, internships and scholarships, improve your CV and track applications.',
      'First step: upload or build your CV',
    ),
    AccountRole.employer: (
      'Verify your organisation, post vacancies and manage applicants with your team.',
      'First step: verify and post a vacancy',
    ),
    AccountRole.business: (
      'Get consultancy and services, find opportunities and build business visibility.',
      'First step: take the needs assessment',
    ),
    AccountRole.provider: (
      'Publish courses, manage learners and issue verifiable certificates.',
      'First step: submit your first course',
    ),
  };

  Color _tint(BuildContext c, AccountRole r) => switch (r) {
    AccountRole.seeker => c.jm.primarySoft,
    AccountRole.employer => c.jm.accentSoft,
    AccountRole.business => DTint.blue(c),
    AccountRole.provider => DTint.purple(c),
  };

  static String _photo(AccountRole r) => switch (r) {
    AccountRole.seeker => DImages.graduate,
    AccountRole.employer => DImages.handshake,
    AccountRole.business => DImages.tailor,
    AccountRole.provider => DImages.classroom,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jm = context.jm;
    final type = context.type;
    final draft = ref.watch(onboardingProvider);
    final ctl = ref.read(onboardingProvider.notifier);
    final phone = DPage.isPhone(context);

    Widget roleCard(AccountRole r) {
      final on = r == draft.role;
      final (desc, first) = _desc[r]!;
      return JmPressable(
        onTap: () => ctl.pickRole(r),
        selected: on,
        semanticLabel: '${r.title}. $desc',
        scaleOnPress: false,
        focusRadius: BorderRadius.circular(22),
        builder: (context, s) => AnimatedContainer(
          duration: JmMotion.micro,
          padding: EdgeInsets.all(phone ? 12 : 0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: jm.surface,
            borderRadius: BorderRadius.circular(phone ? 18 : 22),
            border: Border.all(
              color: on
                  ? jm.primary
                  : (s.hovered ? jm.borderStrong : jm.border),
              width: on ? 2 : 1,
            ),
            boxShadow: on && !phone
                ? [BoxShadow(color: jm.primarySoft, spreadRadius: 4)]
                : null,
          ),
          child: phone
              ? Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        _photo(r),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                        errorBuilder: (_, _, _) => DInitials(
                          r.initials,
                          size: 56,
                          bg: _tint(context, r),
                          fg: jm.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: type.label.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            desc,
                            style: type.small.copyWith(
                              color: jm.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      on
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: on ? jm.primary : jm.borderStrong,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          _photo(r),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, -0.4),
                          excludeFromSemantics: true,
                          errorBuilder: (_, _, _) =>
                              Container(height: 150, color: _tint(context, r)),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: AnimatedOpacity(
                            opacity: on ? 1 : 0,
                            duration: JmMotion.micro,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: jm.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: jm.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: type.h4.copyWith(fontSize: 20)),
                          const SizedBox(height: 12),
                          Text(
                            desc,
                            style: type.small.copyWith(
                              color: jm.textMuted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            first,
                            style: type.caption.copyWith(
                              color: jm.onPrimarySoft,
                              fontWeight: FontWeight.w600,
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
    }

    final cont = DBtn(
      'Continue as ${draft.role.title}',
      height: phone ? 54 : 50,
      expand: phone,
      onTap: () => context.to(Routes.register),
    );

    if (phone) {
      return Scaffold(
        backgroundColor: jm.background,
        body: SafeArea(
          child: Column(
            children: [
              _MobileStepHeader(
                step: 0,
                onBack: () => context.to(Routes.welcome),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    Text(
                      'What brings you here?',
                      style: type.h1.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'You can add another role later.',
                      style: type.body.copyWith(color: jm.textMuted),
                    ),
                    const SizedBox(height: 20),
                    for (final r in AccountRole.values) ...[
                      roleCard(r),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: cont,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: jm.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              DSlimHeader(
                trailing: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: type.small.copyWith(color: jm.textMuted),
                    ),
                    DLink('Sign in', onTap: () => context.to(Routes.signIn)),
                  ],
                ),
              ),
              DContainer(
                maxWidth: 1100,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DStepBar(steps: _steps, current: 0),
                    const SizedBox(height: 32),
                    Text(
                      'What brings you to JobsAndMore?',
                      textAlign: TextAlign.center,
                      style: type.h1,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          'Pick the option that fits best. You can add another role later from the same account.',
                          textAlign: TextAlign.center,
                          style: type.bodyL.copyWith(
                            color: jm.textMuted,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Semantics(
                      label: 'Account type',
                      child: DGrid(
                        minItemWidth: 240,
                        children: [
                          for (final r in AccountRole.values) roleCard(r),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    DCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: DCheck(
                              value: draft.wantsAnotherRole,
                              onChanged: ctl.toggleAnotherRole,
                              label: const Text(
                                'I also need another role (e.g. I own a business and hire staff)',
                              ),
                            ),
                          ),
                          Text(
                            'Multi-role accounts are reviewed before the second role is activated.',
                            style: type.caption.copyWith(
                              color: jm.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DBtn(
                          'Back',
                          style: DBtnStyle.ghost,
                          onTap: () => context.to(Routes.home),
                        ),
                        const SizedBox(width: 12),
                        Flexible(child: cont),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 04 Create account (M03 on phones). Essentials only, inline validation,
/// password rules shown up front and separate, optional consent ticks.
class RegisterScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _city = TextEditingController();
  String _state = 'Lagos';
  String _status = 'Graduate seeking first role';
  bool _terms = false;
  bool _tips = false;
  bool _whatsapp = false;
  bool _busy = false;
  bool _termsError = false;
  String? _error;

  static const _states = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Abuja (FCT)',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
    'Outside Nigeria',
  ];
  static const _statuses = [
    'Student',
    'Graduate seeking first role',
    'Employed, open to offers',
    'Unemployed, actively looking',
    'Career change',
  ];

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone, _password, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = _form.currentState?.validate() ?? false;
    setState(() => _termsError = !_terms);
    if (!ok || !_terms) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final role = ref.read(onboardingProvider).role;
    final repo = ref.read(authRepositoryProvider);
    try {
      final res = await repo.signUp(
        email: _email.text.trim(),
        password: _password.text,
        metadata: {
          'full_name': '${_first.text.trim()} ${_last.text.trim()}'.trim(),
          'role': role.dbValue,
          'state': _state,
          'city': _city.text.trim(),
          'career_status': _status,
          'consents': {
            'terms': true,
            'marketing_email': _tips,
            'whatsapp': _whatsapp,
          },
        },
      );
      if (!mounted) return;
      if (res == SignUpResult.needsEmailConfirmation) {
        showJmToast(
          context,
          'Check ${_email.text.trim()} for a verification link (valid 24 hours).',
          tone: JmTone.success,
        );
      } else if (!repo.isLive) {
        showJmToast(context, 'Preview mode: no backend connected.');
      }
      context.to(Routes.onboarding);
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _rules() {
    final r = AuthValidators.passwordRules(_password.text);
    final jm = context.jm;
    Widget item(bool ok, String t, {bool optional = false}) => Text(
      '${ok ? '✓' : '○'} $t',
      style: context.type.caption.copyWith(
        fontSize: 13,
        color: ok ? jm.onPrimarySoft : jm.textMuted,
        fontWeight: ok ? FontWeight.w600 : FontWeight.w500,
      ),
    );
    return Wrap(
      spacing: 18,
      runSpacing: 6,
      children: [
        item(r.length, '8+ characters'),
        item(r.number, 'A number'),
        item(r.mixedCase, 'Upper & lower case'),
        item(r.symbol, 'A symbol (recommended)', optional: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final phone = DPage.isPhone(context);
    final role = ref.watch(onboardingProvider).role;

    final fields = <Widget>[
      if (phone) ...[
        DBtn(
          'Continue with Google',
          style: DBtnStyle.secondary,
          icon: Icons.g_mobiledata_rounded,
          expand: true,
          height: 50,
          onTap: () async {
            await ref.read(authRepositoryProvider).signInWithGoogle();
          },
        ),
        Row(
          children: [
            Expanded(child: Divider(color: jm.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'or',
                style: type.caption.copyWith(color: jm.textMuted),
              ),
            ),
            Expanded(child: Divider(color: jm.border)),
          ],
        ),
      ],
      DGrid(
        minItemWidth: 220,
        children: [
          DField(
            label: 'First name',
            controller: _first,
            autofillHints: const [AutofillHints.givenName],
            validator: (v) => AuthValidators.required(v, 'first name'),
          ),
          DField(
            label: 'Last name',
            controller: _last,
            autofillHints: const [AutofillHints.familyName],
            validator: (v) => AuthValidators.required(v, 'last name'),
          ),
        ],
      ),
      DField(
        label: 'Email address',
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        validator: AuthValidators.email,
        helper: "We'll send a verification link here.",
        error: _error,
      ),
      DField(
        label: 'Phone number',
        optional: '(optional verification by SMS)',
        controller: _phone,
        hint: '803 000 0000',
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumberNational],
        prefix: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: jm.borderStrong),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('+234', style: type.body),
        ),
      ),
      DField(
        label: 'Password',
        controller: _password,
        obscure: true,
        autofillHints: const [AutofillHints.newPassword],
        validator: AuthValidators.newPassword,
      ),
      _rules(),
      DGrid(
        minItemWidth: 220,
        children: [
          DSelect<String>(
            label: 'State of residence',
            value: _state,
            items: _states,
            onChanged: (v) => setState(() => _state = v),
          ),
          DField(
            label: 'City / area',
            optional: '(optional)',
            controller: _city,
          ),
        ],
      ),
      if (role == AccountRole.seeker)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current career status', style: type.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in _statuses)
                  DChoicePill(
                    label: s,
                    selected: s == _status,
                    onTap: () => setState(() => _status = s),
                  ),
              ],
            ),
          ],
        ),
      Container(
        padding: const EdgeInsets.only(top: 18),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: jm.border)),
        ),
        child: Column(
          children: [
            DCheck(
              value: _terms,
              onChanged: (v) => setState(() {
                _terms = v;
                _termsError = false;
              }),
              label: Text.rich(
                TextSpan(
                  text: 'I agree to the Terms of Use and have read the Privacy Notice. ',
                  children: [
                    TextSpan(
                      text: 'Required',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: jm.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_termsError)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 34, bottom: 4),
                  child: Text(
                    'Please accept the Terms to create an account.',
                    style: type.small.copyWith(color: jm.error, fontSize: 13),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            DCheck(
              value: _tips,
              onChanged: (v) => setState(() => _tips = v),
              label: const Text(
                'Send me career tips and product news by email. Optional',
              ),
            ),
            const SizedBox(height: 10),
            DCheck(
              value: _whatsapp,
              onChanged: (v) => setState(() => _whatsapp = v),
              label: const Text(
                'Send job alerts on WhatsApp. Optional – you can opt out any time',
              ),
            ),
          ],
        ),
      ),
    ];

    final submit = DBtn(
      _busy
          ? 'Creating account…'
          : (phone ? 'Create account' : 'Create account & verify email'),
      height: 52,
      expand: true,
      onTap: _busy ? null : _submit,
    );

    final form = Form(
      key: _form,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!phone) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => context.to(Routes.getStarted),
                  child: DPill('${role.title} account · change'),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              'Create your account',
              style: type.h1.copyWith(fontSize: phone ? 26 : 30),
            ),
            if (!phone) ...[
              const SizedBox(height: 6),
              Text(
                'Only the essentials now. You can add the rest later.',
                style: type.body.copyWith(color: jm.textMuted),
              ),
            ],
            const SizedBox(height: 22),
            for (final f in fields) ...[f, const SizedBox(height: 18)],
            if (!phone) submit,
          ],
        ),
      ),
    );

    if (phone) {
      return Scaffold(
        backgroundColor: jm.surface,
        body: SafeArea(
          child: Column(
            children: [
              _MobileStepHeader(
                step: 1,
                onBack: () => context.to(Routes.getStarted),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: form,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: jm.border)),
                ),
                child: submit,
              ),
            ],
          ),
        ),
      );
    }

    final aside = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why we ask', style: type.h4),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'State',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: jm.text,
                      ),
                    ),
                    const TextSpan(
                      text: ' sets your default job alerts – you can change it or add other states anytime.',
                    ),
                  ],
                ),
                style: type.small.copyWith(color: jm.textMuted, height: 1.6),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Career status',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: jm.text,
                      ),
                    ),
                    const TextSpan(
                      text: ' tailors your dashboard. It is never shown to employers unless you choose to.',
                    ),
                  ],
                ),
                style: type.small.copyWith(color: jm.textMuted, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DCard(
          color: jm.accentSoft,
          borderColor: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What happens next', style: type.h4),
              const SizedBox(height: 8),
              for (final (i, t) in [
                'Verify your email (link valid 24 hrs)',
                'Answer 3 quick questions',
                'Upload or build your CV',
              ].indexed)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${i + 1}. $t',
                    style: type.small.copyWith(color: jm.text, height: 1.6),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: jm.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              DSlimHeader(
                trailing: Text(
                  'Step 2 of 5 · Create account',
                  style: type.small.copyWith(color: jm.textMuted),
                ),
              ),
              DContainer(
                maxWidth: 1100,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 64),
                child: DSplit(
                  asideWidth: 300,
                  gap: 32,
                  main: DCard(padding: const EdgeInsets.all(36), child: form),
                  aside: aside,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 05 Personalise & activate.
class PersonaliseScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<PersonaliseScreen> createState() => _PersonaliseScreenState();
}

class _PersonaliseScreenState extends ConsumerState<PersonaliseScreen> {
  final _role = TextEditingController();

  @override
  void dispose() {
    _role.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final draft = ref.watch(onboardingProvider);
    final ctl = ref.read(onboardingProvider.notifier);
    final phone = DPage.isPhone(context);

    final form = DCard(
      padding: EdgeInsets.all(phone ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '1. What roles are you looking for?',
            style: type.h4.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: jm.borderStrong),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final r in draft.roles)
                  Container(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    decoration: BoxDecoration(
                      color: jm.primarySoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            r,
                            overflow: TextOverflow.ellipsis,
                            style: type.label.copyWith(color: jm.onPrimarySoft),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove $r',
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: jm.onPrimarySoft,
                          ),
                          onPressed: () => ctl.removeTargetRole(r),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: _role,
                    decoration: const InputDecoration(
                      hintText: 'Add a role…',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                    ),
                    onSubmitted: (v) {
                      ctl.addTargetRole(v);
                      _role.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                'Suggestions:',
                style: type.caption.copyWith(color: jm.textMuted, fontSize: 13),
              ),
              for (final s in [
                'Business Analyst',
                'Supply Chain Officer',
                'Graduate Trainee',
              ])
                DLink(s, onTap: () => ctl.addTargetRole(s)),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            '2. How do you want to work?',
            style: type.h4.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in [
                'On-site',
                'Hybrid',
                'Remote',
                'Internship',
                'Contract',
              ])
                DChoicePill(
                  label: a,
                  multi: true,
                  selected: draft.arrangements.contains(a),
                  onTap: () => ctl.toggleArrangement(a),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            '3. Your experience level',
            style: type.h4.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 360,
              child: DSelect<String>(
                label: 'Experience level',
                showLabel: false,
                value: draft.experience,
                items: const [
                  'Graduate / under 1 year',
                  '1–3 years',
                  '3–7 years',
                  '7+ years',
                ],
                onChanged: ctl.setExperience,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              DLink('Skip for now', onTap: () => context.to(Routes.dashboard)),
              DBtn(
                'Save and continue',
                onTap: () => showJmToast(
                  context,
                  'Preferences saved. Your dashboard is ready.',
                  tone: JmTone.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final activate = Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DTint.forest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DEyebrow('Step 5 · Activate', color: JmBrand.amber),
          const SizedBox(height: 16),
          Text(
            'Your best first step',
            style: type.h3.copyWith(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 16),
          Text(
            'Profiles with a CV get matched to far more vacancies. Add yours now – it takes about 2 minutes.',
            style: type.body.copyWith(color: DTint.onDarkMuted, fontSize: 15),
          ),
          const SizedBox(height: 16),
          DBtn(
            'Upload my CV',
            style: DBtnStyle.amber,
            expand: true,
            onTap: () => context.to(Routes.profile),
          ),
          const SizedBox(height: 12),
          DBtn(
            'Build a CV with AI',
            style: DBtnStyle.white,
            expand: true,
            onTap: () => context.to(Routes.tools),
          ),
          const SizedBox(height: 12),
          Center(
            child: DLink(
              'Go to my dashboard',
              color: Colors.white,
              onTap: () => context.to(Routes.dashboard),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: jm.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              DSlimHeader(
                trailing: Text(
                  'Step 3 of 5 · Personalise',
                  style: type.small.copyWith(color: jm.textMuted),
                ),
              ),
              DContainer(
                maxWidth: 1100,
                padding: EdgeInsets.fromLTRB(
                  phone ? 16 : 24,
                  32,
                  phone ? 16 : 24,
                  64,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DNotice(
                      border: jm.isDark ? null : const Color(0xFFB7D8C5),
                      icon: Icons.check_circle_outline_rounded,
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Email verified. ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: "Welcome! Three quick questions and we'll set up your dashboard.",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DSplit(asideWidth: 340, main: form, aside: activate),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-bleed photo that fades into the brand green (Canva-generated image).
class _WelcomeBackdrop extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        'assets/images/graduate_portrait.jpg',
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.7),
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x330A4F34), Color(0xB30A4F34), Color(0xFF0A4F34)],
            stops: [0, 0.45, 0.75],
          ),
        ),
      ),
      child,
    ],
  );
}
