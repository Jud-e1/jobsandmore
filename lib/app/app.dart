import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsandmore/app/router/app_router.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/app/theme/theme_mode_provider.dart';
import 'package:jobsandmore/core/responsive/breakpoints.dart';
import 'package:material_ui/material_ui.dart';

class JobsAndMoreApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final mode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'JobsAndMore',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: mode,
      theme: JmTheme.light(),
      darkTheme: JmTheme.dark(),
      themeAnimationDuration: JmMotion.standard,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en', 'NG'), Locale('en')],
      // Headings drop ~15% on phones. Swapping the theme here (rather than
      // per screen) keeps every component on the same scale.
      builder: (context, child) {
        final compact = context.screenSize.isMobile;
        if (!compact) return child!;
        final dark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: dark
              ? JmTheme.dark(compact: true)
              : JmTheme.light(compact: true),
          child: child!,
        );
      },
    );
  }
}
