import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart' as db;
import '../domain/entities/habit_completion.dart';
import '../domain/repository/habit_completion_repository.dart';

class DriftHabitCompletionRepository implements HabitCompletionRepository {
  DriftHabitCompletionRepository(this._database);

  final db.AppDatabase _database;

  static const _uuid = Uuid();

  @override
  Stream<List<HabitCompletion>> watchByDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final nextDay = day.add(const Duration(days: 1));

    final query = _database.select(_database.habitCompletions)
      ..where(
        (table) =>
            table.date.isBiggerOrEqualValue(day) &
            table.date.isSmallerThanValue(nextDay),
      );

    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<void> markCompleted({
    required String habitId,
    required DateTime date,
  }) async {
    final day = DateTime(date.year, date.month, date.day);

    await _database
        .into(_database.habitCompletions)
        .insert(
          db.HabitCompletionsCompanion.insert(
            id: _uuid.v4(),
            habitId: habitId,
            date: day,
            completedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> markIncomplete({
    required String habitId,
    required DateTime date,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    final nextDay = day.add(const Duration(days: 1));

    await (_database.delete(_database.habitCompletions)..where(
          (table) =>
              table.habitId.equals(habitId) &
              table.date.isBiggerOrEqualValue(day) &
              table.date.isSmallerThanValue(nextDay),
        ))
        .go();
  }

  @override
  Future<List<HabitCompletion>> getByHabitId(String habitId) async {
    final query = _database.select(_database.habitCompletions)
      ..where((table) => table.habitId.equals(habitId))
      ..orderBy([(table) => OrderingTerm.asc(table.date)]);

    final rows = await query.get();

    return rows.map(_toEntity).toList();
  }

  HabitCompletion _toEntity(db.HabitCompletion row) {
    return HabitCompletion(
      id: row.id,
      habitId: row.habitId,
      date: row.date,
      completedAt: row.completedAt,
    );
  }
}
