import 'package:drift/drift.dart';

import 'habits_table.dart';

class HabitCompletions extends Table {
  TextColumn get id => text()();

  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {habitId, date},
  ];
}
