# JobsAndMore (jobsandmoreng.com)

One Flutter codebase for **web, Android and iOS**: jobs, recruitment, career
tools, learning and business support for Nigeria. The product brief lives in
[docs/PROJECT_BRIEF.md](docs/PROJECT_BRIEF.md).

## Status

| Phase | Scope | State |
|---|---|---|
| 0 | Foundation & design system | Done |
| 1 | Database & auth | Next |
| 2–11 | See the brief | Not started |

## Dependency notes

- **Flutter 3.50 / Material:** Material now ships as the `material_ui`
  package. Import `package:material_ui/material_ui.dart`, not
  `package:flutter/material.dart` (deprecated).
- **Riverpod is held at 2.x** (`flutter_riverpod: ^2.6.1`). Providers are
  written by hand. `riverpod_generator` 2.x can't be installed alongside
  current `freezed` / `json_serializable`, so it is not used.
- **Phosphor icons are a patched local copy** in `packages/phosphor_flutter`.
  The pub.dev release (2.1.0) does not compile on Flutter 3.47+ because
  `IconData` became a `final` class. The copy defines each icon as a plain
  `const IconData`. Switch back to pub.dev when upstream releases a fix.

## Prerequisites

- Flutter stable (3.50+; Dart 3.14+). Check with `flutter --version`.
- Android: Android SDK + an emulator or device.
- iOS: a Mac with Xcode (iOS builds cannot be produced on Windows).
- Web: Chrome or Edge.

## Setup

```bash
flutter pub get
cp env/dev.example.json env/dev.json   # then fill in your values; env/*.json is git-ignored
```

The app runs **without** a backend: if `SUPABASE_URL` / `SUPABASE_ANON_KEY`
are missing it starts signed out, which is enough for the design gallery.

## Run

```bash
# Web (Chrome)
flutter run -d chrome --dart-define-from-file=env/dev.json

# Android / iOS
flutter run --dart-define-from-file=env/dev.json
```

Open **`/dev/gallery`** to see every component in light and dark, at 375,
768, 1280 and 1920 px. The gallery is compiled out of production
(`FLAVOR=prod` release builds).

## Quality checks

```bash
flutter analyze
flutter test
```

Tests include a WCAG AA contrast check of every palette pair, router-guard
unit tests, component widget tests, and a full gallery render at all four
widths in both themes (fails on any overflow).

## Brand assets (placeholder logo)

The logo mark is drawn in code (`lib/core/widgets/jm_brand.dart`). To
regenerate the PNGs, app icons and native splash screens:

```bash
flutter test tool/render_brand_assets_test.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

To use a final logo, replace the PNGs in `assets/brand/` (and the inline SVG
in `web/index.html`), then run the last two commands.

## Build

```bash
# Web (WebAssembly, with JS fallback)
flutter build web --wasm --release --dart-define-from-file=env/prod.json

# Android App Bundle for Google Play
flutter build appbundle --release --dart-define-from-file=env/prod.json

# iOS (on macOS)
flutter build ipa --release --dart-define-from-file=env/prod.json
```

## Deploy

- **Web:** upload `build/web` to Firebase Hosting or Vercel. Configure the
  host to rewrite all routes to `/index.html` (the app uses path URLs).
  Public SEO pages are served by the `/seo` Supabase Edge Function (Phase 2).
- **Android:** upload the `.aab` to the Play Console internal track
  (automated in Phase 11 via Codemagic/Fastlane).
- **iOS:** upload the `.ipa` with Transporter or `xcrun altool` to TestFlight.

## Project layout

```
lib/
  app/        app widget, router (auth guard), theme tokens, env
  core/       design-system widgets, responsive helpers, formatters
  features/   one folder per feature (data / domain / presentation)
  l10n/       ARB files (English; ready for Hausa, Yoruba, Igbo, Pidgin)
supabase/     migrations, edge functions, seed (Phase 1+)
tool/         asset generators
```

Rules that keep the codebase consistent:

- Screens never hard-code colours, sizes or text styles. Use `context.jm`
  (colour + depth tokens), `context.type` (type scale) and `JmSpace` /
  `JmRadius`.
- Import components from `package:jobsandmore/core/widgets/widgets.dart`.
- Every async screen has loading (skeleton), empty, error and success states.
- No secrets in the repo. Configuration comes from `--dart-define`.
