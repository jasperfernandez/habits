// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(habitRepository)
final habitRepositoryProvider = HabitRepositoryProvider._();

final class HabitRepositoryProvider
    extends
        $FunctionalProvider<HabitRepository, HabitRepository, HabitRepository>
    with $Provider<HabitRepository> {
  HabitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitRepositoryHash();

  @$internal
  @override
  $ProviderElement<HabitRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HabitRepository create(Ref ref) {
    return habitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitRepository>(value),
    );
  }
}

String _$habitRepositoryHash() => r'0878495ea494280ba2dfa4a3f50ee94d6f1447e9';

@ProviderFor(habitCompletionRepository)
final habitCompletionRepositoryProvider = HabitCompletionRepositoryProvider._();

final class HabitCompletionRepositoryProvider
    extends
        $FunctionalProvider<
          HabitCompletionRepository,
          HabitCompletionRepository,
          HabitCompletionRepository
        >
    with $Provider<HabitCompletionRepository> {
  HabitCompletionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitCompletionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitCompletionRepositoryHash();

  @$internal
  @override
  $ProviderElement<HabitCompletionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HabitCompletionRepository create(Ref ref) {
    return habitCompletionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitCompletionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitCompletionRepository>(value),
    );
  }
}

String _$habitCompletionRepositoryHash() =>
    r'efd81bfa5a6da7ade8a53d8a025ae831bb718ffb';

@ProviderFor(habitsStream)
final habitsStreamProvider = HabitsStreamProvider._();

final class HabitsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Habit>>,
          List<Habit>,
          Stream<List<Habit>>
        >
    with $FutureModifier<List<Habit>>, $StreamProvider<List<Habit>> {
  HabitsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Habit>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Habit>> create(Ref ref) {
    return habitsStream(ref);
  }
}

String _$habitsStreamHash() => r'cf08333f14201375efe39ca443e6207b73d4198f';

@ProviderFor(completionsForDate)
final completionsForDateProvider = CompletionsForDateFamily._();

final class CompletionsForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitCompletion>>,
          List<HabitCompletion>,
          Stream<List<HabitCompletion>>
        >
    with
        $FutureModifier<List<HabitCompletion>>,
        $StreamProvider<List<HabitCompletion>> {
  CompletionsForDateProvider._({
    required CompletionsForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'completionsForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$completionsForDateHash();

  @override
  String toString() {
    return r'completionsForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<HabitCompletion>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitCompletion>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return completionsForDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CompletionsForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$completionsForDateHash() =>
    r'dc0e5936ad6d6c671077ba4b0bdd9cf1ab6e20ed';

final class CompletionsForDateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<HabitCompletion>>, DateTime> {
  CompletionsForDateFamily._()
    : super(
        retry: null,
        name: r'completionsForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CompletionsForDateProvider call(DateTime date) =>
      CompletionsForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'completionsForDateProvider';
}

@ProviderFor(habitStreak)
final habitStreakProvider = HabitStreakFamily._();

final class HabitStreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  HabitStreakProvider._({
    required HabitStreakFamily super.from,
    required (String, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'habitStreakProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitStreakHash();

  @override
  String toString() {
    return r'habitStreakProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as (String, DateTime);
    return habitStreak(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitStreakProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitStreakHash() => r'e307b39dddd73bd6f70e03027c6df0d93635394b';

final class HabitStreakFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, (String, DateTime)> {
  HabitStreakFamily._()
    : super(
        retry: null,
        name: r'habitStreakProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitStreakProvider call(String habitId, DateTime date) =>
      HabitStreakProvider._(argument: (habitId, date), from: this);

  @override
  String toString() => r'habitStreakProvider';
}
