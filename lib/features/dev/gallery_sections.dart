import 'package:flutter_animate/flutter_animate.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/widgets.dart';
import 'package:jobsandmore/features/dev/gallery_samples.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// One gallery section: id (for the nav), title, blurb and body.
typedef GallerySection = ({
  String id,
  String title,
  String blurb,
  IconData icon,
  WidgetBuilder builder,
});

final gallerySections = <GallerySection>[
  (
    id: 'colour',
    title: 'Colour',
    blurb:
        'Semantic tokens, designed separately for light and dark. '
        'Contrast ratios are computed live against the surface.',
    icon: PhosphorIconsRegular.palette,
    builder: (_) => const _ColourSection(),
  ),
  (
    id: 'type',
    title: 'Typography',
    blurb:
        'Plus Jakarta Sans for headings, Inter for body. Headings scale '
        'down ~15% on phones; system text size is respected.',
    icon: PhosphorIconsRegular.textAa,
    builder: (_) => const _TypeSection(),
  ),
  (
    id: 'space',
    title: 'Space, shape & depth',
    blurb: '4-pt grid, five radii and soft ink-tinted shadows.',
    icon: PhosphorIconsRegular.squaresFour,
    builder: (_) => const _SpaceSection(),
  ),
  (
    id: 'motion',
    title: 'Motion',
    blurb:
        '150 / 250 / 400 ms. Everything decorative switches off under '
        'reduce-motion.',
    icon: PhosphorIconsRegular.waveSine,
    builder: (_) => const _MotionSection(),
  ),
  (
    id: 'buttons',
    title: 'Buttons',
    blurb:
        'Press scale 0.97, gradient hover on primary, keyboard focus '
        'rings, width-stable loading.',
    icon: PhosphorIconsRegular.cursorClick,
    builder: (_) => const _ButtonSection(),
  ),
  (
    id: 'inputs',
    title: 'Inputs & search',
    blurb: 'Labels always visible. The hero search sits on frosted glass.',
    icon: PhosphorIconsRegular.textbox,
    builder: (_) => const _InputSection(),
  ),
  (
    id: 'badges',
    title: 'Badges & chips',
    blurb:
        'Each verification level has its own precise label. Sponsored '
        'is always labelled.',
    icon: PhosphorIconsRegular.sealCheck,
    builder: (_) => const _BadgeSection(),
  ),
  (
    id: 'avatars',
    title: 'Avatars',
    blurb: 'Initials fall back to a stable tint per name.',
    icon: PhosphorIconsRegular.userCircle,
    builder: (_) => const _AvatarSection(),
  ),
  (
    id: 'cards',
    title: 'Listing cards',
    blurb: 'Job, course and employer cards. Hover to lift; tap the heart.',
    icon: PhosphorIconsRegular.cards,
    builder: (_) => const _CardSection(),
  ),
  (
    id: 'data',
    title: 'Data & progress',
    blurb: 'Animated score rings, meters and KPI tiles with sparklines.',
    icon: PhosphorIconsRegular.chartDonut,
    builder: (_) => const _DataSection(),
  ),
  (
    id: 'flow',
    title: 'Stepper & timeline',
    blurb: 'Onboarding progress and application status.',
    icon: PhosphorIconsRegular.path,
    builder: (_) => const _FlowSection(),
  ),
  (
    id: 'kanban',
    title: 'ATS pipeline',
    blurb:
        'Long-press and drag a candidate between stages, or use the '
        'Move button (keyboard and screen-reader friendly).',
    icon: PhosphorIconsRegular.kanban,
    builder: (_) => const _KanbanSection(),
  ),
  (
    id: 'pricing',
    title: 'Pricing',
    blurb:
        'Prices and entitlements come from the plans table. Values here '
        'are samples.',
    icon: PhosphorIconsRegular.tag,
    builder: (_) => const _PricingSection(),
  ),
  (
    id: 'feedback',
    title: 'Feedback & overlays',
    blurb:
        'Illustrated empty states, errors, skeletons, toasts, dialogs '
        'and sheets.',
    icon: PhosphorIconsRegular.chatCircleDots,
    builder: (_) => const _FeedbackSection(),
  ),
];

/// Section wrapper: header + staggered entrance.
class GallerySectionView extends StatelessWidget {
  const new({required this.section, super.key});

  final GallerySection section;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: jm.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(section.icon, size: 20, color: jm.onPrimarySoft),
            ),
            const SizedBox(width: JmSpace.x3),
            Expanded(child: JmSectionHeader(title: section.title)),
          ],
        ),
        const SizedBox(height: JmSpace.x2),
        Text(
          section.blurb,
          style: context.type.body.copyWith(color: jm.textMuted),
        ),
        const SizedBox(height: JmSpace.x6),
        section.builder(context),
      ],
    );
    if (context.reduceMotion) return child;
    return child
        .animate()
        .fadeIn(duration: JmMotion.page, curve: JmMotion.ease)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: JmMotion.page,
          curve: JmMotion.ease,
        );
  }
}

// ---------------------------------------------------------------- helpers --

class _Panel extends StatelessWidget {
  const new({required this.child, this.label});

  final Widget child;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: context.type.overline.copyWith(color: jm.textSubtle),
          ),
          const SizedBox(height: JmSpace.x3),
        ],
        Container(
          padding: const EdgeInsets.all(JmSpace.x6),
          decoration: BoxDecoration(
            color: jm.surface,
            borderRadius: JmRadius.cardAll,
            border: Border.all(color: jm.border),
          ),
          child: child,
        ),
      ],
    );
  }
}

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

// ----------------------------------------------------------------- colour --

class _ColourSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final swatches = <(String, Color, Color)>[
      ('Primary', jm.primary, jm.onPrimary),
      ('Secondary', jm.secondary, jm.onSecondary),
      ('Accent', jm.accent, jm.onAccent),
      ('Info', jm.info, jm.surface),
      ('Success', jm.success, jm.surface),
      ('Warning', jm.warning, jm.surface),
      ('Error', jm.error, jm.surface),
    ];
    final surfaces = <(String, Color)>[
      ('Background', jm.background),
      ('Surface', jm.surface),
      ('Surface alt', jm.surfaceAlt),
      ('Sunken', jm.surfaceSunken),
      ('Border', jm.border),
      ('Text', jm.text),
      ('Text muted', jm.textMuted),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 140),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(JmSpace.x6),
          decoration: BoxDecoration(
            gradient: jm.signature,
            borderRadius: JmRadius.sheetAll,
            boxShadow: jm.shadowPrimary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Signature gradient',
                style: context.type.h3.copyWith(color: Colors.white),
              ),
              Text(
                'Emerald → Teal. Hero, primary hover, premium badges only.',
                style: context.type.small.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        JmAdaptiveGrid(
          minItemWidth: 150,
          maxColumns: 7,
          gap: JmSpace.x3,
          children: [
            for (final (name, c, on) in swatches)
              _Swatch(name: name, color: c, on: on),
          ],
        ),
        const SizedBox(height: JmSpace.x6),
        _Panel(
          label: 'Emerald scale',
          child: ClipRRect(
            borderRadius: JmRadius.buttonAll,
            child: Row(
              children: [
                for (final e in JmBrand.emeraldScale.entries)
                  Expanded(
                    child: Tooltip(
                      message: '${e.key} ${_hex(e.value)}',
                      child: Container(
                        height: 64,
                        color: e.value,
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          '${e.key}',
                          style: context.type.caption.copyWith(
                            color: e.key >= 500 ? Colors.white : JmBrand.ink,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        _Panel(
          label: 'Surfaces & text',
          child: Wrap(
            spacing: JmSpace.x4,
            runSpacing: JmSpace.x4,
            children: [
              for (final (name, c) in surfaces)
                SizedBox(
                  width: 120,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: jm.borderStrong),
                        ),
                      ),
                      const SizedBox(width: JmSpace.x2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: context.type.caption),
                            Text(
                              _hex(c),
                              style: context.type.caption.copyWith(
                                color: jm.textSubtle,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const new({required this.name, required this.color, required this.on});

  final String name;
  final Color color;
  final Color on;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final ratio = _contrast(color, on);
    final surfaceRatio = _contrast(color, jm.surface);
    return Container(
      decoration: BoxDecoration(
        color: jm.surface,
        borderRadius: JmRadius.cardAll,
        border: Border.all(color: jm.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 76,
            color: color,
            padding: const EdgeInsets.all(JmSpace.x3),
            alignment: Alignment.bottomLeft,
            child: Text(
              'Aa ${ratio.toStringAsFixed(1)}',
              style: context.type.label.copyWith(color: on),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(JmSpace.x3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.type.label),
                const SizedBox(height: 2),
                Text(
                  _hex(color),
                  style: context.type.caption.copyWith(color: jm.textMuted),
                ),
                const SizedBox(height: 6),
                Text(
                  surfaceRatio >= 4.5
                      ? 'AA text ${surfaceRatio.toStringAsFixed(1)}:1'
                      : (surfaceRatio >= 3
                            ? 'AA large / UI ${surfaceRatio.toStringAsFixed(1)}:1'
                            : 'Fill only ${surfaceRatio.toStringAsFixed(1)}:1'),
                  style: context.type.caption.copyWith(
                    color: surfaceRatio >= 4.5 ? jm.success : jm.textSubtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- type --

class _TypeSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final jm = context.jm;
    final rows = <(String, TextStyle, String)>[
      ('Display', t.display, 'Work that moves you forward'),
      ('Display S', t.displaySm, 'Hire with confidence'),
      ('H1', t.h1, 'Find your next role'),
      ('H2', t.h2, 'Recommended for you'),
      ('H3', t.h3, 'Applications this week'),
      ('H4', t.h4, 'Senior Product Designer'),
      ('Body L', t.bodyL, 'Build a profile employers can trust, in minutes.'),
      ('Body', t.body, 'We only show salary when the employer discloses it.'),
      ('Small', t.small, 'Closes in 3 days · Lekki, Lagos · Hybrid'),
      ('Caption', t.caption, 'Estimated ATS-readiness, not an employer score'),
    ];
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (name, style, sample) in rows) ...[
            LayoutBuilder(
              builder: (context, c) {
                final spec = Text(
                  '$name · ${style.fontSize!.round()} / '
                  '${style.fontWeight!.value}',
                  style: t.caption.copyWith(color: jm.textSubtle),
                );
                final text = Text(
                  sample,
                  style: style,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                );
                if (c.maxWidth < 560) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [spec, const SizedBox(height: 4), text],
                  );
                }
                return Row(
                  children: [
                    SizedBox(width: 140, child: spec),
                    Expanded(child: text),
                  ],
                );
              },
            ),
            if (name != 'Caption')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: JmSpace.x4),
                child: Divider(height: 1, color: jm.border),
              ),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ space --

class _SpaceSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    const spaces = [4.0, 8.0, 12.0, 16.0, 24.0, 32.0, 48.0, 64.0, 96.0];
    const radii = <(String, double)>[
      ('Input 8', JmRadius.input),
      ('Button 12', JmRadius.button),
      ('Card 16', JmRadius.card),
      ('Sheet 24', JmRadius.sheet),
      ('Full', 40),
    ];
    final shadows = <(String, List<BoxShadow>)>[
      ('Resting', jm.shadowSm),
      ('Raised', jm.shadowMd),
      ('Overlay', jm.shadowLg),
      ('CTA glow', jm.shadowPrimary),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          label: 'Spacing',
          child: Wrap(
            spacing: JmSpace.x4,
            runSpacing: JmSpace.x4,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              for (final s in spaces)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: s,
                      height: s,
                      decoration: BoxDecoration(
                        color: jm.primary.withValues(alpha: 0.18),
                        border: Border.all(color: jm.primary),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${s.round()}',
                      style: context.type.caption.copyWith(color: jm.textMuted),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        _Panel(
          label: 'Radii',
          child: Wrap(
            spacing: JmSpace.x6,
            runSpacing: JmSpace.x4,
            children: [
              for (final (name, r) in radii)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: jm.primarySoft,
                        borderRadius: BorderRadius.circular(r),
                        border: Border.all(color: jm.primary, width: 1.5),
                      ),
                    ),
                    const SizedBox(height: JmSpace.x2),
                    Text(name, style: context.type.caption),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        Container(
          padding: const EdgeInsets.all(JmSpace.x8),
          decoration: BoxDecoration(
            color: jm.background,
            borderRadius: JmRadius.cardAll,
            border: Border.all(color: jm.border),
          ),
          child: Wrap(
            spacing: JmSpace.x8,
            runSpacing: JmSpace.x8,
            alignment: WrapAlignment.center,
            children: [
              for (final (name, s) in shadows)
                Container(
                  width: 140,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: jm.surface,
                    borderRadius: JmRadius.cardAll,
                    boxShadow: s,
                  ),
                  child: Text(name, style: context.type.label),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- motion --

class _MotionSection extends StatefulWidget {
  const new();

  @override
  State<_MotionSection> createState() => _MotionSectionState();
}

class _MotionSectionState extends State<_MotionSection> {
  bool _end = false;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final rows = <(String, Duration, Curve)>[
      ('Micro · 150ms', JmMotion.micro, JmMotion.ease),
      ('Standard · 250ms', JmMotion.standard, JmMotion.ease),
      ('Page · 400ms', JmMotion.page, JmMotion.emphasized),
    ];
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (name, d, curve) in rows) ...[
            Text(name, style: context.type.small.copyWith(color: jm.textMuted)),
            const SizedBox(height: JmSpace.x2),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: jm.surfaceSunken,
                borderRadius: JmRadius.pill,
              ),
              child: AnimatedAlign(
                duration: JmMotion.of(context, d),
                curve: curve,
                alignment: _end ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: jm.signature,
                    shape: BoxShape.circle,
                    boxShadow: jm.shadowPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: JmSpace.x4),
          ],
          Row(
            children: [
              JmButton.secondary(
                label: 'Play',
                leading: PhosphorIconsFill.play,
                onPressed: () => setState(() => _end = !_end),
              ),
              const SizedBox(width: JmSpace.x4),
              Expanded(
                child: Text(
                  context.reduceMotion
                      ? 'Reduce motion is ON: transitions are instant.'
                      : 'Reduce motion is off.',
                  style: context.type.small.copyWith(color: jm.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- buttons --

class _ButtonSection extends StatefulWidget {
  const new();

  @override
  State<_ButtonSection> createState() => _ButtonSectionState();
}

class _ButtonSectionState extends State<_ButtonSection> {
  bool _loading = false;

  Future<void> _fakeLoad() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    void noop() {}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          label: 'Variants',
          child: Wrap(
            spacing: JmSpace.x3,
            runSpacing: JmSpace.x3,
            children: [
              JmButton(
                label: 'Apply now',
                trailing: PhosphorIconsBold.arrowRight,
                onPressed: noop,
              ),
              JmButton.secondary(label: 'Save search', onPressed: noop),
              JmButton.ghost(
                label: 'View details',
                leading: PhosphorIconsBold.eye,
                onPressed: noop,
              ),
              JmButton(
                label: 'Upgrade',
                variant: JmButtonVariant.accent,
                leading: PhosphorIconsFill.lightning,
                onPressed: noop,
              ),
              JmButton(
                label: 'Withdraw',
                variant: JmButtonVariant.destructive,
                onPressed: noop,
              ),
            ],
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        _Panel(
          label: 'Sizes & states',
          child: Wrap(
            spacing: JmSpace.x3,
            runSpacing: JmSpace.x3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              JmButton(label: 'Small', size: JmButtonSize.sm, onPressed: noop),
              JmButton(label: 'Medium', onPressed: noop),
              JmButton(label: 'Large', size: JmButtonSize.lg, onPressed: noop),
              JmButton(
                label: 'Submit application',
                loading: _loading,
                onPressed: _fakeLoad,
              ),
              const JmButton(label: 'Disabled', onPressed: null),
              const JmButton.secondary(label: 'Disabled', onPressed: null),
              JmIconButton(
                icon: PhosphorIconsRegular.shareNetwork,
                label: 'Share',
                onPressed: noop,
              ),
              JmIconButton(
                icon: PhosphorIconsRegular.flag,
                label: 'Report listing',
                filled: true,
                onPressed: noop,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- inputs --

class _InputSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: JmRadius.sheetAll,
          child: JmMeshBackground(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: JmSpace.x6,
                vertical: JmSpace.x12,
              ),
              child: Column(
                children: [
                  Text(
                    'Hero search',
                    style: context.type.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: JmSpace.x6),
                  JmHeroSearchBar(
                    options: GallerySamples.searchOptions,
                    onSearch: (q) => showJmToast(
                      context,
                      'Search: "${q.keyword}" · ${q.location ?? 'Any state'}',
                      tone: JmTone.info,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        _Panel(
          label: 'Compact search',
          child: JmSearchBar(
            hint: 'Search jobs, skills or companies',
            activeFilters: 2,
            onFilterTap: () {},
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        _Panel(
          label: 'Text fields',
          child: JmAdaptiveGrid(
            minItemWidth: 260,
            maxColumns: 2,
            children: [
              const JmTextField(
                label: 'Full name',
                hint: 'As it appears on your ID',
                prefixIcon: PhosphorIconsRegular.user,
              ),
              const JmTextField(
                label: 'Phone number',
                hint: '0803 000 0000',
                helper: 'Used for interview updates. Never shown publicly.',
                prefixIcon: PhosphorIconsRegular.phone,
                keyboardType: TextInputType.phone,
              ),
              const JmTextField(
                label: 'Work email',
                prefixIcon: PhosphorIconsRegular.envelopeSimple,
                errorText: 'Enter an email address like name@company.com',
              ),
              const JmTextField(
                label: 'Password',
                obscure: true,
                prefixIcon: PhosphorIconsRegular.lock,
                helper: 'At least 8 characters.',
              ),
              const JmTextField(
                label: 'LinkedIn URL',
                optional: true,
                prefixIcon: PhosphorIconsRegular.link,
              ),
              JmTextField(
                label: 'Organisation',
                enabled: false,
                prefixIcon: PhosphorIconsRegular.buildings,
                hint: 'Locked after verification',
                suffix: Icon(PhosphorIconsRegular.lock, color: jm.textSubtle),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- badges --

class _BadgeSection extends StatefulWidget {
  const new();

  @override
  State<_BadgeSection> createState() => _BadgeSectionState();
}

class _BadgeSectionState extends State<_BadgeSection> {
  final _selected = <String>{'Lagos', 'Hybrid'};
  final _skills = ['Figma', 'User research', 'Prototyping'];

  @override
  Widget build(BuildContext context) {
    const filters = <(String, int)>[
      ('Lagos', 128),
      ('Abuja', 64),
      ('Remote', 41),
      ('Hybrid', 37),
      ('Internship', 22),
      ('NYSC', 9),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          label: 'Verification (precise levels)',
          child: Wrap(
            spacing: JmSpace.x3,
            runSpacing: JmSpace.x3,
            children: [
              JmBadge.verification(JmVerificationLevel.emailVerified),
              JmBadge.verification(JmVerificationLevel.detailsReviewed),
              JmBadge.verification(JmVerificationLevel.verified),
            ],
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        const _Panel(
          label: 'Listing labels & tones',
          child: Wrap(
            spacing: JmSpace.x3,
            runSpacing: JmSpace.x3,
            children: [
              JmBadge.sponsored(),
              JmBadge.newListing(),
              JmBadge.premium(label: 'Career Plus'),
              JmBadge(label: 'Neutral'),
              JmBadge(label: 'Info', tone: JmTone.info),
              JmBadge(label: 'Warning', tone: JmTone.warning),
              JmBadge(label: 'Closed', tone: JmTone.error),
            ],
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        _Panel(
          label: 'Filter chips',
          child: Wrap(
            spacing: JmSpace.x2,
            runSpacing: JmSpace.x2,
            children: [
              for (final (f, count) in filters)
                JmFilterChip(
                  label: f,
                  count: count,
                  selected: _selected.contains(f),
                  onChanged: (v) => setState(
                    () => v ? _selected.add(f) : _selected.remove(f),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        _Panel(
          label: 'Tags',
          child: Wrap(
            spacing: JmSpace.x2,
            runSpacing: JmSpace.x2,
            children: [
              const JmChip(
                label: 'Full-time',
                icon: PhosphorIconsRegular.briefcase,
              ),
              const JmChip(
                label: 'Hybrid',
                icon: PhosphorIconsRegular.buildings,
              ),
              for (final s in _skills)
                JmChip(
                  label: s,
                  tone: JmTone.primary,
                  onRemove: () => setState(() => _skills.remove(s)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- avatars --

class _AvatarSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => const _Panel(
    child: Wrap(
      spacing: JmSpace.x6,
      runSpacing: JmSpace.x6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        JmAvatar(name: 'Ngozi Adeyemi', size: 64, online: true),
        JmAvatar(name: 'Ibrahim Musa', size: 48),
        JmAvatar(name: 'Folake Johnson', size: 40, online: false),
        JmAvatar(name: 'Emeka', size: 32),
        JmAvatar.logo(name: 'Sample Fintech', size: 56),
        JmAvatar.logo(name: 'Arewa Logistics'),
        JmAvatarStack(
          names: [
            'Ngozi Adeyemi',
            'Ibrahim Musa',
            'Folake Johnson',
            'Emeka Obi',
            'Zainab Bello',
            'Tobi Lawal',
          ],
        ),
      ],
    ),
  );
}

// ------------------------------------------------------------------ cards --

class _CardSection extends StatefulWidget {
  const new();

  @override
  State<_CardSection> createState() => _CardSectionState();
}

class _CardSectionState extends State<_CardSection> {
  final _saved = <String>{'sample-1'};
  final _following = <String>{};

  @override
  Widget build(BuildContext context) {
    void open(String what) => showJmToast(context, 'Open $what');
    final jm = context.jm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'JOBS',
          style: context.type.overline.copyWith(color: jm.textSubtle),
        ),
        const SizedBox(height: JmSpace.x3),
        JmAdaptiveGrid(
          minItemWidth: 300,
          maxColumns: 3,
          children: [
            for (final (i, j) in GallerySamples.jobs.indexed)
              JmJobCard(
                job: j,
                now: GallerySamples.now,
                selected: i == 0,
                saved: _saved.contains(j.id),
                onSavedChanged: (v) {
                  setState(() => v ? _saved.add(j.id) : _saved.remove(j.id));
                  showJmToast(
                    context,
                    v ? 'Saved to your jobs' : 'Removed from saved jobs',
                    tone: v ? JmTone.success : JmTone.neutral,
                    actionLabel: 'Undo',
                    onAction: () => setState(
                      () => v ? _saved.remove(j.id) : _saved.add(j.id),
                    ),
                  );
                },
                onTap: () => open(j.title),
              ),
          ],
        ),
        const SizedBox(height: JmSpace.x8),
        Text(
          'COURSES',
          style: context.type.overline.copyWith(color: jm.textSubtle),
        ),
        const SizedBox(height: JmSpace.x3),
        JmAdaptiveGrid(
          minItemWidth: 260,
          maxColumns: 3,
          children: [
            for (final c in GallerySamples.courses)
              JmCourseCard(course: c, onTap: () => open(c.title)),
          ],
        ),
        const SizedBox(height: JmSpace.x8),
        Text(
          'EMPLOYERS',
          style: context.type.overline.copyWith(color: jm.textSubtle),
        ),
        const SizedBox(height: JmSpace.x3),
        JmAdaptiveGrid(
          minItemWidth: 260,
          maxColumns: 3,
          children: [
            for (final e in GallerySamples.employers)
              JmEmployerCard(
                employer: e,
                following: _following.contains(e.id),
                onFollowChanged: (v) => setState(
                  () => v ? _following.add(e.id) : _following.remove(e.id),
                ),
                onTap: () => open(e.name),
              ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------- data --

class _DataSection extends StatefulWidget {
  const new();

  @override
  State<_DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends State<_DataSection> {
  int _replay = 0;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                key: ValueKey(_replay),
                spacing: JmSpace.x8,
                runSpacing: JmSpace.x6,
                alignment: WrapAlignment.spaceAround,
                children: const [
                  JmScoreRing(score: 82, size: 148, label: 'ATS-readiness'),
                  JmScoreRing(
                    score: 64,
                    size: 148,
                    label: 'Profile',
                    useBandColours: false,
                  ),
                  JmScoreRing(score: 41, size: 96, label: 'Keywords'),
                  JmScoreRing(score: 23, size: 64),
                ],
              ),
              const SizedBox(height: JmSpace.x6),
              Container(
                padding: const EdgeInsets.all(JmSpace.x3),
                decoration: BoxDecoration(
                  color: jm.infoSoft,
                  borderRadius: JmRadius.buttonAll,
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIconsFill.info, size: 18, color: jm.info),
                    const SizedBox(width: JmSpace.x2),
                    Expanded(
                      child: Text(
                        'Estimated ATS-readiness. This is a CV compatibility '
                        "analysis, not any employer's actual screening "
                        'result.',
                        style: context.type.small.copyWith(color: jm.text),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: JmSpace.x4),
              Align(
                alignment: Alignment.centerLeft,
                child: JmButton.ghost(
                  label: 'Replay animation',
                  leading: PhosphorIconsBold.arrowClockwise,
                  onPressed: () => setState(() => _replay++),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        _Panel(
          child: Column(
            key: ValueKey('m$_replay'),
            children: const [
              JmProgressMeter(value: 0.72, label: 'Profile completion'),
              SizedBox(height: JmSpace.x6),
              JmProgressMeter(
                value: 0.35,
                label: 'AI CV reviews used this month',
                trailing: '7 of 20',
                tone: JmTone.info,
              ),
              SizedBox(height: JmSpace.x6),
              JmProgressMeter(
                value: 0.9,
                label: 'Vacancy credits used',
                trailing: '9 of 10',
                tone: JmTone.warning,
              ),
            ],
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        const JmAdaptiveGrid(
          minItemWidth: 240,
          maxColumns: 3,
          children: [
            JmStatTile(
              label: 'Applications',
              value: '248',
              icon: PhosphorIconsRegular.users,
              delta: 0.18,
              deltaLabel: 'vs last 30 days',
              trend: [12, 18, 15, 22, 28, 26, 34, 41],
            ),
            JmStatTile(
              label: 'Listing views',
              value: '3,912',
              icon: PhosphorIconsRegular.eye,
              delta: -0.06,
              deltaLabel: 'vs last 30 days',
              trend: [520, 480, 610, 540, 500, 470, 455, 430],
            ),
            JmStatTile(
              label: 'Time to shortlist',
              value: '4.2 days',
              icon: PhosphorIconsRegular.timer,
              delta: -0.22,
              deltaLabel: 'faster',
              positiveIsGood: false,
              trend: [7, 6.5, 6.8, 5.9, 5.1, 4.8, 4.4, 4.2],
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------- flow --

class _FlowSection extends StatefulWidget {
  const new();

  @override
  State<_FlowSection> createState() => _FlowSectionState();
}

class _FlowSectionState extends State<_FlowSection> {
  int _step = 1;
  static const _steps = [
    'Purpose',
    'Account',
    'Personalise',
    'Profile',
    'Activate',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          label: 'Onboarding stepper',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              JmStepper(
                steps: _steps,
                current: _step,
                onStepTap: (i) => setState(() => _step = i),
              ),
              const SizedBox(height: JmSpace.x6),
              Wrap(
                spacing: JmSpace.x3,
                runSpacing: JmSpace.x3,
                children: [
                  JmButton.secondary(
                    label: 'Back',
                    leading: PhosphorIconsBold.arrowLeft,
                    onPressed: _step == 0
                        ? null
                        : () => setState(() => _step--),
                  ),
                  JmButton(
                    label: 'Next',
                    trailing: PhosphorIconsBold.arrowRight,
                    onPressed: _step == _steps.length - 1
                        ? null
                        : () => setState(() => _step++),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: JmSpace.x6),
        const _Panel(
          label: 'Application status',
          child: JmTimeline(
            items: [
              JmTimelineItem(
                title: 'Application submitted',
                subtitle: 'CV v3 · Tailored cover letter',
                timestamp: '3 Nov 2026',
                state: JmTimelineState.done,
              ),
              JmTimelineItem(
                title: 'Under review',
                timestamp: '5 Nov 2026',
                state: JmTimelineState.done,
              ),
              JmTimelineItem(
                title: 'Shortlisted',
                subtitle: 'The employer added you to their shortlist.',
                timestamp: '9 Nov 2026',
                state: JmTimelineState.current,
              ),
              JmTimelineItem(
                title: 'Interview',
                state: JmTimelineState.upcoming,
              ),
              JmTimelineItem(title: 'Offer', state: JmTimelineState.upcoming),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- kanban --

class _KanbanSection extends StatefulWidget {
  const new();

  @override
  State<_KanbanSection> createState() => _KanbanSectionState();
}

class _KanbanSectionState extends State<_KanbanSection> {
  late final Map<String, List<JmCandidateCardData>> _cols = {
    for (final e in GallerySamples.pipeline().entries) e.key: [...e.value],
  };

  void _move(JmCandidateCardData c, String to) {
    setState(() {
      for (final list in _cols.values) {
        list.removeWhere((x) => x.id == c.id);
      }
      _cols[to]!.insert(0, c);
    });
    showJmToast(context, '${c.name} moved to $to', tone: JmTone.success);
  }

  Future<void> _askMove(JmCandidateCardData c) async {
    final to = await showJmBottomSheet<String>(
      context: context,
      title: 'Move ${c.name}',
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final stage in _cols.keys)
            Padding(
              padding: const EdgeInsets.only(bottom: JmSpace.x2),
              child: JmButton.secondary(
                label: stage,
                expand: true,
                onPressed: () => Navigator.of(context).pop(stage),
              ),
            ),
        ],
      ),
    );
    if (to != null) _move(c, to);
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final colours = [jm.info, jm.primary, jm.accent, jm.success];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, e) in _cols.entries.indexed) ...[
            if (i > 0) const SizedBox(width: JmSpace.x4),
            JmKanbanColumn(
              title: e.key,
              color: colours[i % colours.length],
              candidates: e.value,
              width: 272,
              onAccept: (c) => _move(c, e.key),
              onMoveRequest: _askMove,
              onOpen: (c) => showJmToast(context, 'Open ${c.name}'),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- pricing --

class _PricingSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    void pick() => showJmToast(context, 'Checkout opens in Phase 9');
    return JmAdaptiveGrid(
      minItemWidth: 260,
      maxColumns: 3,
      children: [
        JmPricingCard(
          name: 'Starter',
          description: 'Everything you need to start applying.',
          priceLabel: '₦0',
          features: const [
            'Unlimited job applications',
            'Career profile and 2 CV versions',
            '3 AI CV reviews per month',
          ],
          ctaLabel: 'Current plan',
          current: true,
          onSelect: pick,
        ),
        JmPricingCard(
          name: 'Career Plus',
          description: 'Sample price for illustration.',
          priceLabel: '₦4,500',
          period: 'month',
          highlighted: true,
          highlightLabel: 'Most chosen',
          features: const [
            'Unlimited AI CV and ATS-readiness reviews',
            'AI interview coach',
            'Priority job alerts',
            'Skills gap analysis linked to courses',
          ],
          ctaLabel: 'Upgrade',
          onSelect: pick,
        ),
        JmPricingCard(
          name: 'Employer Professional',
          description: 'Sample price for illustration.',
          priceLabel: '₦45,000',
          period: 'month',
          features: const [
            '5 active vacancies',
            'ATS pipeline and team seats',
            'Screening questions',
            'Hiring analytics',
          ],
          ctaLabel: 'Start hiring',
          onSelect: pick,
        ),
      ],
    );
  }
}

// --------------------------------------------------------------- feedback --

class _FeedbackSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    void noop() {}
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JmAdaptiveGrid(
          minItemWidth: 260,
          maxColumns: 3,
          children: [
            _Panel(
              child: JmEmptyState(
                compact: true,
                illustration: JmIllustration.saved,
                title: 'No saved jobs yet',
                message: 'Tap the heart on any job to keep it here.',
                actionLabel: 'Browse jobs',
                onAction: noop,
              ),
            ),
            const _Panel(
              child: JmEmptyState(
                compact: true,
                illustration: JmIllustration.learning,
                title: 'Start learning',
                message: 'Courses you enrol in will show your progress here.',
              ),
            ),
            _Panel(
              child: JmErrorState(
                offline: true,
                title: "You're offline",
                message:
                    'Check your connection. Saved jobs are still '
                    'available.',
                onRetry: noop,
              ),
            ),
          ],
        ),
        const SizedBox(height: JmSpace.x6),
        Text(
          'SKELETON (MATCHES JOB CARD)',
          style: context.type.overline.copyWith(color: jm.textSubtle),
        ),
        const SizedBox(height: JmSpace.x3),
        const JmAdaptiveGrid(
          minItemWidth: 300,
          maxColumns: 3,
          children: [
            JmJobCardSkeleton(),
            JmJobCardSkeleton(),
            JmJobCardSkeleton(),
          ],
        ),
        const SizedBox(height: JmSpace.x6),
        _Panel(
          label: 'Overlays',
          child: Wrap(
            spacing: JmSpace.x3,
            runSpacing: JmSpace.x3,
            children: [
              JmButton.secondary(
                label: 'Success toast',
                leading: PhosphorIconsRegular.checkCircle,
                onPressed: () => showJmToast(
                  context,
                  'Application submitted',
                  tone: JmTone.success,
                ),
              ),
              JmButton.secondary(
                label: 'Error toast',
                leading: PhosphorIconsRegular.warningCircle,
                onPressed: () => showJmToast(
                  context,
                  "Couldn't upload your CV. Try a PDF under 5 MB.",
                  tone: JmTone.error,
                ),
              ),
              JmButton.secondary(
                label: 'Dialog',
                leading: PhosphorIconsRegular.appWindow,
                onPressed: () => showJmDialog(
                  context: context,
                  title: 'Withdraw application?',
                  message:
                      'The employer will see that you withdrew. You can '
                      'apply again while the job is open.',
                  confirmLabel: 'Withdraw',
                  destructive: true,
                  icon: PhosphorIconsBold.warning,
                ),
              ),
              JmButton.secondary(
                label: 'Bottom sheet',
                leading: PhosphorIconsRegular.arrowLineUp,
                onPressed: () => showJmBottomSheet<void>(
                  context: context,
                  title: 'Filters',
                  builder: (context) => Wrap(
                    spacing: JmSpace.x2,
                    runSpacing: JmSpace.x2,
                    children: [
                      for (final s in GallerySamples.searchOptions.locations)
                        JmFilterChip(
                          label: s,
                          selected: s == 'Lagos',
                          onChanged: (_) {},
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
