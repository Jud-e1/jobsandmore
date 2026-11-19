/// Phosphor icons (Regular, Thin, Light, Bold, Fill) as plain `IconData`.
///
/// Locally patched copy of phosphor_flutter 2.1.0 (MIT, see LICENSE). The
/// published package extends `IconData`, which is a `final` class from
/// Flutter 3.47 onward, so it no longer compiles. This copy defines every icon
/// as a `const IconData` instead. Dropped: Duotone style, the `PhosphorIcon`
/// widget and the dynamic `PhosphorIcons.x(style)` helper (unused here, and the
/// helper defeats icon-font tree shaking). Remove this package and go back to
/// pub.dev once upstream ships a compatible release.
library;

export 'package:phosphor_flutter/src/phosphor_icons_bold.dart';
export 'package:phosphor_flutter/src/phosphor_icons_fill.dart';
export 'package:phosphor_flutter/src/phosphor_icons_light.dart';
export 'package:phosphor_flutter/src/phosphor_icons_regular.dart';
export 'package:phosphor_flutter/src/phosphor_icons_thin.dart';
