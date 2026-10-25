import 'package:drift/drift.dart';

class Habits extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get description => text().nullable()();

  TextColumn get frequency => text()();

  TextColumn get scheduledWeekdays =>
      text().withDefault(const Constant('[]'))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get archivedAt => dateTime().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}