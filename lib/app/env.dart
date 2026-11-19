import 'package:flutter/foundation.dart';

/// Build-time configuration, injected with `--dart-define` (or
/// `--dart-define-from-file=env/dev.json`). Never commit real values.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const paystackPublicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
  );

  /// `dev`, `staging` or `prod`.
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// Public site origin, used for share links and SEO deep links.
  static const siteUrl = String.fromEnvironment(
    'SITE_URL',
    defaultValue: 'https://jobsandmoreng.com',
  );

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isProd => flavor == 'prod';

  /// The component gallery ships in debug/profile and non-prod flavours only.
  static bool get devToolsEnabled => !kReleaseMode || !isProd;
}
