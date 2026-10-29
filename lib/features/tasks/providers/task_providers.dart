import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libro_de_tareas/core/database/database.dart';
import 'package:libro_de_tareas/core/utils/task_color_helper.dart';
import 'package:libro_de_tareas/features/tasks/domain/repositories/task_repository.dart';
import 'package:libro_de_tareas/providers/global_providers.dart';
import 'package:libro_de_tareas/services/notification_service.dart';

// Filter/Sort Enums
enum TaskStatusFilter { all, pending, completed }

enum TaskUrgencyFilter { all, green, greenYellow, yellow, orange, red }

enum TaskSortOption { urgency, newest, oldest }

// Filtering/Sorting State Providers
final taskSearchQueryProvider = StateProvider<String>((ref) => '');
final taskStatusFilterProvider =
    StateProvider<TaskStatusFilter>((ref) => TaskStatusFilter.all);
final taskUrgencyFilterProvider =
    StateProvider<TaskUrgencyFilter>((ref) => TaskUrgencyFilter.all);
final taskCategoryFilterProvider = StateProvider<int?>((ref) => null);
final taskSortOptionProvider =
    StateProvider<TaskSortOption>((ref) => TaskSortOption.urgency);

/// Emits a periodic value so colors, filters and ordering react to the
/// passage of time without requiring a database write.
final taskClockProvider = StreamProvider<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  controller.add(DateTime.now());
  final timer = Timer.periodic(const Duration(minutes: 1), (_) {
    controller.add(DateTime.now());
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

/// Watches the SQLite tasks stream directly.
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTasks();
});

/// A computed reactive provider that returns the filtered and sorted list of tasks.
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final query = ref.watch(taskSearchQueryProvider).toLowerCase().trim();
  final statusFilter = ref.watch(taskStatusFilterProvider);
  final urgencyFilter = ref.watch(taskUrgencyFilterProvider);
  final categoryFilter = ref.watch(taskCategoryFilterProvider);
  final sortOption = ref.watch(taskSortOptionProvider);
  ref.watch(taskClockProvider);

  // Return empty list if loading/error
  final tasks = tasksAsync.value ?? [];

  // 1. Filter
  final filtered = tasks.where((task) {
    // Search Query
    if (query.isNotEmpty) {
      final matchesTitle = task.title.toLowerCase().contains(query);
      final matchesDesc =
          task.description?.toLowerCase().contains(query) ?? false;
      if (!matchesTitle && !matchesDesc) return false;
    }

    // Status Filter
    if (statusFilter == TaskStatusFilter.pending && task.completed) {
      return false;
    }
    if (statusFilter == TaskStatusFilter.completed && !task.completed) {
      return false;
    }

    // Category Filter
    if (categoryFilter != null && task.categoryId != categoryFilter) {
      return false;
    }

    // Urgency Color Filter
    if (urgencyFilter != TaskUrgencyFilter.all) {
      final calculatedColor = TaskColorHelper.calculatePriorityColor(
        createdAt: task.createdAt,
        dueDate: task.dueDate,
      );

      if (urgencyFilter == TaskUrgencyFilter.green &&
          calculatedColor != TaskPriorityColor.green) {
        return false;
      }
      if (urgencyFilter == TaskUrgencyFilter.greenYellow &&
          calculatedColor != TaskPriorityColor.greenYellow) {
        return false;
      }
      if (urgencyFilter == TaskUrgencyFilter.yellow &&
          calculatedColor != TaskPriorityColor.yellow) {
        return false;
      }
      if (urgencyFilter == TaskUrgencyFilter.orange &&
          calculatedColor != TaskPriorityColor.orange) {
        return false;
      }
      if (urgencyFilter == TaskUrgencyFilter.red &&
          calculatedColor != TaskPriorityColor.red) {
        return false;
      }
    }

    return true;
  }).toList();

  // 2. Sort
  filtered.sort((a, b) {
    switch (sortOption) {
      case TaskSortOption.newest:
        return b.createdAt.compareTo(a.createdAt);

      case TaskSortOption.oldest:
        return a.createdAt.compareTo(b.createdAt);

      case TaskSortOption.urgency:
        // Calculate priority weight: Red = 2, Orange = 1, Green = 0
        final priorityA = TaskColorHelper.calculatePriorityColor(
          createdAt: a.createdAt,
          dueDate: a.dueDate,
        );
        final priorityB = TaskColorHelper.calculatePriorityColor(
          createdAt: b.createdAt,
          dueDate: b.dueDate,
        );

        final weightA = _priorityWeight(priorityA);
        final weightB = _priorityWeight(priorityB);

        // Put higher urgency first. If equal, sort by newest creation date
        if (weightA != weightB) {
          return weightB.compareTo(weightA);
        }
        return b.createdAt.compareTo(a.createdAt);
    }
  });

  return filtered;
});

int _priorityWeight(TaskPriorityColor color) {
  switch (color) {
    case TaskPriorityColor.green:
      return 0;
    case TaskPriorityColor.greenYellow:
      return 1;
    case TaskPriorityColor.yellow:
      return 2;
    case TaskPriorityColor.orange:
      return 3;
    case TaskPriorityColor.red:
      return 4;
  }
}

/// Controller to perform CRUD operations on Tasks.
final tasksControllerProvider = Provider((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return TasksController(repo, notifications);
});

class TasksController {
  final TaskRepository _repo;
  final NotificationService _notifications;

  TasksController(this._repo, this._notifications);

  Future<void> addTask({
    required String title,
    String? description,
    int? categoryId,
    required DateTime dueDate,
  }) async {
    final createdAt = DateTime.now();
    final companion = TasksCompanion.insert(
      title: title,
      description: description != null && description.trim().isNotEmpty
          ? Value(description)
          : const Value.absent(),
      categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
      createdAt: Value(createdAt),
      dueDate: Value(dueDate),
    );

    final taskId = await _repo.insertTask(companion);

    // Schedule the deadline reminder.
    _scheduleNotifications(taskId, title, dueDate);
  }

  Future<void> editTask(Task task) async {
    await _repo.updateTask(task);

    // Cancel notifications if completed, otherwise reschedule
    if (task.completed) {
      await _notifications.cancelTaskNotifications(task.id);
    } else {
      _scheduleNotifications(task.id, task.title, task.dueDate);
    }
  }

  Future<void> deleteTask(int id) async {
    await _repo.deleteTask(id);
    await _notifications.cancelTaskNotifications(id);
  }

  Future<void> toggleCompleted(int id, bool completed) async {
    await _repo.toggleTaskCompleted(id, completed);

    if (completed) {
      await _notifications.cancelTaskNotifications(id);
    } else {
      // Fetch details to reschedule notifications
      final task = await _repo.getTaskById(id);
      if (task != null) {
        _scheduleNotifications(task.id, task.title, task.dueDate);
      }
    }
  }

  /// Refreshes/reschedules notifications for all active tasks.
  Future<void> rescheduleAllTasksNotifications() async {
    final tasks = await _repo.getAllTasks();
    for (final task in tasks) {
      if (!task.completed) {
        _scheduleNotifications(task.id, task.title, task.dueDate);
      } else {
        await _notifications.cancelTaskNotifications(task.id);
      }
    }
  }

  void _scheduleNotifications(int taskId, String title, DateTime dueDate) {
    _notifications.scheduleTaskDeadlineNotification(
      taskId: taskId,
      taskTitle: title,
      dueDate: dueDate,
    );
  }
}
