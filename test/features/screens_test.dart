import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsandmore/app/router/app_router.dart';
import 'package:jobsandmore/app/router/routes.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Opens every screen from the approved design at phone, tablet, laptop and desktop widths,
/// in light and dark mode, and fails on any overflow or build error.
void main() {
  setUpAll(() => JmFonts.useGoogleFonts = false);

  final routes = <String>[
    Routes.home,
    Routes.welcome,
    Routes.signIn,
    Routes.getStarted,
    Routes.register,
    Routes.onboarding,
    Routes.jobs,
    Routes.jobDetail('operations-analyst'),
    Routes.apply('operations-analyst'),
    Routes.dashboard,
    Routes.profile,
    Routes.tools,
    Routes.ats,
    Routes.alerts,
    Routes.inbox,
    Routes.notifications,
    Routes.applications,
    Routes.myCourses,
    Routes.interview,
    Routes.settings,
    Routes.employer,
    Routes.postVacancy,
    Routes.pipeline,
    Routes.employerProfile('kobo-logistics'),
    Routes.business,
    Routes.businessDashboard,
    Routes.academy,
    Routes.course('intro-sql'),
    Routes.pricing,
    Routes.admin,
    '/no-such-page',
  ];

  for (final (width, label) in [(390.0, 'phone'), (820.0, 'tablet'), (1024.0, 'laptop'), (1440.0, 'desktop')]) {
    for (final dark in [false, true]) {
      testWidgets('all screens render · $label · ${dark ? 'dark' : 'light'}', (tester) async {
        tester.view
          ..physicalSize = Size(width, 900)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final container = ProviderContainer();
        addTearDown(container.dispose);
        final router = container.read(appRouterProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              theme: dark ? JmTheme.dark(compact: width < 600) : JmTheme.light(compact: width < 600),
              // Reduce motion keeps the run deterministic.
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              ),
            ),
          ),
        );

        for (final r in routes) {
          router.go(r);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          final error = tester.takeException();
          expect(error, isNull, reason: 'Route $r at ${width.round()}px failed: $error');
        }
      });
    }
  }
}
