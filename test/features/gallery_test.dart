import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/features/dev/gallery_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Renders the whole gallery (every component) at each target width in both
/// themes and fails on any overflow or build error.
void main() {
  setUpAll(() => JmFonts.useGoogleFonts = false);

  const widths = [375.0, 768.0, 1280.0, 1920.0];

  for (final dark in [false, true]) {
    for (final w in widths) {
      testWidgets(
        'gallery renders at ${w.round()}px ${dark ? 'dark' : 'light'}',
        (tester) async {
          tester.view
            ..physicalSize = Size(w, 900)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: dark
                    ? JmTheme.dark(compact: w < 600)
                    : JmTheme.light(compact: w < 600),
                // Reduce motion keeps the test deterministic (no looping orbs or
                // shimmer) and exercises the reduced-motion code paths.
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: true),
                  child: child!,
                ),
                home: const GalleryScreen(),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 2));

          // Scroll through every section so all of them build and lay out.
          final scrollable = find.byKey(const ValueKey('gallery-scroll'));
          for (var i = 0; i < 40; i++) {
            await tester.drag(scrollable, const Offset(0, -700));
            await tester.pump(const Duration(milliseconds: 50));
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
