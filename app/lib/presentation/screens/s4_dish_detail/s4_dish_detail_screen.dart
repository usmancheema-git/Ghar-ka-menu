import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ghar_ka_menu/config/di.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/data/mock/mock_household_store.dart';
import 'package:ghar_ka_menu/data/models/dish_model.dart';
import 'package:ghar_ka_menu/presentation/bloc/dish_detail/dish_detail_bloc.dart';
import 'package:ghar_ka_menu/presentation/bloc/dish_detail/dish_detail_event.dart';
import 'package:ghar_ka_menu/presentation/bloc/dish_detail/dish_detail_state.dart';
import 'package:ghar_ka_menu/presentation/widgets/screen_header_back.dart';
import 'package:google_fonts/google_fonts.dart';

/// S4 Dish Profile — read-only view of a single dish.
/// Reference: `prototype/s4_dish_detail/index.html`.
class S4DishDetailScreen extends StatelessWidget {
  final String dishId; // passed via route param `/dish/:id`

  const S4DishDetailScreen({super.key, required this.dishId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DishDetailBloc(repository: getIt())
        ..add(LoadDishDetail(
          dishId: dishId,
          householdId: MockHouseholdStore.householdId,
        )),
      child: _S4Body(dishId: dishId),
    );
  }
}

class _S4Body extends StatelessWidget {
  final String dishId;

  const _S4Body({required this.dishId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // `.dish-detail-screen { background: #FFF; }`
      backgroundColor: AppColors.bgCard,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeaderBack(title: 'Dish Profile'),
            Expanded(
              child: BlocBuilder<DishDetailBloc, DishDetailState>(
                builder: (context, state) {
                  if (state is DishDetailLoaded) {
                    return _buildContent(context, state.dish);
                  }
                  if (state is DishDetailError) {
                    return _buildError(context, state.message);
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DishModel dish) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CoverBand(categoryName: dish.categoryName),
          Padding(
            // `.detail-body { padding: 18px 16px; }`
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 6),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _StatBox(
                          value: dish.lastCookedStatLabel,
                          label: 'Last Cooked',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatBox(
                          value: dish.timesCookedLabel,
                          label: 'Times Cooked',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _InfoBlock(title: 'Ingredients', text: dish.ingredientsText),
                const SizedBox(height: 16),
                _InfoBlock(title: 'Planner Notes', text: dish.notes),
              ],
            ),
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
            ElevatedButton(
              onPressed: () => context.read<DishDetailBloc>().add(LoadDishDetail(
                dishId: dishId,
                householdId: MockHouseholdStore.householdId,
              )),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cover Band ──────────────────────────────────────────────────────────────

class _CoverBand extends StatelessWidget {
  final String categoryName;

  const _CoverBand({required this.categoryName});

  /// `.detail-header-cover` gradient end stop, from `prototype/styles.css`.
  static const Color _gradientEnd = Color(0xFFFFEAE6);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      alignment: Alignment.bottomLeft,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, _gradientEnd],
        ),
      ),
      child: categoryName.isEmpty
          ? const SizedBox.shrink()
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categoryName.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.48,
                ),
              ),
            ),
    );
  }
}

// ─── Stat Box ────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Information Block ───────────────────────────────────────────────────────

class _InfoBlock extends StatelessWidget {
  final String title;
  final String? text;

  const _InfoBlock({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final value = text?.trim() ?? '';
    final isMissing = value.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 6),
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
          ),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
              letterSpacing: 0.65,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _DashedBox(
          child: Text(
            isMissing ? 'None provided' : value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.5,
              color: isMissing ? AppColors.textMuted : AppColors.textMain,
              fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}

/// `.detail-text` — filled panel with a 1px dashed border.
class _DashedBox extends StatelessWidget {
  final Widget child;

  const _DashedBox({required this.child});

  static const double _radius = 16; // Radius Medium

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(radius: _radius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgApp,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double radius;

  const _DashedBorderPainter({required this.radius});

  static const Color _color = AppColors.border;
  static const double _strokeWidth = 1;
  static const double _dashLength = 4;
  static const double _gapLength = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + _dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
