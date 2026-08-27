import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_ka_menu/config/di.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/data/mock/mock_household_store.dart';
import 'package:ghar_ka_menu/data/models/dish_model.dart';
import 'package:ghar_ka_menu/presentation/bloc/assign_dish/assign_dish_bloc.dart';
import 'package:ghar_ka_menu/presentation/bloc/assign_dish/assign_dish_event.dart';
import 'package:ghar_ka_menu/presentation/bloc/assign_dish/assign_dish_state.dart';
import 'package:ghar_ka_menu/presentation/widgets/category_tabs_bar.dart';
import 'package:ghar_ka_menu/presentation/widgets/dish_search_field.dart';
import 'package:ghar_ka_menu/presentation/widgets/screen_header_back.dart';
import 'package:google_fonts/google_fonts.dart';

class S3AssignDishScreen extends StatelessWidget {
  final String date; // 'yyyy-MM-dd' passed via route param

  const S3AssignDishScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssignDishBloc(repository: getIt())
        ..add(const LoadAssignDishData(
          householdId: MockHouseholdStore.householdId,
        )),
      child: _S3Body(date: date),
    );
  }
}

class _S3Body extends StatefulWidget {
  final String date;
  const _S3Body({required this.date});

  @override
  State<_S3Body> createState() => _S3BodyState();
}

class _S3BodyState extends State<_S3Body> {
  final TextEditingController _searchCtrl = TextEditingController();

  late final DateTime _parsedDate;
  late final String _formattedDate;

  @override
  void initState() {
    super.initState();
    _parsedDate = DateTime.tryParse(widget.date) ?? DateTime.now();
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    _formattedDate =
        '${weekdays[_parsedDate.weekday - 1]}, ${_parsedDate.day} ${months[_parsedDate.month - 1]}';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssignDishBloc, AssignDishState>(
      listenWhen: (previous, current) {
        if (current is AssignDishSuccess || current is AssignDishError) return true;
        if (current is AssignDishLoaded && current.actionError != null) {
          final prevError = previous is AssignDishLoaded ? previous.actionError : null;
          return prevError != current.actionError;
        }
        return false;
      },
      listener: (context, state) {
        if (state is AssignDishSuccess) {
          if (context.canPop()) {
            context.pop(true);
          } else {
            context.go('/home');
          }
        } else if (state is AssignDishError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        } else if (state is AssignDishLoaded && state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.actionError!), backgroundColor: Colors.redAccent),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgApp,
          body: SafeArea(
            child: Column(
              children: [
                ScreenHeaderBack(
                  title: 'Assign Lunch',
                  subtitle: _formattedDate,
                ),
                if (state is AssignDishLoaded) ...[
                  _buildCategoryTabs(context, state),
                  _buildSearchBar(context, enabled: !state.isAssigning),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildDishList(context, state),
                        if (state.isAssigning)
                          const ColoredBox(
                            color: Color(0x66FAF8F5),
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else if (state is AssignDishLoading || state is AssignDishInitial)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else if (state is AssignDishError)
                  Expanded(child: _buildError(context, state.message)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTabs(BuildContext context, AssignDishLoaded state) {
    return CategoryTabsBar(
      categories: state.categories,
      selectedCategoryId: state.selectedCategoryId,
      enabled: !state.isAssigning,
      onSelected: (categoryId) =>
          context.read<AssignDishBloc>().add(FilterByCategory(categoryId)),
    );
  }

  Widget _buildSearchBar(BuildContext context, {required bool enabled}) {
    return DishSearchField(
      controller: _searchCtrl,
      hintText: 'Search Pakistani dishes…',
      enabled: enabled,
      onChanged: (q) => context.read<AssignDishBloc>().add(SearchDishes(q)),
    );
  }

  Widget _buildDishList(BuildContext context, AssignDishLoaded state) {
    if (state.allDishes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.utensils, size: 32, color: AppColors.border),
              const SizedBox(height: 12),
              Text(
                'No dishes yet',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Add dishes from the Dishes tab, then come back to assign lunch.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.filteredDishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.utensils, size: 32, color: AppColors.border),
            const SizedBox(height: 12),
            Text('No dishes found', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Try a different category or search term',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: state.filteredDishes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final dish = state.filteredDishes[index];
        final isRepeat = state.alreadyPlannedDishIds.contains(dish.id);
        return _DishCard(
          dish: dish,
          isRepeat: isRepeat,
          onTap: state.isAssigning
              ? null
              : () {
                  context.read<AssignDishBloc>().add(AssignDishToDay(
                    dishId: dish.id,
                    householdId: MockHouseholdStore.householdId,
                    date: _parsedDate,
                  ));
                },
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(FontAwesomeIcons.triangleExclamation, color: AppColors.accent, size: 32),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<AssignDishBloc>().add(const LoadAssignDishData(
              householdId: MockHouseholdStore.householdId,
            )),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  final DishModel dish;
  final bool isRepeat;
  final VoidCallback? onTap;

  const _DishCard({
    required this.dish,
    required this.isRepeat,
    required this.onTap,
  });

  static const Color _repeatBg = Color(0xFFFFFBE6);
  static const Color _repeatBorder = Color(0xFFFFE58F);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
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
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 10, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          dish.lastCookedLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (isRepeat) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _repeatBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _repeatBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.triangleExclamation,
                              size: 9,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'is hafte ban chuki hai',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bgApp,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  dish.categoryName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
