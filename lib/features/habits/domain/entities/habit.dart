import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/habit_frequency.dart';

part 'habit.freezed.dart';

@freezed
abstract class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String name,
    required HabitFrequency frequency,
    required Set<int> scheduledWeekdays,
    required DateTime createdAt,
    required DateTime startDate,
    String? description,
    DateTime? archivedAt,
    @Default(0) int sortOrder,
  }) = _Habit;
}
