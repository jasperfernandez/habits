// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HabitsController)
final habitsControllerProvider = HabitsControllerProvider._();

final class HabitsControllerProvider
    extends $StreamNotifierProvider<HabitsController, List<Habit>> {
  HabitsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitsControllerHash();

  @$internal
  @override
  HabitsController create() => HabitsController();
}

String _$habitsControllerHash() => r'e9a31312720ae287edb853d752b80c9d105802dc';

abstract class _$HabitsController extends $StreamNotifier<List<Habit>> {
  Stream<List<Habit>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Habit>>, List<Habit>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Habit>>, List<Habit>>,
              AsyncValue<List<Habit>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
