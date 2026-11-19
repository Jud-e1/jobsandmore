import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_avatar.dart';
import 'package:jobsandmore/core/widgets/jm_button.dart';
import 'package:jobsandmore/core/widgets/jm_pressable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum JmTimelineState { done, current, upcoming, stopped }

@immutable
class JmTimelineItem {
  const new({
    required this.title,
    required this.state,
    this.subtitle,
    this.timestamp,
  });

  final String title;
  final JmTimelineState state;
  final String? subtitle;

  /// Pre-formatted, e.g. "12 Mar 2026".
  final String? timestamp;
}

/// Vertical application-status timeline.
class JmTimeline extends StatelessWidget {
  const new({required this.items, super.key});

  final List<JmTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Semantics(
            label:
                '${_stateWord(items[i].state)}: ${items[i].title}'
                '${items[i].timestamp == null ? '' : ', ${items[i].timestamp}'}',
            excludeSemantics: true,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        _Node(state: items[i].state),
                        if (i < items.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: items[i].state == JmTimelineState.done
                                    ? jm.primary
                                    : jm.border,
                                borderRadius: JmRadius.pill,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: JmSpace.x3),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: i < items.length - 1 ? JmSpace.x6 : 0,
                        top: 3,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  items[i].title,
                                  style: type.label.copyWith(
                                    fontSize: 15,
                                    color:
                                        items[i].state ==
                                            JmTimelineState.upcoming
                                        ? jm.textSubtle
                                        : jm.text,
                                  ),
                                ),
                              ),
                              if (items[i].timestamp != null)
                                Text(
                                  items[i].timestamp!,
                                  style: type.caption.copyWith(
                                    color: jm.textSubtle,
                                  ),
                                ),
                            ],
                          ),
                          if (items[i].subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              items[i].subtitle!,
                              style: type.small.copyWith(color: jm.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static String _stateWord(JmTimelineState s) => switch (s) {
    JmTimelineState.done => 'Completed',
    JmTimelineState.current => 'Current stage',
    JmTimelineState.upcoming => 'Upcoming',
    JmTimelineState.stopped => 'Ended',
  };
}

class _Node extends StatelessWidget {
  const new({required this.state});

  final JmTimelineState state;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return switch (state) {
      JmTimelineState.done => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: jm.primary, shape: BoxShape.circle),
        child: Icon(PhosphorIconsBold.check, size: 13, color: jm.onPrimary),
      ),
      JmTimelineState.current => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: jm.primarySoft,
          border: Border.all(color: jm.primary, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: jm.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      JmTimelineState.upcoming => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: jm.surface,
          border: Border.all(color: jm.borderStrong, width: 1.5),
        ),
      ),
      JmTimelineState.stopped => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: jm.surfaceSunken,
          shape: BoxShape.circle,
        ),
        child: Icon(PhosphorIconsBold.minus, size: 13, color: jm.textMuted),
      ),
    };
  }
}

/// Candidate summary shown on an ATS board.
@immutable
class JmCandidateCardData {
  const new({
    required this.id,
    required this.name,
    required this.headline,
    required this.appliedLabel,
    this.avatarUrl,
    this.tags = const [],
    this.unread = false,
  });

  final String id;
  final String name;
  final String headline;
  final String appliedLabel;
  final String? avatarUrl;
  final List<String> tags;
  final bool unread;
}

/// One ATS stage column. Cards are draggable on pointer devices; keyboard
/// and screen-reader users move candidates with the per-card "Move" action.
class JmKanbanColumn extends StatefulWidget {
  const new({
    required this.title,
    required this.color,
    required this.candidates,
    required this.onAccept,
    this.onOpen,
    this.onMoveRequest,
    this.width = 300,
    super.key,
  });

  final String title;
  final Color color;
  final List<JmCandidateCardData> candidates;

  /// Called when a candidate card is dropped on this column.
  final ValueChanged<JmCandidateCardData> onAccept;
  final ValueChanged<JmCandidateCardData>? onOpen;

  /// Accessible alternative to drag-and-drop.
  final ValueChanged<JmCandidateCardData>? onMoveRequest;
  final double width;

  @override
  State<JmKanbanColumn> createState() => _JmKanbanColumnState();
}

class _JmKanbanColumnState extends State<JmKanbanColumn> {
  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return DragTarget<JmCandidateCardData>(
      onWillAcceptWithDetails: (d) =>
          !widget.candidates.any((c) => c.id == d.data.id),
      onAcceptWithDetails: (d) => widget.onAccept(d.data),
      builder: (context, incoming, _) {
        final hovering = incoming.isNotEmpty;
        return AnimatedContainer(
          duration: JmMotion.micro,
          width: widget.width,
          padding: const EdgeInsets.all(JmSpace.x3),
          decoration: BoxDecoration(
            color: hovering ? jm.primarySoft : jm.surfaceAlt,
            borderRadius: JmRadius.cardAll,
            border: Border.all(
              color: hovering ? jm.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                label:
                    '${widget.title}, ${widget.candidates.length} candidates',
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, JmSpace.x3),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: JmSpace.x2),
                      Expanded(child: Text(widget.title, style: type.label)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: jm.surface,
                          borderRadius: JmRadius.pill,
                          border: Border.all(color: jm.border),
                        ),
                        child: Text(
                          '${widget.candidates.length}',
                          style: type.caption.copyWith(
                            color: jm.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.candidates.isEmpty)
                Container(
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: JmRadius.buttonAll,
                    border: Border.all(color: jm.borderStrong),
                  ),
                  child: Text(
                    'Drop candidates here',
                    style: type.small.copyWith(color: jm.textSubtle),
                  ),
                ),
              for (final c in widget.candidates) ...[
                LongPressDraggable<JmCandidateCardData>(
                  data: c,
                  delay: const Duration(milliseconds: 150),
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: widget.width - JmSpace.x6,
                      child: Transform.rotate(
                        angle: 0.03,
                        child: _CandidateCard(c: c, dragging: true),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: _CandidateCard(c: c),
                  ),
                  child: _CandidateCard(
                    c: c,
                    onTap: widget.onOpen == null
                        ? null
                        : () => widget.onOpen!(c),
                    onMove: widget.onMoveRequest == null
                        ? null
                        : () => widget.onMoveRequest!(c),
                  ),
                ),
                const SizedBox(height: JmSpace.x2),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const new({required this.c, this.onTap, this.onMove, this.dragging = false});

  final JmCandidateCardData c;
  final VoidCallback? onTap;
  final VoidCallback? onMove;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return JmPressable(
      onTap: onTap,
      semanticLabel: '${c.name}, ${c.headline}, applied ${c.appliedLabel}',
      scaleOnPress: false,
      builder: (context, s) => AnimatedContainer(
        duration: JmMotion.micro,
        padding: const EdgeInsets.all(JmSpace.x3),
        decoration: BoxDecoration(
          color: jm.surface,
          borderRadius: JmRadius.buttonAll,
          border: Border.all(color: s.hovered ? jm.borderStrong : jm.border),
          boxShadow: dragging
              ? jm.shadowLg
              : (s.hovered ? jm.shadowMd : jm.shadowSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                JmAvatar(name: c.name, imageUrl: c.avatarUrl, size: 32),
                const SizedBox(width: JmSpace.x2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.label,
                      ),
                      Text(
                        c.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.caption.copyWith(color: jm.textMuted),
                      ),
                    ],
                  ),
                ),
                if (c.unread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: jm.info,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (onMove != null)
                  JmIconButton(
                    icon: PhosphorIconsRegular.arrowsLeftRight,
                    label: 'Move ${c.name} to another stage',
                    size: 32,
                    onPressed: onMove,
                  ),
              ],
            ),
            if (c.tags.isNotEmpty) ...[
              const SizedBox(height: JmSpace.x2),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final t in c.tags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: jm.surfaceSunken,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t,
                        style: type.caption.copyWith(
                          color: jm.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: JmSpace.x2),
            Text(
              'Applied ${c.appliedLabel}',
              style: type.caption.copyWith(color: jm.textSubtle, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plan card. Prices and entitlements are passed in from the `plans` table
/// (admins configure them); nothing is hard-coded here.
class JmPricingCard extends StatelessWidget {
  const new({
    required this.name,
    required this.priceLabel,
    required this.features,
    required this.ctaLabel,
    required this.onSelect,
    this.period,
    this.description,
    this.highlighted = false,
    this.highlightLabel,
    this.current = false,
    super.key,
  });

  final String name;
  final String priceLabel;
  final String? period;
  final String? description;
  final List<String> features;
  final String ctaLabel;
  final VoidCallback? onSelect;
  final bool highlighted;
  final String? highlightLabel;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;

    final body = Container(
      padding: const EdgeInsets.all(JmSpace.x6),
      decoration: BoxDecoration(
        color: jm.surface,
        borderRadius: BorderRadius.circular(
          highlighted ? JmRadius.sheet - 2 : JmRadius.sheet,
        ),
        border: highlighted ? null : Border.all(color: jm.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: type.h4)),
              if (highlighted && highlightLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: jm.signature,
                    borderRadius: JmRadius.pill,
                  ),
                  child: Text(
                    highlightLabel!,
                    style: type.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: JmSpace.x2),
            Text(description!, style: type.small.copyWith(color: jm.textMuted)),
          ],
          const SizedBox(height: JmSpace.x6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: priceLabel, style: type.h1),
                if (period != null)
                  TextSpan(
                    text: ' / $period',
                    style: type.body.copyWith(color: jm.textMuted),
                  ),
              ],
            ),
          ),
          const SizedBox(height: JmSpace.x6),
          JmButton(
            label: current ? 'Current plan' : ctaLabel,
            variant: highlighted
                ? JmButtonVariant.primary
                : JmButtonVariant.secondary,
            expand: true,
            onPressed: current ? null : onSelect,
          ),
          const SizedBox(height: JmSpace.x6),
          Divider(height: 1, color: jm.border),
          const SizedBox(height: JmSpace.x4),
          for (final f in features)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: jm.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsBold.check,
                      size: 11,
                      color: jm.onPrimarySoft,
                    ),
                  ),
                  const SizedBox(width: JmSpace.x3),
                  Expanded(
                    child: Text(f, style: type.small.copyWith(color: jm.text)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    return Semantics(
      container: true,
      label: '$name plan, $priceLabel${period == null ? '' : ' per $period'}',
      child: highlighted
          ? Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: jm.signature,
                borderRadius: JmRadius.sheetAll,
                boxShadow: jm.shadowLg,
              ),
              child: body,
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: JmRadius.sheetAll,
                boxShadow: jm.shadowSm,
              ),
              child: body,
            ),
    );
  }
}
