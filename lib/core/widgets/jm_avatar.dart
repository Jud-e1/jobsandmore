import 'package:cached_network_image/cached_network_image.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

enum JmAvatarShape { circle, rounded }

/// Person or organisation avatar. Falls back to initials on a deterministic
/// tinted background, so the same name always gets the same colour.
class JmAvatar extends StatelessWidget {
  const new({
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.shape = JmAvatarShape.circle,
    this.online,
    super.key,
  });

  /// Square, rounded logo for organisations.
  const new logo({required this.name, this.imageUrl, this.size = 48, super.key})
    : shape = JmAvatarShape.rounded,
      online = null;

  final String name;
  final String? imageUrl;
  final double size;
  final JmAvatarShape shape;

  /// Presence dot: true online, false away, null hidden.
  final bool? online;

  static const _tints = <(Color, Color)>[
    (Color(0xFFE8F6F0), Color(0xFF065438)),
    (Color(0xFFE6F0FD), Color(0xFF1A4F9E)),
    (Color(0xFFFEF3DC), Color(0xFF7A4A00)),
    (Color(0xFFF1E9FD), Color(0xFF5B2EA6)),
    (Color(0xFFFDE8EE), Color(0xFF9E1F45)),
    (Color(0xFFE2F6F5), Color(0xFF0E5E59)),
  ];

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty && RegExp('[A-Za-z0-9]').hasMatch(p[0]))
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final hash = name.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0xFFFF);
    var (bg, fg) = _tints[hash % _tints.length];
    if (jm.isDark) {
      (bg, fg) = (Color.lerp(fg, jm.surface, 0.55)!, Color.lerp(bg, fg, 0.1)!);
    }
    final radius = shape == JmAvatarShape.circle
        ? BorderRadius.circular(size)
        : BorderRadius.circular(size * 0.26);

    final fallback = Container(
      alignment: Alignment.center,
      color: bg,
      child: Text(
        _initials,
        style: context.type.label.copyWith(
          color: fg,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: shape == JmAvatarShape.rounded
            ? Border.all(color: jm.border)
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: imageUrl == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                fadeInDuration: JmMotion.standard,
                placeholder: (_, _) => fallback,
                errorWidget: (_, _, _) => fallback,
              ),
      ),
    );

    return Semantics(
      image: true,
      label: shape == JmAvatarShape.rounded ? '$name logo' : name,
      excludeSemantics: true,
      child: online == null
          ? avatar
          : Stack(
              clipBehavior: Clip.none,
              children: [
                avatar,
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: size * 0.28,
                    height: size * 0.28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: online! ? jm.success : jm.textSubtle,
                      border: Border.all(color: jm.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Overlapping avatar stack, e.g. "12 people from your network".
class JmAvatarStack extends StatelessWidget {
  const new({required this.names, this.size = 32, this.max = 4, super.key});

  final List<String> names;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final shown = names.take(max).toList();
    final extra = names.length - shown.length;
    final count = shown.length + (extra > 0 ? 1 : 0);
    return SizedBox(
      height: size,
      width: size + (count - 1) * size * 0.7,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * size * 0.7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: jm.surface, width: 2),
                ),
                child: JmAvatar(name: shown[i], size: size - 4),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * size * 0.7,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: jm.surfaceSunken,
                  border: Border.all(color: jm.surface, width: 2),
                ),
                child: Text(
                  '+$extra',
                  style: context.type.caption.copyWith(
                    color: jm.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
