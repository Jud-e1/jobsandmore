import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/responsive/breakpoints.dart';
import 'package:jobsandmore/core/widgets/jm_brand.dart';
import 'package:jobsandmore/core/widgets/jm_button.dart';
import 'package:jobsandmore/core/widgets/jm_pressable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Values captured by the hero search bar.
@immutable
class JmSearchQuery {
  const new({this.keyword = '', this.location, this.jobType, this.experience});

  final String keyword;
  final String? location;
  final String? jobType;
  final String? experience;

  JmSearchQuery copyWith({
    String? keyword,
    String? Function()? location,
    String? Function()? jobType,
    String? Function()? experience,
  }) => JmSearchQuery(
    keyword: keyword ?? this.keyword,
    location: location != null ? location() : this.location,
    jobType: jobType != null ? jobType() : this.jobType,
    experience: experience != null ? experience() : this.experience,
  );
}

/// Option lists come from the taxonomy tables, never hard-coded in screens.
@immutable
class JmSearchOptions {
  const new({
    required this.locations,
    required this.jobTypes,
    required this.experienceLevels,
  });

  final List<String> locations;
  final List<String> jobTypes;
  final List<String> experienceLevels;
}

/// Hero search: a frosted glass panel with keyword, location, job type and
/// experience. Lays out as a single row on desktop and stacks on mobile.
class JmHeroSearchBar extends StatefulWidget {
  const new({
    required this.options,
    required this.onSearch,
    this.initial = const JmSearchQuery(),
    super.key,
  });

  final JmSearchOptions options;
  final ValueChanged<JmSearchQuery> onSearch;
  final JmSearchQuery initial;

  @override
  State<JmHeroSearchBar> createState() => _JmHeroSearchBarState();
}

class _JmHeroSearchBarState extends State<JmHeroSearchBar> {
  late JmSearchQuery _q = widget.initial;
  late final _keyword = TextEditingController(text: widget.initial.keyword);

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  void _submit() => widget.onSearch(_q.copyWith(keyword: _keyword.text.trim()));

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;

    final keyword = _HeroCell(
      icon: PhosphorIconsRegular.magnifyingGlass,
      label: 'What',
      child: TextField(
        controller: _keyword,
        onSubmitted: (_) => _submit(),
        textInputAction: TextInputAction.search,
        style: type.body.copyWith(color: jm.text, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: 'Job title, skill or company',
          hintStyle: type.body.copyWith(color: jm.textSubtle),
        ),
      ),
    );

    final location = _HeroSelect(
      icon: PhosphorIconsRegular.mapPin,
      label: 'Where',
      hint: 'Any state',
      value: _q.location,
      options: widget.options.locations,
      onChanged: (v) => setState(() => _q = _q.copyWith(location: () => v)),
    );
    final jobType = _HeroSelect(
      icon: PhosphorIconsRegular.briefcase,
      label: 'Job type',
      hint: 'Any type',
      value: _q.jobType,
      options: widget.options.jobTypes,
      onChanged: (v) => setState(() => _q = _q.copyWith(jobType: () => v)),
    );
    final experience = _HeroSelect(
      icon: PhosphorIconsRegular.chartLineUp,
      label: 'Experience',
      hint: 'Any level',
      value: _q.experience,
      options: widget.options.experienceLevels,
      onChanged: (v) => setState(() => _q = _q.copyWith(experience: () => v)),
    );

    return Semantics(
      container: true,
      label: 'Job search',
      child: JmGlass(
        padding: const EdgeInsets.all(JmSpace.x2),
        child: JmResponsive(
          builder: (context, size) {
            if (size.isDesktop) {
              Widget divider() =>
                  Container(width: 1, height: 36, color: jm.border);
              return Row(
                children: [
                  Expanded(flex: 5, child: keyword),
                  divider(),
                  Expanded(flex: 3, child: location),
                  divider(),
                  Expanded(flex: 3, child: jobType),
                  divider(),
                  Expanded(flex: 3, child: experience),
                  const SizedBox(width: JmSpace.x2),
                  JmButton(
                    label: 'Search jobs',
                    leading: PhosphorIconsBold.magnifyingGlass,
                    size: JmButtonSize.lg,
                    onPressed: _submit,
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                keyword,
                Divider(height: 1, color: jm.border),
                location,
                Divider(height: 1, color: jm.border),
                if (size.isTablet)
                  Row(
                    children: [
                      Expanded(child: jobType),
                      Container(width: 1, height: 36, color: jm.border),
                      Expanded(child: experience),
                    ],
                  )
                else ...[
                  jobType,
                  Divider(height: 1, color: jm.border),
                  experience,
                ],
                const SizedBox(height: JmSpace.x2),
                JmButton(
                  label: 'Search jobs',
                  leading: PhosphorIconsBold.magnifyingGlass,
                  size: JmButtonSize.lg,
                  expand: true,
                  haptic: true,
                  onPressed: _submit,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroCell extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: JmSpace.x4,
        vertical: JmSpace.x3,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: jm.primary),
          const SizedBox(width: JmSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: context.type.overline.copyWith(
                    color: jm.textSubtle,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _HeroSelect extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(jm.surface),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: JmRadius.cardAll),
        ),
        maximumSize: const WidgetStatePropertyAll(Size(320, 360)),
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () => onChanged(null),
          child: Text(hint, style: type.body.copyWith(color: jm.textMuted)),
        ),
        for (final o in options)
          MenuItemButton(
            onPressed: () => onChanged(o),
            trailingIcon: o == value
                ? Icon(PhosphorIconsBold.check, size: 16, color: jm.primary)
                : null,
            child: Text(o, style: type.body.copyWith(color: jm.text)),
          ),
      ],
      builder: (context, controller, _) => JmPressable(
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        semanticLabel: '$label: ${value ?? hint}',
        scaleOnPress: false,
        focusRadius: JmRadius.cardAll,
        builder: (context, s) => AnimatedContainer(
          duration: JmMotion.micro,
          decoration: BoxDecoration(
            color: s.hovered ? jm.surface.withValues(alpha: 0.6) : null,
            borderRadius: JmRadius.cardAll,
          ),
          child: _HeroCell(
            icon: icon,
            label: label,
            trailing: Icon(
              PhosphorIconsRegular.caretDown,
              size: 16,
              color: jm.textSubtle,
            ),
            child: Text(
              value ?? hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: type.body.copyWith(
                color: value == null ? jm.textSubtle : jm.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact pill search for app bars and list headers.
class JmSearchBar extends StatelessWidget {
  const new({
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.activeFilters = 0,
    super.key,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final int activeFilters;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: jm.isDark ? jm.surfaceSunken : jm.surface,
        borderRadius: JmRadius.pill,
        border: Border.all(color: jm.border),
        boxShadow: jm.shadowSm,
      ),
      child: Row(
        children: [
          const SizedBox(width: JmSpace.x4),
          Icon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 20,
            color: jm.textSubtle,
          ),
          const SizedBox(width: JmSpace.x3),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: type.body.copyWith(color: jm.text),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hint,
                hintStyle: type.body.copyWith(color: jm.textSubtle),
              ),
            ),
          ),
          if (onFilterTap != null)
            Padding(
              padding: const EdgeInsets.all(4),
              child: JmPressable(
                onTap: onFilterTap,
                semanticLabel: activeFilters == 0
                    ? 'Filters'
                    : 'Filters, $activeFilters active',
                builder: (context, s) => AnimatedContainer(
                  duration: JmMotion.micro,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: activeFilters > 0
                        ? jm.primarySoft
                        : (s.hovered ? jm.surfaceSunken : jm.surfaceAlt),
                    borderRadius: JmRadius.pill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsRegular.slidersHorizontal,
                        size: 18,
                        color: activeFilters > 0 ? jm.onPrimarySoft : jm.text,
                      ),
                      if (activeFilters > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '$activeFilters',
                          style: type.label.copyWith(color: jm.onPrimarySoft),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: JmSpace.x4),
        ],
      ),
    );
  }
}
