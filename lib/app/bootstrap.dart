import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:jobsandmore/app/app.dart';
import 'package:jobsandmore/app/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initialises services, then runs the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean web URLs: /jobs/123 instead of /#/jobs/123.
  usePathUrlStrategy();

  if (Env.hasSupabase) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  } else if (kDebugMode) {
    debugPrint(
      'SUPABASE_URL / SUPABASE_ANON_KEY not set: running without a backend. '
      'Auth is always signed out.',
    );
  }

  runApp(const ProviderScope(child: JobsAndMoreApp()));
}
