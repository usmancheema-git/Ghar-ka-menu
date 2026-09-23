import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_ka_menu/data/models/day_plan_model.dart';
import 'package:ghar_ka_menu/data/repositories/history_repository.dart';
import 'package:ghar_ka_menu/presentation/bloc/history/history_bloc.dart';
import 'package:ghar_ka_menu/presentation/bloc/history/history_event.dart';
import 'package:ghar_ka_menu/presentation/bloc/history/history_state.dart';

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DayPlanModel _plan(int daysAgo, String name, DayPlanStatus status) {
  final date = _today().subtract(Duration(days: daysAgo));
  return DayPlanModel(
    id: 'plan-$daysAgo',
    date: date,
    dishId: 'd$daysAgo',
    dishName: name,
    categoryName: 'Chawal',
    status: status,
  );
}

class _FakeHistoryRepository implements HistoryRepository {
  bool throws = false;

  List<DayPlanModel> entries = [
    _plan(1, 'Chicken Biryani', DayPlanStatus.cooked),
    _plan(2, 'Karelay Pyaz', DayPlanStatus.cancelled),
  ];

  final List<Map<String, Object?>> calls = [];

  @override
  Future<List<DayPlanModel>> fetchHistory({
    required String householdId,
    required DateTime from,
    required DateTime to,
  }) async {
    calls.add({'householdId': householdId, 'from': from, 'to': to});
    if (throws) throw Exception('offline');
    return entries;
  }
}

void main() {
  late _FakeHistoryRepository repo;

  setUp(() => repo = _FakeHistoryRepository());

  HistoryBloc build() => HistoryBloc(repository: repo);

  test('starts in the initial state', () {
    expect(build().state, isA<HistoryInitial>());
  });

  test('loading emits Loading then Loaded with the records', () async {
    final bloc = build();
    final states = <HistoryState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const LoadHistory(householdId: 'h1'));
    await Future<void>.delayed(Duration.zero);

    expect(states.first, isA<HistoryLoading>());
    final loaded = states.last as HistoryLoaded;
    expect(loaded.entries.length, 2);
    expect(loaded.hasNoHistory, isFalse);

    await sub.cancel();
    await bloc.close();
  });

  test('queries the 30 days before today, ending yesterday', () async {
    final bloc = build();
    bloc.add(const LoadHistory(householdId: 'h1'));
    await Future<void>.delayed(Duration.zero);

    final today = _today();
    expect(repo.calls.single['householdId'], 'h1');
    expect(repo.calls.single['from'], today.subtract(const Duration(days: 30)));
    // Today is still in progress — it belongs to the week plan, not history.
    expect(repo.calls.single['to'], today.subtract(const Duration(days: 1)));

    await bloc.close();
  });

  test('no records reports the empty state, not an error', () async {
    repo.entries = [];
    final bloc = build();
    bloc.add(const LoadHistory(householdId: 'h1'));
    await Future<void>.delayed(Duration.zero);

    final loaded = bloc.state as HistoryLoaded;
    expect(loaded.hasNoHistory, isTrue);

    await bloc.close();
  });

  test('a failed fetch emits an error', () async {
    repo.throws = true;
    final bloc = build();
    bloc.add(const LoadHistory(householdId: 'h1'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state, isA<HistoryError>());
    expect((bloc.state as HistoryError).message, contains('offline'));

    await bloc.close();
  });

  test('reloading after an error recovers', () async {
    repo.throws = true;
    final bloc = build();
    bloc.add(const LoadHistory(householdId: 'h1'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state, isA<HistoryError>());

    repo.throws = false;
    bloc.add(const LoadHistory(householdId: 'h1'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state, isA<HistoryLoaded>());

    await bloc.close();
  });

  group('DayPlanModel history formatting', () {
    test('subtitle reads "d MMMM yyyy · Category" with no leading zero', () {
      final plan = DayPlanModel(
        id: 'p1',
        date: DateTime(2026, 7, 9),
        dishId: 'd1',
        dishName: 'Daal Chawal Combo',
        categoryName: 'Chawal',
        status: DayPlanStatus.cooked,
      );
      expect(plan.historySubtitle, '9 July 2026 · Chawal');
    });

    test('a plan with no category shows the date alone', () {
      final plan = DayPlanModel(
        id: 'p1',
        date: DateTime(2026, 12, 25),
        dishId: 'd1',
        dishName: 'Daal Chawal Combo',
        status: DayPlanStatus.cooked,
      );
      expect(plan.historySubtitle, '25 December 2026');
    });

    test('only a cancelled day counts as cancelled', () {
      expect(_plan(1, 'X', DayPlanStatus.cancelled).wasCancelled, isTrue);
      expect(_plan(1, 'X', DayPlanStatus.cooked).wasCancelled, isFalse);
      // The midnight rollover has not run yet; a past planned day was served.
      expect(_plan(1, 'X', DayPlanStatus.planned).wasCancelled, isFalse);
    });
  });
}
