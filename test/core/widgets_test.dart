import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

Widget wrap(Widget child, {bool dark = false}) => MaterialApp(
  theme: dark ? JmTheme.dark() : JmTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  setUpAll(() => JmFonts.useGoogleFonts = false);

  testWidgets('JmButton fires on tap and on keyboard Enter', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(JmButton(label: 'Apply', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Apply'));
    expect(taps, 1);

    // Tab to focus, then Enter activates.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 2);
  });

  testWidgets('disabled and loading buttons ignore taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const JmButton(label: 'Disabled', onPressed: null),
            JmButton(label: 'Busy', loading: true, onPressed: () => taps++),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Disabled'));
    await tester.tap(find.text('Busy'), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('verification badge shows only its precise label', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(JmBadge.verification(JmVerificationLevel.emailVerified)),
    );
    expect(find.text('Email verified'), findsOneWidget);
    expect(find.text('Verified employer'), findsNothing);
  });

  testWidgets('sponsored job card is labelled for sighted and SR users', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 360,
          child: JmJobCard(
            now: DateTime(2026, 11, 17),
            onTap: () {},
            job: JmJobCardData(
              id: 't1',
              title: 'Accountant',
              employerName: 'Test Co',
              verification: JmVerificationLevel.none,
              location: 'Abuja',
              jobType: 'Full-time',
              arrangement: 'On-site',
              postedAt: DateTime(2026, 10),
              isSponsored: true,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Sponsored'), findsOneWidget);
    expect(find.text('Salary not disclosed'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Accountant at Test Co.*sponsored')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('save heart toggles', (tester) async {
    var saved = false;
    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) => JmSaveButton(
            saved: saved,
            onChanged: (v) => setState(() => saved = v),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(JmSaveButton));
    await tester.pump();
    // flutter_animate starts the pop on a zero-length timer; let it fire,
    // then let the animation finish.
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(saved, isTrue);
  });

  testWidgets('score ring clamps and labels its value', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(const JmScoreRing(score: 140, label: 'ATS')));
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
    expect(find.bySemanticsLabel('ATS: 100 out of 100'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('components build in dark mode', (tester) async {
    await tester.pumpWidget(
      wrap(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            JmProgressMeter(value: 0.5, label: 'Profile'),
            JmEmptyState(title: 'Empty', message: 'Nothing here yet'),
          ],
        ),
        dark: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
