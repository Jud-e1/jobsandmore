import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Organisation verification levels. Each maps to its own precise label so a
/// badge never implies checks that were not done (product rule 2).
enum JmVerificationLevel {
  none,
  emailVerified,
  detailsReviewed,
  verified;

  String get label => switch (this) {
    JmVerificationLevel.none => 'Not verified',
    JmVerificationLevel.emailVerified => 'Email verified',
    JmVerificationLevel.detailsReviewed => 'Business details reviewed',
    JmVerificationLevel.verified => 'Verified employer',
  };

  /// What the label actually means, for tooltips and screen readers.
  String get explanation => switch (this) {
    JmVerificationLevel.none =>
      'This organisation has not completed any verification checks.',
    JmVerificationLevel.emailVerified =>
      'The account holder confirmed an email address on the '
          "organisation's domain. Business details have not been reviewed.",
    JmVerificationLevel.detailsReviewed =>
      'Our team reviewed the submitted business details. Registration '
          'documents have not yet been fully verified.',
    JmVerificationLevel.verified =>
      'Our team verified registration documents and the identity of the '
          'account holder.',
  };
}

/// Small status label. Use the named constructors for the standard meanings.
class JmBadge extends StatelessWidget {
  const new({
    required this.label,
    this.tone = JmTone.neutral,
    this.icon,
    this.tooltip,
    this.premium = false,
    this.dense = false,
    super.key,
  });

  /// Precise verification badge. Renders nothing for [JmVerificationLevel.none].
  factory verification(
    JmVerificationLevel level, {
    bool dense = false,
    Key? key,
  }) => JmBadge(
    key: key,
    label: level.label,
    tooltip: level.explanation,
    dense: dense,
    tone: switch (level) {
      JmVerificationLevel.verified => JmTone.primary,
      JmVerificationLevel.detailsReviewed => JmTone.info,
      JmVerificationLevel.emailVerified => JmTone.neutral,
      JmVerificationLevel.none => JmTone.neutral,
    },
    icon: switch (level) {
      JmVerificationLevel.verified => PhosphorIconsFill.sealCheck,
      JmVerificationLevel.detailsReviewed => PhosphorIconsBold.fileText,
      JmVerificationLevel.emailVerified => PhosphorIconsBold.envelopeSimple,
      JmVerificationLevel.none => null,
    },
  );

  /// Always visible on paid placement (product rule 5).
  const new sponsored({this.dense = false, super.key})
    : label = 'Sponsored',
      tone = JmTone.accent,
      icon = PhosphorIconsFill.lightning,
      tooltip = 'This employer paid to promote this listing.',
      premium = false;

  const new newListing({this.dense = false, super.key})
    : label = 'New',
      tone = JmTone.success,
      icon = null,
      tooltip = 'Posted in the last 3 days.',
      premium = false;

  const new premium({required this.label, this.dense = false, super.key})
    : tone = JmTone.primary,
      icon = PhosphorIconsFill.sparkle,
      tooltip = null,
      premium = true;

  final String label;
  final JmTone tone;
  final IconData? icon;
  final String? tooltip;
  final bool premium;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final fg = premium ? Colors.white : jm.toneFg(tone);

    Widget badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: premium ? null : jm.toneBg(tone),
        gradient: premium ? jm.signature : null,
        borderRadius: JmRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: fg),
            SizedBox(width: dense ? 3 : 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: type.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: dense ? 11 : 12,
              ),
            ),
          ),
        ],
      ),
    );

    if (tooltip != null) {
      badge = Tooltip(message: tooltip, child: badge);
    }
    return Semantics(
      label: tooltip == null ? label : '$label. $tooltip',
      excludeSemantics: true,
      child: badge,
    );
  }
}
