import 'package:flutter_test/flutter_test.dart';
import 'package:jobsandmore/app/router/app_router.dart';

void main() {
  String? go(String path, {bool signedIn = false, bool dev = true}) =>
      authRedirect(
        uri: Uri.parse(path),
        signedIn: signedIn,
        devToolsEnabled: dev,
      );

  group('authRedirect', () {
    test('public pages are open to everyone', () {
      expect(go('/'), isNull);
      expect(go('/sign-in'), isNull);
    });

    test(
      'protected pages send signed-out users to sign in, keeping target',
      () {
        expect(go('/app'), '/sign-in?from=%2Fapp');
        expect(go('/employer/jobs'), '/sign-in?from=%2Femployer%2Fjobs');
        expect(go('/admin'), startsWith('/sign-in'));
      },
    );

    test('prefix match is segment-aware', () {
      expect(go('/apply-tips'), isNull);
      expect(go('/administrator-guide'), isNull);
    });

    test('signed-in users skip sign in and return to their target', () {
      expect(go('/app', signedIn: true), isNull);
      expect(go('/sign-in', signedIn: true), '/app');
      expect(go('/sign-in?from=%2Femployer', signedIn: true), '/employer');
    });

    test('never redirects to an external URL', () {
      expect(go('/sign-in?from=https://evil.example', signedIn: true), '/app');
      expect(go('/sign-in?from=//evil.example', signedIn: true), '/app');
    });

    test('dev gallery is hidden when dev tools are off', () {
      expect(go('/dev/gallery'), isNull);
      expect(go('/dev/gallery', dev: false), '/');
    });
  });
}
