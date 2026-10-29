import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libro_de_tareas/core/database/database.dart';
import 'package:libro_de_tareas/core/theme/app_theme.dart';
import 'package:libro_de_tareas/core/utils/task_color_helper.dart';
import 'package:libro_de_tareas/features/categories/providers/category_providers.dart';
import 'package:libro_de_tareas/features/tasks/presentation/widgets/task_card.dart';
import 'package:libro_de_tareas/features/tasks/providers/task_providers.dart';
import 'package:libro_de_tareas/features/voice/presentation/widgets/voice_input_fab.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);

    // Watch filters & sorting to style the chips
    final statusFilter = ref.watch(taskStatusFilterProvider);
    final urgencyFilter = ref.watch(taskUrgencyFilterProvider);
    final categoryFilter = ref.watch(taskCategoryFilterProvider);
    final sortOption = ref.watch(taskSortOptionProvider);

    // Watch categories to build filter list
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Libro de Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categorías',
            onPressed: () => Navigator.of(context).pushNamed('/categories'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration(context),
        child: Column(
          children: [
            // 1. Statistics Cards & Search Panel
            _buildHeaderStats(context, tasksAsync.value ?? []),

            // 2. Search & Filters Panel
            _buildSearchAndFilters(
              context,
              ref,
              statusFilter,
              urgencyFilter,
              categoryFilter,
              sortOption,
              categoriesAsync.value ?? [],
            ),

            // 3. Tasks List
            Expanded(
              child: filteredTasks.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TaskCard(task: task),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // Combined FABs: Dictation Mic FAB + Add Task FAB
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Voice Microphone Button
          const VoiceInputFab(),
          const SizedBox(width: 16),
          // Standard Add Button
          FloatingActionButton(
            heroTag: 'add_task_fab',
            onPressed: () {
              Navigator.of(context).pushNamed('/create_edit_task');
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats(BuildContext context, List<Task> tasks) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.completed).length;
    final pending = total - completed;

    // Calculate critical (Red) tasks count
    int criticalCount = 0;
    for (final task in tasks) {
      if (!task.completed) {
        final color = TaskColorHelper.calculatePriorityColor(
          createdAt: task.createdAt,
          dueDate: task.dueDate,
        );
        if (color == TaskPriorityColor.red) {
          criticalCount++;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.softDecoration(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu Progreso',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    total > 0
                        ? '${((completed / total) * 100).toInt()}% Completado'
                        : 'Sin Tareas Pendientes',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (criticalCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFEF4444), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$criticalCount Críticas',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              minHeight: 8,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', total.toString(), Colors.blue),
              _buildStatItem('Pendientes', pending.toString(), Colors.orange),
              _buildStatItem('Completadas', completed.toString(), Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    WidgetRef ref,
    TaskStatusFilter currentStatus,
    TaskUrgencyFilter currentUrgency,
    int? currentCategoryId,
    TaskSortOption currentSort,
    List<Category> categories,
  ) {
    final searchController =
        TextEditingController(text: ref.read(taskSearchQueryProvider));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(10),
      decoration: AppTheme.softDecoration(context, radius: 22),
      child: Column(
        children: [
          // Search Input + Sort Dropdown
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar tarea...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              searchController.clear();
                              ref.read(taskSearchQueryProvider.notifier).state =
                                  '';
                            },
                            child: const Icon(Icons.clear, size: 18),
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade200,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  onChanged: (text) {
                    ref.read(taskSearchQueryProvider.notifier).state = text;
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Sort Trigger
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.shade200,
                  ),
                ),
                child: PopupMenuButton<TaskSortOption>(
                  icon: const Icon(Icons.sort_rounded),
                  tooltip: 'Ordenar por',
                  onSelected: (option) {
                    ref.read(taskSortOptionProvider.notifier).state = option;
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: TaskSortOption.urgency,
                      child: Text('Más Urgente Primero'),
                    ),
                    const PopupMenuItem(
                      value: TaskSortOption.newest,
                      child: Text('Más Reciente Primero'),
                    ),
                    const PopupMenuItem(
                      value: TaskSortOption.oldest,
                      child: Text('Más Antigua Primero'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Horizontal filters list
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // 1. Status Filter: Pendientes / Completadas
                _buildFilterChip(
                  context,
                  label: 'Todas',
                  isSelected: currentStatus == TaskStatusFilter.all &&
                      currentUrgency == TaskUrgencyFilter.all &&
                      currentCategoryId == null,
                  onSelected: () {
                    ref.read(taskStatusFilterProvider.notifier).state =
                        TaskStatusFilter.all;
                    ref.read(taskUrgencyFilterProvider.notifier).state =
                        TaskUrgencyFilter.all;
                    ref.read(taskCategoryFilterProvider.notifier).state = null;
                  },
                ),
                _buildFilterChip(
                  context,
                  label: 'Pendientes',
                  isSelected: currentStatus == TaskStatusFilter.pending,
                  onSelected: () {
                    ref.read(taskStatusFilterProvider.notifier).state =
                        TaskStatusFilter.pending;
                  },
                ),
                _buildFilterChip(
                  context,
                  label: 'Completadas',
                  isSelected: currentStatus == TaskStatusFilter.completed,
                  onSelected: () {
                    ref.read(taskStatusFilterProvider.notifier).state =
                        TaskStatusFilter.completed;
                  },
                ),

                const VerticalDivider(
                    width: 16, thickness: 1, indent: 6, endIndent: 6),

                // 2. Color/Urgency filter
                _buildFilterChip(
                  context,
                  label: 'Verdes (Nuevas)',
                  isSelected: currentUrgency == TaskUrgencyFilter.green,
                  activeColor: const Color(0xFF10B981),
                  onSelected: () {
                    ref.read(taskUrgencyFilterProvider.notifier).state =
                        TaskUrgencyFilter.green;
                  },
                ),
                _buildFilterChip(
                  context,
                  label: 'Verde-amarillas',
                  isSelected: currentUrgency == TaskUrgencyFilter.greenYellow,
                  activeColor: const Color(0xFF9ACD32),
                  onSelected: () {
                    ref.read(taskUrgencyFilterProvider.notifier).state =
                        TaskUrgencyFilter.greenYellow;
                  },
                ),
                _buildFilterChip(
                  context,
                  label: 'Amarillas',
                  isSelected: currentUrgency == TaskUrgencyFilter.yellow,
                  activeColor: const Color(0xFFFACC15),
                  onSelected: () {
                    ref.read(taskUrgencyFilterProvider.notifier).state =
                        TaskUrgencyFilter.yellow;
                  },
                ),
                _buildFilterChip(
                  context,
                  label: 'Naranjas (Próximas)',
                  isSelected: currentUrgency == TaskUrgencyFilter.orange,
                  activeColor: const Color(0xFFF59E0B),
                  onSelected: () {
                    ref.read(taskUrgencyFilterProvider.notifier).state =
                        TaskUrgencyFilter.orange;
                  },
                ),
                _buildFilterChip(
                  context,
                  label: 'Rojas (Críticas)',
                  isSelected: currentUrgency == TaskUrgencyFilter.red,
                  activeColor: const Color(0xFFEF4444),
                  onSelected: () {
                    ref.read(taskUrgencyFilterProvider.notifier).state =
                        TaskUrgencyFilter.red;
                  },
                ),

                if (categories.isNotEmpty) ...[
                  const VerticalDivider(
                      width: 16, thickness: 1, indent: 6, endIndent: 6),

                  // 3. Categories Filters
                  ...categories.map((cat) => _buildFilterChip(
                        context,
                        label: cat.name,
                        isSelected: currentCategoryId == cat.id,
                        activeColor: Color(cat.color),
                        onSelected: () {
                          ref.read(taskCategoryFilterProvider.notifier).state =
                              currentCategoryId == cat.id ? null : cat.id;
                        },
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? activeColor,
  }) {
    final themeColor = activeColor ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade700),
          ),
        ),
        selected: isSelected,
        selectedColor: themeColor,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? themeColor : Colors.transparent,
            width: 1,
          ),
        ),
        showCheckmark: false,
        onSelected: (_) => onSelected(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_rounded,
            size: 64,
            color: Colors.grey.shade400.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay tareas que coincidan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '¡Prueba ajustando los filtros o añade una nueva!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
