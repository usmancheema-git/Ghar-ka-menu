import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_ka_menu/config/di.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/data/models/day_plan_model.dart';
import 'package:ghar_ka_menu/presentation/bloc/week_plan/week_plan_bloc.dart';
import 'package:ghar_ka_menu/presentation/bloc/week_plan/week_plan_event.dart';
import 'package:ghar_ka_menu/presentation/bloc/week_plan/week_plan_state.dart';
import 'package:ghar_ka_menu/presentation/widgets/app_bottom_nav.dart';

class S2WeekViewScreen extends StatelessWidget {
  const S2WeekViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeekPlanBloc(repository: getIt())..add(LoadWeekPlan()),
      child: const _S2WeekViewBody(),
    );
  }
}

class _S2WeekViewBody extends StatelessWidget {
  const _S2WeekViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: BlocConsumer<WeekPlanBloc, WeekPlanState>(
        listener: (context, state) {
          if (state is WeekPlanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context, state),
              Expanded(child: _buildBody(context, state)),
              const AppBottomNav(activeIndex: 0),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WeekPlanState state) {
    final householdName = state is WeekPlanLoaded ? state.householdName : 'Loading...';
    final isPlanner = state is WeekPlanLoaded && state.userRole == 'planner';

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    householdName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Rolling 7-Day Lunch Plan',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            _RoleBadge(isPlanner: isPlanner),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeekPlanState state) {
    if (state is WeekPlanLoading || state is WeekPlanInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is WeekPlanError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.triangleExclamation, color: AppColors.accent, size: 32),
            const SizedBox(height: 12),
            Text(state.message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<WeekPlanBloc>().add(LoadWeekPlan()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is WeekPlanLoaded) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.plans.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _DayCard(
            plan: state.plans[index],
            isToday: index == 0,
            isPlanner: state.userRole == 'planner',
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}

Future<void> _openAssignDish(BuildContext context, DateTime date) async {
  final key =
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  final assigned = await context.push<bool>('/assign/$key');
  if (assigned == true && context.mounted) {
    context.read<WeekPlanBloc>().add(LoadWeekPlan());
  }
}

// ─── Role Badge ─────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final bool isPlanner;
  const _RoleBadge({required this.isPlanner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPlanner ? AppColors.primaryLight : AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPlanner
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            isPlanner ? FontAwesomeIcons.crown : FontAwesomeIcons.user,
            size: 11,
            color: isPlanner ? AppColors.primary : AppColors.secondary,
          ),
          const SizedBox(width: 5),
          Text(
            isPlanner ? 'Planner' : 'Member',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: isPlanner ? AppColors.primary : AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Day Card ────────────────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  final DayPlanModel plan;
  final bool isToday;
  final bool isPlanner;

  const _DayCard({
    required this.plan,
    required this.isToday,
    required this.isPlanner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? AppColors.primary : AppColors.border,
          width: isToday ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textMain.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: plan.isEmpty ? null : () => context.push('/dish/${plan.dishId}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _buildDateInfo(context),
                const SizedBox(width: 14),
                Expanded(child: _buildDishContent(context)),
                _buildActionButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[plan.date.weekday - 1];
    final dayNum = plan.date.day.toString();

    return SizedBox(
      width: 42,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: isToday ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          Text(
            dayNum,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 22,
              color: isToday ? AppColors.primary : AppColors.textMain,
            ),
          ),
          if (plan.status != null) _buildStatusPill(context, plan.status!),
        ],
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, DayPlanStatus status) {
    Color bg, fg;
    String label;
    switch (status) {
      case DayPlanStatus.planned:
        bg = const Color(0xFFE6F7FF);
        fg = const Color(0xFF1890FF);
        label = 'Planned';
        break;
      case DayPlanStatus.cooked:
        bg = AppColors.secondaryLight;
        fg = AppColors.secondary;
        label = 'Cooked';
        break;
      case DayPlanStatus.cancelled:
        bg = const Color(0xFFFFF1F0);
        fg = const Color(0xFFFF4D4F);
        label = 'Cancelled';
        break;
    }
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _buildDishContent(BuildContext context) {
    if (plan.isEmpty) {
      return Text(
        'Menu not decided yet',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          fontSize: 12.5,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (plan.categoryName != null)
          Text(
            plan.categoryName!.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 9.5,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        Text(
          plan.dishName ?? '',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 14),
        ),
        if (plan.dishNotes != null && plan.dishNotes!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.noteSticky, size: 10, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    plan.dishNotes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (plan.isEmpty && isPlanner) {
      // Empty + Planner: Show orange "+" button → navigates to S3
      return GestureDetector(
        onTap: () => _openAssignDish(context, plan.date),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 14),
        ),
      );
    }

    if (!plan.isEmpty && isPlanner) {
      // Filled + Planner: show ellipsis menu with status options
      return _EllipsisMenu(plan: plan);
    }

    if (!plan.isEmpty && !isPlanner) {
      // Member: show chevron → navigates to dish detail
      return Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const FaIcon(FontAwesomeIcons.chevronRight, color: AppColors.textMuted, size: 12),
      );
    }

    return const SizedBox(width: 34);
  }
}

// ─── Ellipsis Menu ───────────────────────────────────────────────────────────

enum _DayMenuAction { changeDish, planned, cooked, cancelled }

class _EllipsisMenu extends StatelessWidget {
  final DayPlanModel plan;
  const _EllipsisMenu({required this.plan});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_DayMenuAction>(
      icon: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const FaIcon(FontAwesomeIcons.ellipsisVertical, size: 14, color: AppColors.textMuted),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (action) {
        switch (action) {
          case _DayMenuAction.changeDish:
            _openAssignDish(context, plan.date);
          case _DayMenuAction.planned:
            context.read<WeekPlanBloc>().add(
              UpdateDayStatus(planId: plan.id, status: DayPlanStatus.planned),
            );
          case _DayMenuAction.cooked:
            context.read<WeekPlanBloc>().add(
              UpdateDayStatus(planId: plan.id, status: DayPlanStatus.cooked),
            );
          case _DayMenuAction.cancelled:
            context.read<WeekPlanBloc>().add(
              UpdateDayStatus(planId: plan.id, status: DayPlanStatus.cancelled),
            );
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _DayMenuAction.changeDish,
          child: _menuItem(FontAwesomeIcons.utensils, 'Change dish', AppColors.textMain),
        ),
        PopupMenuItem(
          value: _DayMenuAction.planned,
          child: _menuItem(FontAwesomeIcons.calendarCheck, 'Mark Planned', const Color(0xFF1890FF)),
        ),
        PopupMenuItem(
          value: _DayMenuAction.cooked,
          child: _menuItem(FontAwesomeIcons.check, 'Mark Cooked', AppColors.secondary),
        ),
        PopupMenuItem(
          value: _DayMenuAction.cancelled,
          child: _menuItem(FontAwesomeIcons.ban, 'Mark Cancelled', const Color(0xFFFF4D4F)),
        ),
      ],
    );
  }

  Widget _menuItem(FaIconData icon, String label, Color color) {
    return Row(
      children: [
        FaIcon(icon, size: 13, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
