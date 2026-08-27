import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/category_model.dart';

/// Horizontally scrollable category filter used by S3 Assign Dish and
/// S5 Dishes Manager. Mirrors `.category-tabs` / `.cat-tab` in
/// `prototype/styles.css`. The leading "All" tab maps to a null category id.
class CategoryTabsBar extends StatelessWidget {
  final List<CategoryModel> categories;

  /// null selects the "All" tab.
  final String? selectedCategoryId;

  final ValueChanged<String?> onSelected;

  /// false greys out taps while an action is in flight.
  final bool enabled;

  const CategoryTabsBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _CategoryTab(
              label: 'All',
              isActive: selectedCategoryId == null,
              onTap: enabled ? () => onSelected(null) : null,
            ),
            ...categories.map((cat) => _CategoryTab(
              label: cat.name,
              isActive: selectedCategoryId == cat.id,
              onTap: enabled ? () => onSelected(cat.id) : null,
            )),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _CategoryTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.textMain : AppColors.bgApp,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.textMain : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: isActive ? Colors.white : AppColors.textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
