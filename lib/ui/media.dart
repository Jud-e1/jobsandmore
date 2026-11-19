import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Photos bundled in assets/images/ (sources in assets/images/CREDITS.md).
abstract final class DImages {
  // Generated in Canva for JobsAndMore.
  static const heroOffice = 'assets/images/hero_office.jpg';
  static const graduate = 'assets/images/graduate_portrait.jpg';
  // Unsplash, free Unsplash License.
  static const teamMeeting = 'assets/images/team_meeting.jpg';
  static const shopOwner = 'assets/images/shop_owner.jpg';
  static const chefOwner = 'assets/images/chef_owner.jpg';
  static const professional = 'assets/images/professional_man.jpg';
  static const classroom = 'assets/images/classroom.jpg';
  static const tailor = 'assets/images/tailor.jpg';
  static const lagos = 'assets/images/lagos_skyline.jpg';
  static const handshake = 'assets/images/handshake.jpg';
  static const womanDesk = 'assets/images/woman_desk.jpg';
}

/// Rounded photo with a soft shadow, Apple product-shot style.
class DPhoto extends StatelessWidget {
  const new(
    this.asset, {
    this.radius = 28,
    this.height,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.shadow = true,
    super.key,
  });

  final String asset;
  final double radius;
  final double? height;
  final Alignment alignment;
  final String? semanticLabel;
  final bool shadow;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow
          ? const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 40,
                offset: Offset(0, 18),
              ),
            ]
          : null,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        asset,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: alignment,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        errorBuilder: (_, _, _) =>
            Container(height: height ?? 300, color: context.jm.surfaceSunken),
      ),
    ),
  );
}

/// Frosted floating card used over photos.
class DGlassCard extends StatelessWidget {
  const new({required this.child, this.width, super.key});

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.jm.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x26000000),
          blurRadius: 30,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: child,
  );
}

/// Full-bleed photo band behind a page hero. The photo is decorative; a dark
/// scrim keeps white text above WCAG AA contrast whatever the image shows.
class DPhotoBackdrop extends StatelessWidget {
  const new({
    required this.asset,
    required this.child,
    this.alignment = Alignment.center,
    this.tint = const Color(0xFF06291C),
    this.strength = 0.82,
    super.key,
  });

  final String asset;
  final Widget child;
  final Alignment alignment;

  /// Scrim colour (defaults to a deep forest green).
  final Color tint;

  /// Opacity of the scrim on the text side (0–1).
  final double strength;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            alignment: alignment,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) => ColoredBox(color: tint),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: wide
                  ? LinearGradient(
                      colors: [
                        tint.withValues(alpha: strength),
                        tint.withValues(alpha: strength * 0.85),
                        tint.withValues(alpha: strength * 0.35),
                      ],
                      stops: const [0, 0.5, 1],
                    )
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        tint.withValues(alpha: strength * 0.7),
                        tint.withValues(alpha: strength),
                      ],
                    ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Photo card with a caption on a bottom gradient (Freelancer-style category
/// tile). Taps are optional.
class DPhotoTile extends StatefulWidget {
  const new({
    required this.asset,
    required this.title,
    this.subtitle,
    this.height = 240,
    this.alignment = Alignment.center,
    this.onTap,
    super.key,
  });

  final String asset;
  final String title;
  final String? subtitle;
  final double height;
  final Alignment alignment;
  final VoidCallback? onTap;

  @override
  State<DPhotoTile> createState() => _DPhotoTileState();
}

class _DPhotoTileState extends State<DPhotoTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final reduce = context.reduceMotion;
    final tile = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedScale(
              scale: _hover && !reduce ? 1.05 : 1,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              child: Image.asset(
                widget.asset,
                fit: BoxFit.cover,
                alignment: widget.alignment,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) =>
                    ColoredBox(color: context.jm.surfaceSunken),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xD9000000)],
                  stops: [0.35, 1],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: type.h4.copyWith(color: Colors.white),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: type.small.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (widget.onTap == null) return tile;
    return Semantics(
      button: true,
      label: widget.title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(onTap: widget.onTap, child: tile),
      ),
    );
  }
}
