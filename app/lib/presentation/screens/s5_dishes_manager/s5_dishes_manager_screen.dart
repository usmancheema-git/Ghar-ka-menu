import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_ka_menu/config/di.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/data/mock/mock_household_store.dart';
import 'package:ghar_ka_menu/data/models/dish_model.dart';
import 'package:ghar_ka_menu/presentation/bloc/dishes_manager/dishes_manager_bloc.dart';
import 'package:ghar_ka_menu/presentation/bloc/dishes_manager/dishes_manager_event.dart';
import 'package:ghar_ka_menu/presentation/bloc/dishes_manager/dishes_manager_state.dart';
import 'package:ghar_ka_menu/presentation/widgets/app_bottom_nav.dart';
import 'package:ghar_ka_menu/presentation/widgets/category_tabs_bar.dart';
import 'package:ghar_ka_menu/presentation/widgets/dish_search_field.dart';
import 'package:google_fonts/google_fonts.dart';

/// S5 Dishes Manager — searchable repository of every dish preset.
/// Reference: `prototype/s5_dishes_manager/index.html`.
class S5DishesManagerScreen extends StatelessWidget {
  const S5DishesManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DishesManagerBloc(repository: getIt())
        ..add(LoadDishesManager(householdId: MockHouseholdStore.householdId)),
      child: const _S5Body(),
    );
  }
}

class _S5Body extends StatefulWidget {
  const _S5Body();

  @override
  State<_S5Body> createState() => _S5BodyState();
}

class _S5BodyState extends State<_S5Body> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    context.read<DishesManagerBloc>().add(
      LoadDishesManager(householdId: MockHouseholdStore.householdId),
    );
  }

  /// Opens S6 and reloads the list when it reports a successful save.
  Future<void> _openForm(String route) async {
    final saved = await context.push<bool>(route);
    if (saved == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: BlocConsumer<DishesManagerBloc, DishesManagerState>(
        listenWhen: (previous, current) {
          if (current is! DishesManagerLoaded || current.actionError == null) {
            return false;
          }
          final prevError = previous is DishesManagerLoaded
              ? previous.actionError
              : null;
          return prevError != current.actionError;
        },
        listener: (context, state) {
          if (state is DishesManagerLoaded && state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context, state),
              if (state is DishesManagerLoaded) ...[
                CategoryTabsBar(
                  categories: state.categories,
                  selectedCategoryId: state.selectedCategoryId,
                  onSelected: (categoryId) => context
                      .read<DishesManagerBloc>()
                      .add(FilterManagerByCategory(categoryId)),
                ),
                DishSearchField(
                  controller: _searchCtrl,
                  hintText: 'Search preset database…',
                  onChanged: (q) => context.read<DishesManagerBloc>().add(
                    SearchManagerDishes(q),
                  ),
                ),
                Expanded(child: _buildList(context, state)),
              ] else if (state is DishesManagerError)
                Expanded(child: _buildError(context, state.message))
              else
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              const AppBottomNav(activeIndex: 1),
            ],
          );
        },
      ),
    );
  }

  // `.manager-header`
  Widget _buildHeader(BuildContext context, DishesManagerState state) {
    final loaded = state is DishesManagerLoaded ? state : null;
    final count = loaded?.allDishes.length;

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dishes Database',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  Text(
                    count == null
                        ? 'Loading…'
                        : '$count household preset${count == 1 ? '' : 's'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Planner only — members get a read-only list.
            if (loaded != null && loaded.isPlanner)
              _AddCircleButton(onTap: () => _openForm('/dishes/new')),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, DishesManagerLoaded state) {
    if (state.isDatabaseEmpty) return _buildEmptyDatabase(context, state);
    if (state.filteredDishes.isEmpty) return _buildNoMatches(context);

    // `.manager-list { padding: 12px; }`
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: state.filteredDishes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final dish = state.filteredDishes[index];
        return _ManagerItem(
          dish: dish,
          showActions: state.isPlanner,
          isDeleting: state.deletingDishId == dish.id,
          onTap: () => context.push('/dish/${dish.id}'),
          onEdit: () => _openForm('/dishes/edit/${dish.id}'),
          onDelete: () => _confirmDelete(
            context,
            dish: dish,
            isScheduled: state.scheduledDishIds.contains(dish.id),
          ),
        );
      },
    );
  }

  Widget _buildEmptyDatabase(BuildContext context, DishesManagerLoaded state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.utensils,
              size: 32,
              color: AppColors.border,
            ),
            const SizedBox(height: 12),
            Text(
              'No dishes yet',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              state.isPlanner
                  ? 'Tap + to add your first dish preset.'
                  : 'Your planner has not added any dishes yet.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMatches(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.utensils,
            size: 32,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),
          Text(
            'No dishes found',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different category or search term',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
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
            ElevatedButton(onPressed: _reload, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  /// S5 spec: confirm before deleting. When the dish is on the current week
  /// plan the dialog says so — that day becomes unassigned.
  Future<void> _confirmDelete(
    BuildContext context, {
    required DishModel dish,
    required bool isScheduled,
  }) async {
    final bloc = context.read<DishesManagerBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete this dish?',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
          ),
        ),
        content: Text(
          isScheduled
              ? '${dish.name} is planned in this week. Deleting it will leave '
                    'that day unassigned.'
              : '${dish.name} will be removed from the dishes database.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _ManagerItem.deleteColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(
        DeleteManagerDish(
          dishId: dish.id,
          householdId: MockHouseholdStore.householdId,
        ),
      );
    }
  }
}

// ─── Add Button ──────────────────────────────────────────────────────────────

/// `.btn-add-circle`
class _AddCircleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCircleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.plus,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dish Row ────────────────────────────────────────────────────────────────

/// `.manager-item`
class _ManagerItem extends StatelessWidget {
  final DishModel dish;
  final bool showActions;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManagerItem({
    required this.dish,
    required this.showActions,
    required this.isDeleting,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  /// Delete icon colour, from `prototype/s5_dishes_manager/index.html`.
  static const Color deleteColor = AppColors.danger;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDeleting ? 0.5 : 1,
      child: Material(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isDeleting ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        dish.managerSubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showActions) ...[
                  const SizedBox(width: 10),
                  if (isDeleting)
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: deleteColor,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    _ActionIconButton(
                      icon: FontAwesomeIcons.penToSquare,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 6),
                    _ActionIconButton(
                      icon: FontAwesomeIcons.trashCan,
                      color: deleteColor,
                      borderColor: deleteColor.withValues(alpha: 0.25),
                      onTap: onDelete,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `.action-icon-btn`
class _ActionIconButton extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    this.color = AppColors.textMuted,
    this.borderColor = AppColors.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sits on top of the row's InkWell, so it takes the tap first.
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: FaIcon(icon, size: 12, color: color),
        ),
      ),
    );
  }
}
