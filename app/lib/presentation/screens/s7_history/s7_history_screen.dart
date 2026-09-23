import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ghar_ka_menu/config/di.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/data/mock/mock_household_store.dart';
import 'package:ghar_ka_menu/data/models/day_plan_model.dart';
import 'package:ghar_ka_menu/presentation/bloc/history/history_bloc.dart';
import 'package:ghar_ka_menu/presentation/bloc/history/history_event.dart';
import 'package:ghar_ka_menu/presentation/bloc/history/history_state.dart';
import 'package:ghar_ka_menu/presentation/widgets/app_bottom_nav.dart';
import 'package:google_fonts/google_fonts.dart';

/// S7 History — a read-only 30-day log of past lunches.
/// Reference: `prototype/s7_history/index.html`.
class S7HistoryScreen extends StatelessWidget {
  const S7HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HistoryBloc(repository: getIt())
            ..add(LoadHistory(householdId: MockHouseholdStore.householdId)),
      child: const _S7Body(),
    );
  }
}

class _S7Body extends StatelessWidget {
  const _S7Body();

  void _reload(BuildContext context) {
    context.read<HistoryBloc>().add(
      LoadHistory(householdId: MockHouseholdStore.householdId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: Column(
        children: [
          const _HistoryHeader(),
          Expanded(
            child: BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoaded) {
                  return state.hasNoHistory
                      ? const _EmptyHistory()
                      : _buildList(state.entries);
                }
                if (state is HistoryError) {
                  return _buildError(context, state.message);
                }
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              },
            ),
          ),
          const AppBottomNav(activeIndex: 2),
        ],
      ),
    );
  }

  // `.history-list { padding: 12px; }`
  Widget _buildList(List<DayPlanModel> entries) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _HistoryCard(plan: entries[index]),
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
              onPressed: () => _reload(context),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

/// `.manager-header` / `.manager-title`
class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
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
                    '30-Day History',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  Text(
                    'Past lunch records',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── History Row ─────────────────────────────────────────────────────────────

/// `.history-card`. Read-only — the S7 spec allows vertical scrolling only.
class _HistoryCard extends StatelessWidget {
  final DayPlanModel plan;

  const _HistoryCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
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
                  plan.dishName ?? '',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  plan.historySubtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusBadge(cancelled: plan.wasCancelled),
        ],
      ),
    );
  }
}

/// `.history-badge`
class _StatusBadge extends StatelessWidget {
  final bool cancelled;

  const _StatusBadge({required this.cancelled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: cancelled ? AppColors.dangerLight : AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        cancelled ? 'Cancelled' : 'Served',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: cancelled ? AppColors.danger : AppColors.secondary,
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

/// S7 edge case: the app has just been installed, so no history exists.
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.clockRotateLeft,
              size: 32,
              color: AppColors.border,
            ),
            const SizedBox(height: 12),
            Text(
              'No history yet',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Served and cancelled lunches will show up here.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
