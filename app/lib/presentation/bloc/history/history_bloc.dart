import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/history_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _repository;
  StreamSubscription<void>? _historySubscription;

  /// S7 spec: "Queries `day_plans` where date is in the past 30 days."
  static const int windowDays = 30;

  HistoryBloc({required HistoryRepository repository})
    // ignore: prefer_initializing_formals
    : _repository = repository,
      super(HistoryInitial()) {
    on<LoadHistory>(_onLoad);
    on<ReloadHistory>(_onReload);
  }

  Future<void> _onLoad(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final today = _today();
      final entries = await _repository.fetchHistory(
        householdId: event.householdId,
        from: today.subtract(const Duration(days: windowDays)),
        // Today is still in progress, so it belongs to the week plan, not here.
        to: today.subtract(const Duration(days: 1)),
      );
      emit(HistoryLoaded(entries));
      await _historySubscription?.cancel();
      final realtimeRepository = _repository is HistoryRealtimeRepository
          ? _repository as HistoryRealtimeRepository
          : null;
      if (realtimeRepository != null) {
        _historySubscription = realtimeRepository
            .watchHistory(event.householdId)
            .listen((_) => add(ReloadHistory(householdId: event.householdId)));
      }
    } catch (e) {
      emit(HistoryError('Could not load the history: ${e.toString()}'));
    }
  }

  Future<void> _onReload(ReloadHistory event, Emitter<HistoryState> emit) =>
      _onLoad(LoadHistory(householdId: event.householdId), emit);

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Future<void> close() async {
    await _historySubscription?.cancel();
    return super.close();
  }
}
