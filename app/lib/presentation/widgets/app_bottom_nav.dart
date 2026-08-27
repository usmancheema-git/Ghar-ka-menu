import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

/// Persistent bottom navigation. `docs/NAVIGATION.md`: shown on S2, S7, S5, S8.
/// Mirrors `.bottom-nav` / `.nav-item` in `prototype/styles.css`.
class AppBottomNav extends StatelessWidget {
  /// Index into [items] — 0 Week Plan, 1 Dishes, 2 History, 3 Settings.
  final int activeIndex;

  const AppBottomNav({super.key, required this.activeIndex});

  static const items = [
    (icon: FontAwesomeIcons.calendarDays, label: 'Week Plan', route: '/home'),
    (icon: FontAwesomeIcons.utensils, label: 'Dishes', route: '/dishes'),
    (icon: FontAwesomeIcons.clockRotateLeft, label: 'History', route: '/history'),
    (icon: FontAwesomeIcons.sliders, label: 'Settings', route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isActive = i == activeIndex;
            return Expanded(
              child: InkWell(
                onTap: () {
                  if (!isActive) context.go(item.route);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        item.icon,
                        size: 18,
                        color: isActive ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: isActive ? AppColors.primary : AppColors.textMuted,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
