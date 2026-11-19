#!/usr/bin/env bash
# Vercel "install" step for Git-triggered deploys: fetches the pinned Flutter
# SDK into /tmp/flutter and resolves packages. The build step (vercel.json)
# then runs `flutter build web --release` and serves build/web.
set -euo pipefail

FLUTTER_VERSION="3.50.0"

# Flutter's first run unpacks the Dart SDK and needs unzip/xz.
if ! command -v unzip >/dev/null 2>&1 || ! command -v xz >/dev/null 2>&1; then
  dnf install -y unzip xz >/dev/null 2>&1 || yum install -y unzip xz >/dev/null 2>&1 || true
fi

if [ ! -x /tmp/flutter/bin/flutter ]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git /tmp/flutter
fi

export PATH="/tmp/flutter/bin:$PATH"
flutter config --no-analytics >/dev/null
flutter --version
flutter pub get
