import 'package:libro_de_tareas/core/database/database.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasks();
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(int id);
  Future<int> insertTask(TasksCompanion task);
  Future<bool> updateTask(Task task);
  Future<int> deleteTask(int id);
  Future<void> toggleTaskCompleted(int id, bool completed);
}
