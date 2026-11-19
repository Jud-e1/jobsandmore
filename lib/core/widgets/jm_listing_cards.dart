import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/utils/formatters.dart';
import 'package:jobsandmore/core/widgets/jm_avatar.dart';
import 'package:jobsandmore/core/widgets/jm_badge.dart';
import 'package:jobsandmore/core/widgets/jm_button.dart';
import 'package:jobsandmore/core/widgets/jm_card.dart';
import 'package:jobsandmore/core/widgets/jm_pressable.dart';
import 'package:jobsandmore/core/widgets/jm_progress.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// What a job card needs. Built from the `jobs` table by the jobs feature.
@immutable
class JmJobCardData {
  const new({
    required this.id,
    required this.title,
    required this.employerName,
    required this.verification,
    required this.location,
    required this.jobType,
    required this.arrangement,
    required this.postedAt,
    this.closingDate,
    this.logoUrl,
    this.salaryMin,
    this.salaryMax,
    this.salaryDisclosed = false,
    this.isSponsored = false,
    this.matchPercent,
  });

  final String id;
  final String title;
  final String employerName;
  final JmVerificationLevel verification;
  final String location;
  final String jobType;
  final String arrangement;
  final DateTime postedAt;
  final DateTime? closingDate;
  final String? logoUrl;
  final int? salaryMin;
  final int? salaryMax;
  final bool salaryDisclosed;
  final bool isSponsored;
  final int? matchPercent;

  bool isNew(DateTime now) => now.difference(postedAt).inDays < 3;
}

/// Job listing card with save heart, precise badges and a hero logo.
class JmJobCard extends StatelessWidget {
  const new({
    required this.job,
    required this.onTap,
    this.saved = false,
    this.onSavedChanged,
    this.selected = false,
    this.now,
    super.key,
  });

  final JmJobCardData job;
  final VoidCallback? onTap;
  final bool saved;
  final ValueChanged<bool>? onSavedChanged;
  final bool selected;

  /// Injected for tests and goldens.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final today = now ?? DateTime.now();
    final salary = JmFormat.salaryRange(
      job.salaryMin,
      job.salaryMax,
      disclosed: job.salaryDisclosed,
    );
    final closing = job.closingDate == null
        ? null
        : JmFormat.closingIn(job.closingDate!, today);

    return JmCard(
      onTap: onTap,
      highlighted: selected,
      semanticLabel:
          '${job.title} at ${job.employerName}, ${job.location}'
          '${job.isSponsored ? ', sponsored' : ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'job-logo-${job.id}',
                child: JmAvatar.logo(
                  name: job.employerName,
                  imageUrl: job.logoUrl,
                ),
              ),
              const SizedBox(width: JmSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (job.isSponsored)
                          const JmBadge.sponsored(dense: true),
                        if (job.isNew(today))
                          const JmBadge.newListing(dense: true),
                      ],
                    ),
                    if (job.isSponsored || job.isNew(today))
                      const SizedBox(height: 6),
                    Text(
                      job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: type.h4.copyWith(fontSize: 18, height: 1.3),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job.employerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: type.small.copyWith(
                              color: jm.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (job.verification ==
                            JmVerificationLevel.verified) ...[
                          const SizedBox(width: 4),
                          Tooltip(
                            message: job.verification.explanation,
                            child: Icon(
                              PhosphorIconsFill.sealCheck,
                              size: 16,
                              color: jm.primary,
                              semanticLabel: job.verification.label,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (onSavedChanged != null)
                JmSaveButton(saved: saved, onChanged: onSavedChanged!),
            ],
          ),
          const SizedBox(height: JmSpace.x4),
          Wrap(
            spacing: JmSpace.x4,
            runSpacing: JmSpace.x2,
            children: [
              _Meta(icon: PhosphorIconsRegular.mapPin, text: job.location),
              _Meta(icon: PhosphorIconsRegular.briefcase, text: job.jobType),
              _Meta(
                icon: PhosphorIconsRegular.buildings,
                text: job.arrangement,
              ),
            ],
          ),
          const SizedBox(height: JmSpace.x4),
          Divider(height: 1, color: jm.border),
          const SizedBox(height: JmSpace.x3),
          LayoutBuilder(
            builder: (context, c) {
              final salaryText = Text(
                salary ?? 'Salary not disclosed',
                style: salary == null
                    ? type.small.copyWith(color: jm.textSubtle)
                    : type.label.copyWith(color: jm.text, fontSize: 15),
              );
              final hasSignals = job.matchPercent != null || closing != null;
              final signals = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (job.matchPercent != null) ...[
                    JmMatchPill(percent: job.matchPercent!),
                    const SizedBox(width: JmSpace.x2),
                  ],
                  if (closing != null)
                    Flexible(
                      child: Text(
                        closing.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: type.caption.copyWith(
                          color: closing.urgent ? jm.warning : jm.textSubtle,
                          fontWeight: closing.urgent
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              );
              // Narrow cards (phones): salary gets its own line so it never
              // wraps awkwardly beside the match pill and deadline.
              if (c.maxWidth < 360 && salary != null && hasSignals) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    salaryText,
                    const SizedBox(height: JmSpace.x2),
                    signals,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: salaryText),
                  if (hasSignals) Flexible(child: signals),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const new({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: jm.textSubtle),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.small.copyWith(color: jm.textMuted),
          ),
        ),
      ],
    );
  }
}

/// "82% match" pill.
class JmMatchPill extends StatelessWidget {
  const new({required this.percent, super.key});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final tone = percent >= 75
        ? JmTone.success
        : (percent >= 50 ? JmTone.info : JmTone.neutral);
    return Semantics(
      label: 'Estimated match $percent percent',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: jm.toneBg(tone),
          borderRadius: JmRadius.pill,
        ),
        child: Text(
          '$percent% match',
          style: context.type.caption.copyWith(
            color: jm.toneFg(tone),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Heart toggle with a springy pop when saved.
class JmSaveButton extends StatelessWidget {
  const new({required this.saved, required this.onChanged, super.key});

  final bool saved;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final reduce = context.reduceMotion;
    return JmPressable(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onChanged(!saved);
      },
      semanticLabel: saved ? 'Remove from saved jobs' : 'Save job',
      selected: saved,
      tooltip: saved ? 'Saved' : 'Save',
      builder: (context, s) {
        Widget icon = Icon(
          saved ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
          key: ValueKey(saved),
          size: 22,
          color: saved ? jm.error : (s.hovered ? jm.text : jm.textSubtle),
        );
        if (saved && !reduce) {
          icon = icon.animate().scale(
            begin: const Offset(0.6, 0.6),
            end: const Offset(1, 1),
            duration: JmMotion.standard,
            curve: Curves.elasticOut,
          );
        }
        return AnimatedContainer(
          duration: JmMotion.micro,
          width: JmSpace.minTouch,
          height: JmSpace.minTouch,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: s.hovered ? jm.surfaceSunken : Colors.transparent,
          ),
          child: Center(child: icon),
        );
      },
    );
  }
}

/// What a course card needs.
@immutable
class JmCourseCardData {
  const new({
    required this.id,
    required this.title,
    required this.providerName,
    required this.level,
    required this.durationLabel,
    required this.format,
    this.priceLabel,
    this.hasCertificate = false,
    this.progress,
    this.coverUrl,
  });

  final String id;
  final String title;
  final String providerName;
  final String level;
  final String durationLabel;
  final String format;

  /// Null means free. Prices come from the provider, never hard-coded.
  final String? priceLabel;
  final bool hasCertificate;

  /// 0–1 when the learner is enrolled.
  final double? progress;
  final String? coverUrl;
}

/// Course card with generated cover art (unique per course id).
class JmCourseCard extends StatelessWidget {
  const new({required this.course, required this.onTap, super.key});

  final JmCourseCardData course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return JmCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      semanticLabel: '${course.title} by ${course.providerName}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'course-cover-${course.id}',
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(JmRadius.card - 1),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 8,
                child: JmCoverArt(seed: course.id, label: course.format),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(JmSpace.x6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.providerName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.overline.copyWith(color: jm.textSubtle),
                ),
                const SizedBox(height: 6),
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: type.h4.copyWith(fontSize: 18, height: 1.3),
                ),
                const SizedBox(height: JmSpace.x3),
                Wrap(
                  spacing: JmSpace.x4,
                  runSpacing: JmSpace.x2,
                  children: [
                    _Meta(
                      icon: PhosphorIconsRegular.chartBar,
                      text: course.level,
                    ),
                    _Meta(
                      icon: PhosphorIconsRegular.clock,
                      text: course.durationLabel,
                    ),
                  ],
                ),
                const SizedBox(height: JmSpace.x4),
                if (course.progress != null)
                  JmProgressMeter(
                    value: course.progress!,
                    label: 'Progress',
                    compact: true,
                  )
                else
                  Row(
                    children: [
                      Text(
                        course.priceLabel ?? 'Free',
                        style: type.label.copyWith(
                          fontSize: 15,
                          color: course.priceLabel == null
                              ? jm.success
                              : jm.text,
                        ),
                      ),
                      const Spacer(),
                      if (course.hasCertificate)
                        const JmBadge(
                          label: 'Certificate',
                          icon: PhosphorIconsBold.certificate,
                          tone: JmTone.info,
                          dense: true,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Deterministic abstract cover art (no stock imagery). Each seed yields its
/// own palette rotation and shape layout so no two covers repeat.
class JmCoverArt extends StatelessWidget {
  const new({required this.seed, this.label, super.key});

  final String seed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final h = seed.codeUnits.fold<int>(7, (a, b) => (a * 33 + b) & 0x7FFFFFFF);
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _CoverPainter(h, dark: jm.isDark)),
        if (label != null)
          Positioned(
            left: JmSpace.x3,
            bottom: JmSpace.x3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: JmRadius.pill,
              ),
              child: Text(
                label!,
                style: context.type.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CoverPainter extends CustomPainter {
  new(this.h, {required this.dark});

  final int h;
  final bool dark;

  static const _sets = <List<Color>>[
    [Color(0xFF0B8457), Color(0xFF14B8A6), Color(0xFFF5A524)],
    [Color(0xFF0F1B2D), Color(0xFF2F80ED), Color(0xFF14B8A6)],
    [Color(0xFF065438), Color(0xFFF5A524), Color(0xFFFFE3A8)],
    [Color(0xFF1A4F9E), Color(0xFF0B8457), Color(0xFFBDEBD7)],
    [Color(0xFF7A4A00), Color(0xFFF5A524), Color(0xFF0B8457)],
    [Color(0xFF243044), Color(0xFF12B76A), Color(0xFF8FE3DA)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final set = _sets[h % _sets.length];
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [set[0], Color.lerp(set[0], set[1], 0.6)!],
        ).createShader(rect),
    );
    final w = size.width;
    final ht = size.height;
    final r1 = ht * (0.55 + (h >> 3 & 7) / 30);
    canvas.drawCircle(
      Offset(w * (0.7 + (h >> 6 & 7) / 40), ht * 0.2),
      r1,
      Paint()..color = set[1].withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      Offset(w * (0.92 - (h >> 9 & 7) / 50), ht * 0.95),
      ht * 0.32,
      Paint()..color = set[2].withValues(alpha: 0.85),
    );
    // Fine grid lines for texture.
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var x = 0.0; x < w; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, ht), line);
    }
    if (dark) {
      canvas.drawRect(
        rect,
        Paint()..color = Colors.black.withValues(alpha: 0.12),
      );
    }
  }

  @override
  bool shouldRepaint(_CoverPainter old) => old.h != h || old.dark != dark;
}

/// What an employer card needs.
@immutable
class JmEmployerCardData {
  const new({
    required this.id,
    required this.name,
    required this.industry,
    required this.location,
    required this.verification,
    required this.openRoles,
    this.logoUrl,
    this.tagline,
  });

  final String id;
  final String name;
  final String industry;
  final String location;
  final JmVerificationLevel verification;
  final int openRoles;
  final String? logoUrl;
  final String? tagline;
}

class JmEmployerCard extends StatelessWidget {
  const new({
    required this.employer,
    required this.onTap,
    this.following = false,
    this.onFollowChanged,
    super.key,
  });

  final JmEmployerCardData employer;
  final VoidCallback? onTap;
  final bool following;
  final ValueChanged<bool>? onFollowChanged;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return JmCard(
      onTap: onTap,
      semanticLabel: employer.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              JmAvatar.logo(
                name: employer.name,
                imageUrl: employer.logoUrl,
                size: 56,
              ),
              const Spacer(),
              if (onFollowChanged != null)
                JmButton(
                  label: following ? 'Following' : 'Follow',
                  leading: following
                      ? PhosphorIconsBold.check
                      : PhosphorIconsBold.plus,
                  variant: following
                      ? JmButtonVariant.secondary
                      : JmButtonVariant.ghost,
                  size: JmButtonSize.sm,
                  onPressed: () => onFollowChanged!(!following),
                ),
            ],
          ),
          const SizedBox(height: JmSpace.x4),
          Text(employer.name, style: type.h4),
          const SizedBox(height: 6),
          if (employer.verification != JmVerificationLevel.none)
            JmBadge.verification(employer.verification, dense: true),
          if (employer.tagline != null) ...[
            const SizedBox(height: JmSpace.x3),
            Text(
              employer.tagline!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: type.small.copyWith(color: jm.textMuted),
            ),
          ],
          const SizedBox(height: JmSpace.x4),
          Wrap(
            spacing: JmSpace.x4,
            runSpacing: JmSpace.x2,
            children: [
              _Meta(
                icon: PhosphorIconsRegular.factory,
                text: employer.industry,
              ),
              _Meta(icon: PhosphorIconsRegular.mapPin, text: employer.location),
            ],
          ),
          const SizedBox(height: JmSpace.x4),
          Divider(height: 1, color: jm.border),
          const SizedBox(height: JmSpace.x3),
          Row(
            children: [
              Text(
                employer.openRoles == 1
                    ? '1 open role'
                    : '${employer.openRoles} open roles',
                style: type.label.copyWith(
                  color: jm.isDark ? jm.primary : jm.onPrimarySoft,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                PhosphorIconsBold.arrowRight,
                size: 14,
                color: jm.isDark ? jm.primary : jm.onPrimarySoft,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
