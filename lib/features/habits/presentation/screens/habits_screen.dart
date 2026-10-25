import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_color_scheme.dart';
import '../../application/controllers/habits_controller.dart';
import '../../domain/entities/habit.dart';
import '../../domain/enums/habit_frequency.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatFrequency(Habit habit) {
    if (habit.frequency == HabitFrequency.daily) {
      return 'Daily';
    }
    final days = habit.scheduledWeekdays;
    if (days.length == 7) {
      return 'Daily';
    }
    if (days.length == 5 &&
        days.contains(1) &&
        days.contains(2) &&
        days.contains(3) &&
        days.contains(4) &&
        days.contains(5)) {
      return 'Weekdays';
    }
    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return 'Weekends';
    }
    const dayNames = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final sorted = days.toList()..sort();
    return sorted
        .map((d) => dayNames[d] ?? '')
        .where((s) => s.isNotEmpty)
        .join(', ');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habits',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Habit',
            icon: const Icon(Icons.add_rounded, size: 26),
            onPressed: () => _openAddHabitSheet(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Active Habits'),
            Tab(text: 'Archived'),
          ],
        ),
      ),
      body: habitsAsync.when(
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
          final activeHabits = allHabits
              .where((h) => h.archivedAt == null)
              .toList();
          final archivedHabits = allHabits
              .where((h) => h.archivedAt != null)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Active habits (Reorderable)
              _ActiveHabitsTab(
                habits: activeHabits,
                formatFrequency: _formatFrequency,
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(habitsControllerProvider.notifier)
                      .reorder(oldIndex, newIndex, activeHabits);
                },
                onArchive: (id) {
                  ref.read(habitsControllerProvider.notifier).archive(id);
                },
                onDelete: (id) {
                  ref.read(habitsControllerProvider.notifier).delete(id);
                },
                onAddHabit: () => _openAddHabitSheet(context),
              ),

              // Archived habits
              _ArchivedHabitsTab(
                habits: archivedHabits,
                formatFrequency: _formatFrequency,
                onUnarchive: (id) {
                  ref.read(habitsControllerProvider.notifier).unarchive(id);
                },
                onDelete: (id) {
                  ref.read(habitsControllerProvider.notifier).delete(id);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActiveHabitsTab extends StatelessWidget {
  const _ActiveHabitsTab({
    required this.habits,
    required this.formatFrequency,
    required this.onReorder,
    required this.onArchive,
    required this.onDelete,
    required this.onAddHabit,
  });

  final List<Habit> habits;
  final String Function(Habit) formatFrequency;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(String id) onArchive;
  final void Function(String id) onDelete;
  final VoidCallback onAddHabit;

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No active habits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a habit to build your daily routine.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAddHabit,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Habit'),
              ),
            ],
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: habits.length,
      onReorderItem: onReorder,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Card(
          key: ValueKey(habit.id),
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Reorder drag start handle
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (habit.description != null &&
                          habit.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          habit.description!.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          formatFrequency(habit),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions Menu
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'archive') {
                      onArchive(habit.id);
                    } else if (value == 'delete') {
                      onDelete(habit.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          Icon(Icons.archive_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Archive'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArchivedHabitsTab extends StatelessWidget {
  const _ArchivedHabitsTab({
    required this.habits,
    required this.formatFrequency,
    required this.onUnarchive,
    required this.onDelete,
  });

  final List<Habit> habits;
  final String Function(Habit) formatFrequency;
  final void Function(String id) onUnarchive;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.archive_outlined,
                  size: 36,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No archived habits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Habits you archive will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Card(
          key: ValueKey(habit.id),
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.outline),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: Text(
              habit.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              formatFrequency(habit),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Restore habit',
                  icon: const Icon(
                    Icons.unarchive_outlined,
                    color: AppColors.primary,
                  ),
                  onPressed: () => onUnarchive(habit.id),
                ),
                IconButton(
                  tooltip: 'Delete permanently',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  onPressed: () => onDelete(habit.id),
                ),
              ],
            ),
          ),
        );
      },
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
