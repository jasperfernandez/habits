import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_color_scheme.dart';
import '../../application/controllers/habits_controller.dart';
import '../../application/providers/habit_providers.dart';
import '../../application/services/streak_calculator.dart';
import '../../domain/entities/habit.dart';
import '../../domain/enums/habit_frequency.dart';
import '../widgets/daily_progress_header.dart';
import '../widgets/greeting_header.dart';
import '../widgets/habit_card.dart';
import '../../../settings/application/settings_controller.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  bool get _isViewingToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _selectedDate == today;
  }

  Future<void> _toggleHabit({
    required String habitId,
    required bool isCurrentlyCompleted,
    required int completedCount,
    required int totalCount,
  }) async {
    await ref
        .read(habitsControllerProvider.notifier)
        .toggleCompletion(
          habitId: habitId,
          date: _selectedDate,
          isCurrentlyCompleted: isCurrentlyCompleted,
        );

    if (!isCurrentlyCompleted &&
        completedCount + 1 >= totalCount &&
        totalCount > 0 &&
        mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 All habits completed for today! Amazing work!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _openAddHabitSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddHabitBottomSheet(
        onSave: (habit) async {
          await ref.read(habitsControllerProvider.notifier).create(habit);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Habit "${habit.name}" created!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsControllerProvider);
    final completionsAsync = ref.watch(
      completionsForDateProvider(_selectedDate),
    );
    final userSettings = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: GreetingHeader(name: userSettings.userName ?? 'Friend'),
        actions: [
          if (!_isViewingToday)
            TextButton(
              onPressed: _goToToday,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Today'),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: habitsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load habits: $error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(habitsControllerProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (allHabits) {
            return completionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, _) =>
                  Center(child: Text('Error loading completions: $error')),
              data: (completions) {
                // Filter active habits scheduled for selected date
                final activeHabits = allHabits
                    .where((h) => h.archivedAt == null)
                    .toList();

                final todayScheduledHabits = activeHabits
                    .where((h) => h.isScheduledOn(_selectedDate))
                    .toList();

                final completedHabitIds = completions
                    .map((c) => c.habitId)
                    .toSet();

                final pendingHabits = todayScheduledHabits
                    .where((h) => !completedHabitIds.contains(h.id))
                    .toList();

                final completedHabits = todayScheduledHabits
                    .where((h) => completedHabitIds.contains(h.id))
                    .toList();

                final totalCount = todayScheduledHabits.length;
                final completedCount = completedHabits.length;

                return CustomScrollView(
                  slivers: [
                    // Daily progress header
                    SliverToBoxAdapter(
                      child: DailyProgressHeader(
                        date: _selectedDate,
                        completedCount: completedCount,
                        totalCount: totalCount,
                        onPreviousDay: _goToPreviousDay,
                        onNextDay: _goToNextDay,
                        onDateTap: _goToToday,
                      ),
                    ),

                    // Empty states
                    if (activeHabits.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyStateView(
                          icon: Icons.spa_outlined,
                          title: 'No habits yet',
                          message:
                              'Create your first habit to start building positive daily routines.',
                          buttonText: 'Create Habit',
                          onPressed: () => _openAddHabitSheet(context),
                        ),
                      )
                    else if (todayScheduledHabits.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyStateView(
                          icon: Icons.wb_sunny_outlined,
                          title: 'All clear for today',
                          message:
                              'No habits are scheduled for this date. Enjoy your rest day or add a new habit!',
                          buttonText: 'Add Habit',
                          onPressed: () => _openAddHabitSheet(context),
                        ),
                      )
                    else ...[
                      // Pending Habits section
                      if (pendingHabits.isNotEmpty) ...[
                        if (completedHabits.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                              child: Text(
                                'TO DO (${pendingHabits.length})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final habit = pendingHabits[index];
                            return HabitCard(
                              key: ValueKey(habit.id),
                              habit: habit,
                              isCompleted: false,
                              date: _selectedDate,
                              onToggle: () {
                                _toggleHabit(
                                  habitId: habit.id,
                                  isCurrentlyCompleted: false,
                                  completedCount: completedCount,
                                  totalCount: totalCount,
                                );
                              },
                            );
                          }, childCount: pendingHabits.length),
                        ),
                      ],

                      // Completed Habits section
                      if (completedHabits.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                            child: Text(
                              'COMPLETED (${completedHabits.length})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final habit = completedHabits[index];
                            return HabitCard(
                              key: ValueKey(habit.id),
                              habit: habit,
                              isCompleted: true,
                              date: _selectedDate,
                              onToggle: () {
                                _toggleHabit(
                                  habitId: habit.id,
                                  isCurrentlyCompleted: true,
                                  completedCount: completedCount,
                                  totalCount: totalCount,
                                );
                              },
                            );
                          }, childCount: completedHabits.length),
                        ),
                      ],

                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddHabitBottomSheet extends StatefulWidget {
  const _AddHabitBottomSheet({required this.onSave});

  final Future<void> Function(Habit habit) onSave;

  @override
  State<_AddHabitBottomSheet> createState() => _AddHabitBottomSheetState();
}

class _AddHabitBottomSheetState extends State<_AddHabitBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  HabitFrequency _frequency = HabitFrequency.daily;
  final Set<int> _selectedWeekdays = {1, 2, 3, 4, 5, 6, 7};
  bool _isSaving = false;

  static const _weekdayLabels = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frequency == HabitFrequency.selectedWeekdays &&
        _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();

    final habit = Habit(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      frequency: _frequency,
      scheduledWeekdays: _frequency == HabitFrequency.daily
          ? const {1, 2, 3, 4, 5, 6, 7}
          : _selectedWeekdays,
      createdAt: now,
      startDate: DateTime(now.year, now.month, now.day),
    );

    try {
      await widget.onSave(habit);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Habit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g., Morning Meditation',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'e.g., 10 minutes of mindfulness',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 18),
              const Text(
                'Frequency',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<HabitFrequency>(
                segments: const [
                  ButtonSegment(
                    value: HabitFrequency.daily,
                    label: Text('Every Day'),
                    icon: Icon(Icons.calendar_today_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: HabitFrequency.selectedWeekdays,
                    label: Text('Selected Days'),
                    icon: Icon(Icons.date_range_rounded, size: 16),
                  ),
                ],
                selected: {_frequency},
                onSelectionChanged: (set) {
                  setState(() {
                    _frequency = set.first;
                  });
                },
              ),
              if (_frequency == HabitFrequency.selectedWeekdays) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    final isSelected = _selectedWeekdays.contains(day);
                    return FilterChip(
                      label: Text(_weekdayLabels[day]!),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedWeekdays.add(day);
                          } else {
                            _selectedWeekdays.remove(day);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Habit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
