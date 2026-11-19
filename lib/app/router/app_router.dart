import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobsandmore/app/env.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/features/auth/data/auth_repository.dart';
import 'package:jobsandmore/features/auth/presentation/onboarding_screens.dart';
import 'package:jobsandmore/features/auth/presentation/sign_in_screen.dart';
import 'package:jobsandmore/features/billing/presentation/platform_screens.dart';
import 'package:jobsandmore/features/business/presentation/business_academy_screens.dart';
import 'package:jobsandmore/features/career_tools/presentation/career_tools_screens.dart';
import 'package:jobsandmore/features/dev/gallery_screen.dart';
import 'package:jobsandmore/features/employer/presentation/employer_screens.dart';
import 'package:jobsandmore/features/home/presentation/home_screen.dart';
import 'package:jobsandmore/features/jobs/presentation/jobs_screens.dart';
import 'package:jobsandmore/features/messaging/presentation/account_screens.dart';
import 'package:jobsandmore/features/profile/presentation/seeker_screens.dart';
import 'package:material_ui/material_ui.dart';

/// Pure guard logic, unit-tested in `test/app/router_guard_test.dart`.
///
/// [enforceAuth] is false in preview builds (no backend configured) so every
/// screen can be reviewed; with Supabase connected the guard is always on.
String? authRedirect({
  required Uri uri,
  required bool signedIn,
  required bool devToolsEnabled,
  bool enforceAuth = true,
}) {
  final path = uri.path;

  if (path.startsWith(Routes.devPrefix) && !devToolsEnabled) return Routes.home;

  final protected = Routes.protectedPrefixes.any(
    (p) => path == p || path.startsWith('$p/'),
  );
  if (protected && !signedIn && enforceAuth) {
    return Uri(
      path: Routes.signIn,
      queryParameters: {'from': uri.toString()},
    ).toString();
  }

  if (signedIn && path == Routes.signIn) {
    final from = uri.queryParameters['from'];
    // Only follow internal paths, never an absolute URL (open-redirect guard).
    if (from != null && from.startsWith('/') && !from.startsWith('//')) {
      return from;
    }
    return Routes.dashboard;
  }
  return null;
}

/// Bridges Riverpod auth changes to go_router's refreshListenable.
class _AuthRefresh extends ChangeNotifier {
  new(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
}

/// Fade + slight rise between pages (instant under reduce-motion).
Page<void> _page(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, _, child) {
        if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.015),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

GoRoute _r(String path, Widget Function(GoRouterState s) build) => GoRoute(
  path: path,
  pageBuilder: (context, state) => _page(state, build(state)),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      uri: state.uri,
      signedIn: ref.read(authStateProvider).valueOrNull != null,
      devToolsEnabled: Env.devToolsEnabled,
      enforceAuth: Env.hasSupabase,
    ),
    routes: [
      // Public
      _r(Routes.home, (_) => const HomeScreen()),
      _r(Routes.welcome, (_) => const WelcomeScreen()),
      _r(Routes.signIn, (_) => const SignInScreen()),
      _r(Routes.getStarted, (_) => const GetStartedScreen()),
      _r(Routes.register, (_) => const RegisterScreen()),
      _r(Routes.jobs, (_) => const JobsSearchScreen()),
      _r('/jobs/:id', (s) => JobDetailScreen(jobId: s.pathParameters['id']!)),
      _r('/jobs/:id/apply', (s) => ApplyScreen(jobId: s.pathParameters['id']!)),
      _r(Routes.tools, (_) => const CareerToolsScreen()),
      _r(Routes.business, (_) => const BusinessHubScreen()),
      _r(Routes.academy, (_) => const AcademyScreen()),
      _r(
        '/academy/:id',
        (s) => CourseDetailScreen(courseId: s.pathParameters['id']!),
      ),
      _r(Routes.pricing, (_) => const PricingScreen()),
      _r(
        '/employers/:slug',
        (s) => EmployerProfileScreen(slug: s.pathParameters['slug']!),
      ),

      // Job seeker
      _r(Routes.dashboard, (_) => const SeekerDashboardScreen()),
      _r(Routes.onboarding, (_) => const PersonaliseScreen()),
      _r(Routes.profile, (_) => const CareerProfileScreen()),
      _r(Routes.ats, (_) => const AtsAnalysisScreen()),
      _r(Routes.alerts, (_) => const JobAlertsScreen()),
      _r(Routes.inbox, (_) => const InboxScreen()),
      _r(
        Routes.notifications,
        (_) => const InboxScreen(notificationsOnly: true),
      ),
      _r(Routes.applications, (_) => const ApplicationsScreen()),
      _r(Routes.myCourses, (_) => const MyCoursesScreen()),
      _r(Routes.interview, (_) => const InterviewCoachScreen()),
      _r(Routes.settings, (_) => const SettingsScreen()),

      // Employer
      _r(Routes.employer, (_) => const EmployerDashboardScreen()),
      _r(Routes.postVacancy, (_) => const PostVacancyScreen()),
      _r(Routes.pipeline, (_) => const PipelineScreen()),

      // Business owner
      _r(Routes.businessDashboard, (_) => const BusinessDashboardScreen()),

      // Staff
      _r(Routes.admin, (_) => const AdminVerificationScreen()),

      // Dev
      _r(Routes.gallery, (_) => const GalleryScreen()),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});
