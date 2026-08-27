import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_ka_menu/config/di.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/data/mock/mock_household_store.dart';
import 'package:ghar_ka_menu/data/models/category_model.dart';
import 'package:ghar_ka_menu/presentation/bloc/dish_form/dish_form_bloc.dart';
import 'package:ghar_ka_menu/presentation/bloc/dish_form/dish_form_event.dart';
import 'package:ghar_ka_menu/presentation/bloc/dish_form/dish_form_state.dart';
import 'package:ghar_ka_menu/presentation/widgets/screen_header_back.dart';
import 'package:google_fonts/google_fonts.dart';

/// S6 Add / Edit Dish — planner-only dish preset form.
/// Reference: `prototype/s6_add_edit_dish/index.html`.
class S6AddEditDishScreen extends StatelessWidget {
  /// null opens an empty form (Add mode); an id opens it pre-filled (Edit mode).
  final String? dishId;

  const S6AddEditDishScreen({super.key, this.dishId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DishFormBloc(repository: getIt())
        ..add(LoadDishForm(
          householdId: MockHouseholdStore.householdId,
          dishId: dishId,
        )),
      child: _S6Body(dishId: dishId),
    );
  }
}

class _S6Body extends StatefulWidget {
  final String? dishId;

  const _S6Body({required this.dishId});

  @override
  State<_S6Body> createState() => _S6BodyState();
}

class _S6BodyState extends State<_S6Body> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _ingredientsCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  String? _categoryId;

  /// Guards against re-filling the fields the planner is editing.
  bool _hydrated = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ingredientsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _hydrate(DishFormReady state) {
    _hydrated = true;
    final dish = state.dish;
    if (dish == null) return;
    _nameCtrl.text = dish.name;
    _ingredientsCtrl.text = dish.ingredientsText ?? '';
    _notesCtrl.text = dish.notes ?? '';
    _categoryId = dish.categoryId;
  }

  void _submit() {
    context.read<DishFormBloc>().add(SubmitDishForm(
      householdId: MockHouseholdStore.householdId,
      name: _nameCtrl.text,
      categoryId: _categoryId,
      ingredientsText: _ingredientsCtrl.text,
      notes: _notesCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DishFormBloc, DishFormState>(
      listenWhen: (previous, current) =>
          current is DishFormSaved ||
          (current is DishFormReady && !_hydrated) ||
          (current is DishFormReady && current.submitError != null),
      listener: (context, state) {
        if (state is DishFormSaved) {
          // S5 reloads its list when it gets `true` back.
          if (context.canPop()) {
            context.pop(true);
          } else {
            context.go('/dishes');
          }
          return;
        }
        if (state is DishFormReady) {
          if (!_hydrated) setState(() => _hydrate(state));
          if (state.submitError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.submitError!),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final ready = state is DishFormReady ? state : null;

        return Scaffold(
          // `.form-screen { background: #FFF; }`
          backgroundColor: AppColors.bgCard,
          body: SafeArea(
            child: Column(
              children: [
                ScreenHeaderBack(
                  title: ready?.title ??
                      (widget.dishId == null ? 'Add New Dish' : 'Edit Preset Dish'),
                  fallbackRoute: '/dishes',
                ),
                if (ready != null) ...[
                  Expanded(child: _buildForm(context, ready)),
                  _buildFooter(context, ready),
                ] else if (state is DishFormError)
                  Expanded(child: _buildError(context, state.message))
                else
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // `.form-body { padding: 16px; }`
  Widget _buildForm(BuildContext context, DishFormReady state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormGroup(
            label: 'Dish Name',
            isRequired: true,
            errorText: state.nameError,
            child: _FormTextField(
              controller: _nameCtrl,
              hintText: 'e.g., Aloo Qeema',
              enabled: !state.isSubmitting,
              hasError: state.nameError != null,
            ),
          ),
          _FormGroup(
            label: 'Category',
            isRequired: true,
            errorText: state.categoryError,
            child: _CategoryDropdown(
              categories: state.categories,
              value: _categoryId,
              enabled: !state.isSubmitting,
              hasError: state.categoryError != null,
              onChanged: (id) => setState(() => _categoryId = id),
            ),
          ),
          _FormGroup(
            label: 'Ingredients',
            isOptional: true,
            child: _FormTextField(
              controller: _ingredientsCtrl,
              hintText: 'e.g., Chicken, Tomatoes, Onions, Spices…',
              enabled: !state.isSubmitting,
              maxLines: 3,
            ),
          ),
          _FormGroup(
            label: 'Planner Notes',
            isOptional: true,
            child: _FormTextField(
              controller: _notesCtrl,
              hintText: 'e.g., Marinate overnight. Serve with Naan.',
              enabled: !state.isSubmitting,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  // `.form-footer`
  Widget _buildFooter(BuildContext context, DishFormReady state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: state.isSubmitting
          ? ElevatedButton(
              onPressed: null,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          : ElevatedButton.icon(
              onPressed: _submit,
              icon: const FaIcon(FontAwesomeIcons.circleCheck, size: 15),
              label: const Text('Save Dish Preset'),
            ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: AppColors.accent,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<DishFormBloc>().add(LoadDishForm(
                householdId: MockHouseholdStore.householdId,
                dishId: widget.dishId,
              )),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form Group ──────────────────────────────────────────────────────────────

/// `.form-group` + `.form-label`
class _FormGroup extends StatelessWidget {
  final String label;
  final bool isRequired;
  final bool isOptional;
  final String? errorText;
  final Widget child;

  const _FormGroup({
    required this.label,
    this.isRequired = false,
    this.isOptional = false,
    this.errorText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
                letterSpacing: 0.525,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                if (isOptional)
                  TextSpan(
                    text: ' (optional)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      letterSpacing: 0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          child,
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 2),
              child: Text(
                errorText!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Inputs ──────────────────────────────────────────────────────────────────

/// `.form-input`
class _FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final bool hasError;
  final int maxLines;

  const _FormTextField({
    required this.controller,
    required this.hintText,
    required this.enabled,
    this.hasError = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: 1.5),
        );

    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppColors.textMain),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.bgCard,
        isDense: true,
        // `.form-input { padding: 10px 14px; }`
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: border(hasError ? errorColor : AppColors.border),
        enabledBorder: border(hasError ? errorColor : AppColors.border),
        focusedBorder: border(hasError ? errorColor : AppColors.primary),
      ),
    );
  }
}

/// `.form-input` rendered as a `<select>`.
class _CategoryDropdown extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? value;
  final bool enabled;
  final bool hasError;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({
    required this.categories,
    required this.value,
    required this.enabled,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? errorColor : AppColors.border,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(16),
          icon: const FaIcon(
            FontAwesomeIcons.chevronDown,
            size: 12,
            color: AppColors.textMuted,
          ),
          hint: Text(
            'Select a category',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppColors.textMuted,
            ),
          ),
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppColors.textMain),
          onChanged: enabled ? onChanged : null,
          items: [
            for (final category in categories)
              DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              ),
          ],
        ),
      ),
    );
  }
}
