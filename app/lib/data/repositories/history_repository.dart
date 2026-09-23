import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../mock/mock_household_store.dart';
import '../models/day_plan_model.dart';

/// S7 History — the household's past lunch records.
abstract class HistoryRepository {
  /// Day plans in [from]..[to], newest first. Days that were never planned are
  /// not returned: history is a log of records, not a calendar.
  Future<List<DayPlanModel>> fetchHistory({
    required String householdId,
    required DateTime from,
    required DateTime to,
  });
}

abstract interface class HistoryRealtimeRepository {
  Stream<void> watchHistory(String householdId);
}

class SupabaseHistoryRepository
    implements HistoryRepository, HistoryRealtimeRepository {
  SupabaseHistoryRepository(this._supabase);

  final SupabaseClient? _supabase;
  final MockHouseholdStore _store = MockHouseholdStore.instance;

  @override
  Future<List<DayPlanModel>> fetchHistory({
    required String householdId,
    required DateTime from,
    required DateTime to,
  }) async {
    if (_supabase != null) {
      final response = await _supabase
          .from('day_plans')
          .select(
            'id, date, dish_id, status, dishes(name, notes, categories(name))',
          )
          .eq('household_id', householdId)
          .gte('date', from.toIso8601String().substring(0, 10))
          .lte('date', to.toIso8601String().substring(0, 10))
          .not('dish_id', 'is', null)
          .order('date', ascending: false);
      return response.map((row) => DayPlanModel.fromMap(row)).toList();
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    return _store.plansBetween(from, to);
  }

  @override
  Stream<void> watchHistory(String householdId) {
    final supabase = _supabase;
    if (supabase == null) return const Stream<void>.empty();

    final changes = StreamController<void>.broadcast();
    final channel = supabase.channel('history-$householdId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'day_plans',
          callback: (_) => changes.add(null),
        )
        .subscribe();

    changes.onCancel = () async {
      await supabase.removeChannel(channel);
      await changes.close();
    };
    return changes.stream;
  }
}
