import 'package:drift/drift.dart';
import 'package:libro_de_tareas/core/database/database.dart';
import 'package:libro_de_tareas/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _db;

  TaskRepositoryImpl(this._db);

  @override
  Stream<List<Task>> watchTasks() {
    return (_db.select(_db.tasks)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  @override
  Future<List<Task>> getAllTasks() {
    return _db.select(_db.tasks).get();
  }

  @override
  Future<Task?> getTaskById(int id) {
    return (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<int> insertTask(TasksCompanion task) {
    return _db.into(_db.tasks).insert(task);
  }

  @override
  Future<bool> updateTask(Task task) {
    return _db.update(_db.tasks).replace(task);
  }

  @override
  Future<int> deleteTask(int id) {
    return (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> toggleTaskCompleted(int id, bool completed) async {
    final completedAt = completed ? DateTime.now() : null;
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        completed: Value(completed),
        completedAt: Value(completedAt),
      ),
    );
  }
}
