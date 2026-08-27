import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Real-time search field used by S3 Assign Dish and S5 Dishes Manager.
/// Mirrors `.search-bar-container` / `.search-input` in `prototype/styles.css`.
class DishSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const DishSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgCard,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textMain),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.bgCard,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 13, color: AppColors.textMuted),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
