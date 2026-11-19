// Renders the placeholder logo mark to PNGs used by flutter_launcher_icons,
// flutter_native_splash and the web favicon/manifest icons.
//
// Run:  flutter test tool/render_brand_assets_test.dart
// Then: dart run flutter_launcher_icons && dart run flutter_native_splash:create
//
// Replace with the final logo by dropping new PNGs into assets/brand/ and
// re-running the two commands above.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:jobsandmore/app/theme/tokens.dart';
import 'package:jobsandmore/core/widgets/jm_brand.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _write(String path, ui.Image image) async {
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path)..createSync(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
}

Future<ui.Image> _paint(
  double size,
  void Function(Canvas canvas, Size size) draw,
) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  draw(canvas, Size.square(size));
  return recorder.endRecording().toImage(size.toInt(), size.toInt());
}

void main() {
  test('render brand assets', () async {
    final logo = JmLogoPainter();

    // Full-bleed app icon (iOS masks its own corners; keep square tile).
    await _write(
      'assets/brand/app_icon.png',
      await _paint(1024, (c, s) {
        c.drawRect(Offset.zero & s, Paint()..color = JmBrand.emerald);
        logo.paint(c, s);
      }),
    );

    // Android adaptive foreground: mark centred in the 66% safe zone.
    await _write(
      'assets/brand/app_icon_foreground.png',
      await _paint(1024, (c, s) {
        const inset = 1024 * 0.22;
        c
          ..save()
          ..translate(inset, inset);
        logo.paint(c, const Size.square(1024 - inset * 2));
        c.restore();
      }),
    );

    // Splash mark (transparent background, centred by the splash generator).
    await _write('assets/brand/splash_mark.png', await _paint(768, logo.paint));

    // Web icons.
    for (final px in [16, 32, 192, 512]) {
      await _write(
        px <= 32 ? 'web/favicon-$px.png' : 'web/icons/Icon-$px.png',
        await _paint(px.toDouble(), logo.paint),
      );
    }
    await _write(
      'web/icons/Icon-maskable-512.png',
      await _paint(512, (c, s) {
        c.drawRect(Offset.zero & s, Paint()..color = JmBrand.emerald);
        const inset = 512 * 0.18;
        c
          ..save()
          ..translate(inset, inset);
        logo.paint(c, const Size.square(512 - inset * 2));
        c.restore();
      }),
    );
    await _write(
      'web/icons/Icon-maskable-192.png',
      await _paint(192, (c, s) {
        c.drawRect(Offset.zero & s, Paint()..color = JmBrand.emerald);
        const inset = 192 * 0.18;
        c
          ..save()
          ..translate(inset, inset);
        logo.paint(c, const Size.square(192 - inset * 2));
        c.restore();
      }),
    );
  });
}
