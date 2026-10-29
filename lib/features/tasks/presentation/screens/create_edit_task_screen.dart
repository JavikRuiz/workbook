import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import 'package:libro_de_tareas/core/database/database.dart';
import 'package:libro_de_tareas/core/theme/app_theme.dart';
import 'package:libro_de_tareas/features/categories/providers/category_providers.dart';
import 'package:libro_de_tareas/features/tasks/providers/task_providers.dart';

class CreateEditTaskScreen extends ConsumerStatefulWidget {
  const CreateEditTaskScreen({super.key});

  @override
  ConsumerState<CreateEditTaskScreen> createState() =>
      _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends ConsumerState<CreateEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  int? _selectedCategoryId;
  DateTime? _selectedDueDate;
  Task? _editingTask;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Check if editing an existing task passed through arguments
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Task) {
        _editingTask = args;
        _titleController.text = args.title;
        _descController.text = args.description ?? '';
        _selectedCategoryId = args.categoryId;
        _selectedDueDate = args.dueDate;
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final dueDate = _selectedDueDate;
    if (dueDate == null) {
      _showMessage('Selecciona una fecha límite para la tarea');
      return;
    }

    if (_editingTask == null && !dueDate.isAfter(DateTime.now())) {
      _showMessage('La fecha límite debe ser posterior a este momento');
      return;
    }

    final controller = ref.read(tasksControllerProvider);

    if (_editingTask == null) {
      // Create new task
      await controller.addTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        categoryId: _selectedCategoryId,
        dueDate: dueDate,
      );
    } else {
      // Edit existing task
      final updated = _editingTask!.copyWith(
        title: _titleController.text.trim(),
        description: Value(_descController.text.trim()),
        categoryId: Value(_selectedCategoryId),
        dueDate: dueDate,
      );
      await controller.editTask(updated);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _editingTask == null
              ? '¡Tarea creada con éxito!'
              : '¡Tarea actualizada con éxito!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now.add(const Duration(days: 1));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecciona la fecha límite',
      cancelText: 'Cancelar',
      confirmText: 'Continuar',
    );

    if (pickedDate == null || !mounted) return;

    final initialTime = _selectedDueDate != null
        ? TimeOfDay.fromDateTime(_selectedDueDate!)
        : TimeOfDay.fromDateTime(now.add(const Duration(days: 1)));
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Selecciona la hora límite',
      cancelText: 'Cancelar',
      confirmText: 'Guardar',
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final isEditing = _editingTask != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Instructions / Context Card
                _buildContextCard(context, isEditing),
                const SizedBox(height: 24),

                // 2. Title Field
                Text(
                  'Título de la Tarea',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Ej. Comprar materiales para el proyecto...',
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                    prefixIcon: const Icon(Icons.title, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa un título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. Description Field
                Text(
                  'Descripción (Opcional)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  decoration: InputDecoration(
                    hintText: 'Añade notas adicionales o detalles...',
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 50.0),
                      child: Icon(Icons.description, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Due Date Field
                Text(
                  'Fecha límite',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDueDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Selecciona cuándo debe estar lista',
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.event_outlined, size: 20),
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(
                      _selectedDueDate == null
                          ? 'Sin fecha límite seleccionada'
                          : DateFormat('dd MMM yyyy, hh:mm a', 'es_ES')
                              .format(_selectedDueDate!),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedDueDate == null
                            ? Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.55)
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Category Selector
                Text(
                  'Seleccionar Categoría',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 10),
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return _buildNoCategoriesWidget(context);
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // "Ninguna" chip option
                        ChoiceChip(
                          label: const Text('Ninguna'),
                          selected: _selectedCategoryId == null,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1E293B)
                                  : Colors.grey.shade200,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _selectedCategoryId == null
                                ? Colors.white
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700),
                          ),
                          showCheckmark: false,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategoryId = null;
                            });
                          },
                        ),
                        // Custom Categories
                        ...categories.map((cat) {
                          final isSelected = _selectedCategoryId == cat.id;
                          final catColor = Color(cat.color);
                          return ChoiceChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            selectedColor: catColor,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E293B)
                                    : Colors.grey.shade200,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700),
                            ),
                            showCheckmark: false,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategoryId = cat.id;
                              });
                            },
                          );
                        }),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error al cargar categorías: $err'),
                ),
                const SizedBox(height: 48),

                // 6. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isEditing ? Icons.save : Icons.add_task, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Guardar Cambios' : 'Crear Tarea',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextCard(BuildContext context, bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.softDecoration(context, radius: 20),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditing
                  ? 'Estás editando esta tarea. Su color se recalculará según el tiempo transcurrido y se reprogramará el recordatorio.'
                  : 'El color cambiará automáticamente de verde a rojo según avance el plazo, y recibirás un recordatorio en la fecha límite.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCategoriesWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.softDecoration(context, radius: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Aún no tienes categorías creadas',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/categories');
            },
            child: const Text('Crear Categoría'),
          ),
        ],
      ),
    );
  }
}
