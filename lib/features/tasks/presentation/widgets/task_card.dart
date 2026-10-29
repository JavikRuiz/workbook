import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:libro_de_tareas/core/database/database.dart';
import 'package:libro_de_tareas/core/theme/app_theme.dart';
import 'package:libro_de_tareas/core/utils/task_color_helper.dart';
import 'package:libro_de_tareas/features/categories/providers/category_providers.dart';
import 'package:libro_de_tareas/features/tasks/providers/task_providers.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(taskClockProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    // Calculate color dynamically from the task deadline.
    final priorityColor = TaskColorHelper.calculatePriorityColor(
      createdAt: task.createdAt,
      dueDate: task.dueDate,
    );
    final statusColor =
        task.completed ? Colors.grey : TaskColorHelper.getColor(priorityColor);

    // 2. Fetch category details if assigned
    Category? assignedCategory;
    if (task.categoryId != null && categoriesAsync.hasValue) {
      try {
        assignedCategory =
            categoriesAsync.value!.firstWhere((c) => c.id == task.categoryId);
      } catch (_) {
        // Category deleted or not found
      }
    }

    final formattedDate =
        DateFormat('dd MMM yyyy, hh:mm a', 'es_ES').format(task.createdAt);
    final formattedDueDate =
        DateFormat('dd MMM yyyy, hh:mm a', 'es_ES').format(task.dueDate);

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        // Show confirm dialog
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('¿Eliminar Tarea?'),
                content: Text(
                    '¿Estás seguro de que deseas eliminar la tarea "${task.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        ref.read(tasksControllerProvider).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarea "${task.title}" eliminada'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/create_edit_task', arguments: task);
        },
        child: Container(
          decoration: AppTheme.softDecoration(context, radius: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Highlight strip on the left showing priority aging status
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 6,
                    color: statusColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Complete Checkbox with Urgency Color tint
                      Transform.scale(
                        scale: 1.15,
                        child: Checkbox(
                          value: task.completed,
                          activeColor: Colors.grey,
                          checkColor: Colors.white,
                          side: BorderSide(color: statusColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onChanged: (bool? checked) {
                            if (checked != null) {
                              ref
                                  .read(tasksControllerProvider)
                                  .toggleCompleted(task.id, checked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Text Contents
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: task.completed
                                    ? Colors.grey.shade500
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            if (task.description != null &&
                                task.description!.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                task.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: task.completed
                                      ? Colors.grey.shade400
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.75),
                                  height: 1.3,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Meta elements row (Date + Category Pill)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Creation and deadline timestamps
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDateRow(
                                      icon: Icons.access_time_filled,
                                      label: 'Creada: $formattedDate',
                                      color: task.completed
                                          ? Colors.grey.shade400
                                          : Colors.indigo.shade300,
                                    ),
                                    const SizedBox(height: 4),
                                    _buildDateRow(
                                      icon: Icons.event_outlined,
                                      label: 'Límite: $formattedDueDate',
                                      color: task.completed
                                          ? Colors.grey.shade400
                                          : TaskColorHelper.getColor(
                                              priorityColor),
                                    ),
                                  ],
                                ),
                                // Category Tag
                                if (assignedCategory != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(assignedCategory.color)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color(assignedCategory.color)
                                              .withValues(alpha: 0.35),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: Color(
                                                  assignedCategory.color),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            assignedCategory.name,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(
                                                  assignedCategory.color),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
