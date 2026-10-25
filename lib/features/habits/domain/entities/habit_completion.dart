import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_completion.freezed.dart';

@freezed
abstract class HabitCompletion with _$HabitCompletion {
  const factory HabitCompletion({
    required String id,
    required String habitId,
    required DateTime date,
    required DateTime completedAt,
  }) = _HabitCompletion;
}
