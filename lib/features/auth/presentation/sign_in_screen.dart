import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_feedback.dart';
import 'package:jobsandmore/features/auth/data/auth_repository.dart';
import 'package:jobsandmore/ui/chrome.dart';
import 'package:jobsandmore/ui/kit.dart';
import 'package:material_ui/material_ui.dart';

/// 02 Sign in – one route for every role.
class SignInScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _keep = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      if (!repo.isLive) {
        showJmToast(
          context,
          'Preview mode: no backend connected, showing the dashboard.',
        );
      }
      context.to(Routes.dashboard);
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted && !ref.read(authRepositoryProvider).isLive) {
        context.to(Routes.dashboard);
      }
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _forgot() async {
    final err = AuthValidators.email(_email.text);
    if (err != null) {
      setState(
        () => _error =
            'Enter your email above, then tap "Forgot password?" again.',
      );
      return;
    }
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordReset(_email.text.trim());
      if (mounted) {
        showJmToast(
          context,
          'If an account exists for ${_email.text.trim()}, a reset link is on its way.',
          tone: JmTone.success,
        );
      }
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final phone = DPage.isPhone(context);
    // Below 900px the aside stacks above the form inside a scroll view, so it
    // must not use Spacers.
    final stacked = MediaQuery.sizeOf(context).width < 900;

    final form = Form(
      key: _form,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text('Sign in', style: type.h1.copyWith(fontSize: 32)),
              ),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'New here? ',
                    style: type.body.copyWith(color: jm.textMuted),
                  ),
                  DLink(
                    'Create an account',
                    onTap: () => context.to(Routes.getStarted),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DBtn(
                'Continue with Google',
                style: DBtnStyle.secondary,
                icon: Icons.g_mobiledata_rounded,
                height: 50,
                expand: true,
                onTap: _google,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: jm.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or with email',
                      style: type.caption.copyWith(
                        color: jm.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: jm.border)),
                ],
              ),
              const SizedBox(height: 20),
              DField(
                label: 'Email address',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: AuthValidators.email,
              ),
              const SizedBox(height: 20),
              DField(
                label: 'Password',
                controller: _password,
                obscure: true,
                autofillHints: const [AutofillHints.password],
                validator: (v) => AuthValidators.required(v, 'password'),
                error: _error,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DCheck(
                      value: _keep,
                      onChanged: (v) => setState(() => _keep = v),
                      label: const Text('Keep me signed in'),
                    ),
                  ),
                  DLink('Forgot password?', onTap: _forgot),
                ],
              ),
              const SizedBox(height: 20),
              DBtn(
                _busy ? 'Signing in…' : 'Sign in',
                height: 50,
                expand: true,
                onTap: _busy ? null : _submit,
              ),
              const SizedBox(height: 16),
              Text(
                'Staff accounts require multi-factor authentication.',
                textAlign: TextAlign.center,
                style: type.caption.copyWith(color: jm.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );

    final aside = Container(
      decoration: BoxDecoration(
        color: DTint.forest,
        image: DecorationImage(
          image: const AssetImage('assets/images/hero_office.jpg'),
          fit: BoxFit.cover,
          alignment: const Alignment(0.4, 0),
          colorFilter: ColorFilter.mode(
            DTint.forest.withValues(alpha: 0.72),
            BlendMode.srcOver,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: phone ? 24 : 56,
        vertical: phone ? 32 : 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => context.to(Routes.home),
            child: const DLogo(onDark: true),
          ),
          if (!stacked) const Spacer(),
          SizedBox(height: stacked ? 24 : 0),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back.',
                  style: type.h1.copyWith(
                    color: Colors.white,
                    fontSize: phone ? 30 : 40,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'One sign-in for every role. If you are a job seeker and an employer, you can switch workspaces after signing in.',
                  style: type.bodyL.copyWith(
                    color: DTint.onDarkMuted,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          if (!stacked) ...[
            const Spacer(),
            Text(
              'Never pay anyone to get a job. Report suspicious requests to our support team.',
              style: type.small.copyWith(color: DTint.onDarkMuted),
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      backgroundColor: jm.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 900) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    aside,
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: form),
                    ),
                  ],
                ),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: aside),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(48),
                      child: form,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
