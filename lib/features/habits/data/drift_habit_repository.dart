import 'dart:convert';

import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart' as db;
import '../domain/entities/habit.dart';
import '../domain/enums/habit_frequency.dart';
import '../domain/repository/habit_repository.dart';

class DriftHabitRepository implements HabitRepository {
  DriftHabitRepository(this._database);

  final db.AppDatabase _database;

  @override
  Stream<List<Habit>> watchHabits() {
    return (_database.select(_database.habits)..orderBy([
          (table) => OrderingTerm.asc(table.sortOrder),
          (table) => OrderingTerm.asc(table.createdAt),
        ]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Habit?> getById(String id) async {
    final query = _database.select(_database.habits)
      ..where((table) => table.id.equals(id));

    final row = await query.getSingleOrNull();

    return row == null ? null : _toEntity(row);
  }

  @override
  Future<String> create(Habit habit) async {
    await _database.into(_database.habits).insert(_toCompanion(habit));

    return habit.id;
  }

  @override
  Future<void> update(Habit habit) async {
    await (_database.update(
      _database.habits,
    )..where((table) => table.id.equals(habit.id))).write(_toCompanion(habit));
  }

  @override
  Future<void> archive(String id) async {
    await (_database.update(_database.habits)
          ..where((table) => table.id.equals(id)))
        .write(db.HabitsCompanion(archivedAt: Value(DateTime.now())));
  }

  @override
  Future<void> unarchive(String id) async {
    await (_database.update(_database.habits)
          ..where((table) => table.id.equals(id)))
        .write(const db.HabitsCompanion(archivedAt: Value(null)));
  }

  @override
  Future<void> reorderHabits(List<String> habitIds) async {
    await _database.transaction(() async {
      for (var i = 0; i < habitIds.length; i++) {
        await (_database.update(_database.habits)
              ..where((table) => table.id.equals(habitIds[i])))
            .write(db.HabitsCompanion(sortOrder: Value(i)));
      }
    });
  }

  @override
  Future<void> delete(String id) async {
    await (_database.delete(
      _database.habits,
    )..where((table) => table.id.equals(id))).go();
  }

  Habit _toEntity(db.Habit row) {
    return Habit(
      id: row.id,
      name: row.name,
      description: row.description,
      frequency: HabitFrequency.values.byName(row.frequency),
      scheduledWeekdays: (jsonDecode(row.scheduledWeekdays) as List)
          .cast<int>()
          .toSet(),
      createdAt: row.createdAt,
      startDate: row.startDate,
      archivedAt: row.archivedAt,
      sortOrder: row.sortOrder,
    );
  }

  db.HabitsCompanion _toCompanion(Habit habit) {
    return db.HabitsCompanion(
      id: Value(habit.id),
      name: Value(habit.name),
      description: Value(habit.description),
      frequency: Value(habit.frequency.name),
      scheduledWeekdays: Value(
        jsonEncode(habit.scheduledWeekdays.toList()..sort()),
      ),
      createdAt: Value(habit.createdAt),
      startDate: Value(habit.startDate),
      archivedAt: Value(habit.archivedAt),
      sortOrder: Value(habit.sortOrder),
    );
  }
}
