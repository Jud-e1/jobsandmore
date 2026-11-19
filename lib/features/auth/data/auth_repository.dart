import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Minimal signed-in identity used by routing. Fuller profile data lives in
/// the profile feature.
class AppUser {
  const new({required this.id, this.email});

  final String id;
  final String? email;
}

/// A sign-in / sign-up failure with a message safe to show the user.
class AuthFailure implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}

/// What happened after sign-up.
enum SignUpResult {
  /// Account created; the user must confirm their email before signing in.
  needsEmailConfirmation,

  /// Account created and signed in (email confirmation disabled).
  signedIn,
}

/// Auth boundary, kept behind an interface so tests and offline builds can
/// swap the Supabase implementation.
abstract interface class AuthRepository {
  AppUser? get currentUser;
  Stream<AppUser?> authStateChanges();

  /// True when a real backend is connected.
  bool get isLive;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  });
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required Map<String, Object?> metadata,
  });
  Future<void> signInWithGoogle();
  Future<void> sendMagicLink(String email);
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  new(this._client);

  final SupabaseClient _client;

  AppUser? _map(User? u) =>
      u == null ? null : AppUser(id: u.id, email: u.email);

  String? get _redirect => kIsWeb
      ? '${Env.siteUrl}/app/personalise'
      : 'com.jobsandmoreng.app://auth-callback';

  @override
  bool get isLive => true;

  @override
  AppUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() =>
      _client.auth.onAuthStateChange.map((s) => _map(s.session?.user));

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AuthException catch (e) {
      // Supabase messages are already user-facing; normalise the common ones.
      final m = e.message.toLowerCase();
      if (m.contains('invalid login')) {
        throw const AuthFailure('Email or password is incorrect.');
      }
      if (m.contains('email not confirmed')) {
        throw const AuthFailure(
          'Please confirm your email first. Check your inbox for the link.',
        );
      }
      if (m.contains('already registered')) {
        throw const AuthFailure(
          'An account with this email already exists. Try signing in.',
        );
      }
      if (e.statusCode == '429') {
        throw const AuthFailure(
          'Too many attempts. Please wait a few minutes and try again.',
        );
      }
      throw AuthFailure(e.message);
    } on Object {
      throw const AuthFailure(
        'We could not reach JobsAndMore. Check your connection and try again.',
      );
    }
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) => _guard(
    () => _client.auth.signInWithPassword(email: email, password: password),
  );

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required Map<String, Object?> metadata,
  }) => _guard(() async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: metadata,
      emailRedirectTo: _redirect,
    );
    return res.session == null
        ? SignUpResult.needsEmailConfirmation
        : SignUpResult.signedIn;
  });

  @override
  Future<void> signInWithGoogle() => _guard(
    () => _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _redirect,
    ),
  );

  @override
  Future<void> sendMagicLink(String email) => _guard(
    () => _client.auth.signInWithOtp(email: email, emailRedirectTo: _redirect),
  );

  @override
  Future<void> sendPasswordReset(String email) => _guard(
    () => _client.auth.resetPasswordForEmail(email, redirectTo: _redirect),
  );

  @override
  Future<void> signOut() => _client.auth.signOut();
}

/// Preview mode: used when Supabase is not configured. Forms still validate
/// so the screens can be reviewed, but nothing is sent anywhere.
class PreviewAuthRepository implements AuthRepository {
  @override
  bool get isLive => false;

  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required Map<String, Object?> metadata,
  }) async => SignUpResult.signedIn;

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> sendMagicLink(String email) async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {}
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (Env.hasSupabase) return SupabaseAuthRepository(Supabase.instance.client);
  return PreviewAuthRepository();
});

/// Current user, updated as auth state changes.
final authStateProvider = StreamProvider<AppUser?>((ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield repo.currentUser;
  yield* repo.authStateChanges();
});

/// Validation shared by the sign-in and sign-up forms.
abstract final class AuthValidators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  static String? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Enter your email address.';
    if (!_email.hasMatch(s)) {
      return 'Enter a full email address, e.g. name@example.com';
    }
    return null;
  }

  /// Password rules shown up front on the sign-up form.
  static ({bool length, bool number, bool mixedCase, bool symbol})
  passwordRules(String p) => (
    length: p.length >= 8,
    number: RegExp('[0-9]').hasMatch(p),
    mixedCase: RegExp('[a-z]').hasMatch(p) && RegExp('[A-Z]').hasMatch(p),
    symbol: RegExp('[^A-Za-z0-9]').hasMatch(p),
  );

  static String? newPassword(String? v) {
    final r = passwordRules(v ?? '');
    if (!r.length || !r.number || !r.mixedCase) {
      return 'Use 8+ characters with a number and upper and lower case letters.';
    }
    return null;
  }

  static String? required(String? v, String what) =>
      (v == null || v.trim().isEmpty) ? 'Enter your $what.' : null;
}
