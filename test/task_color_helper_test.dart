import 'package:flutter_test/flutter_test.dart';
import 'package:libro_de_tareas/core/utils/task_color_helper.dart';

void main() {
  final createdAt = DateTime(2026, 1, 1);
  final dueDate = DateTime(2026, 1, 11);

  TaskPriorityColor colorAt(double percentage) {
    final elapsed = dueDate.difference(createdAt).inMilliseconds;
    return TaskColorHelper.calculatePriorityColor(
      createdAt: createdAt,
      dueDate: dueDate,
      now: createdAt.add(
        Duration(milliseconds: (elapsed * percentage).round()),
      ),
    );
  }

  test('mantiene verde al iniciar y cambia según el porcentaje transcurrido',
      () {
    expect(colorAt(0), TaskPriorityColor.green);
    expect(colorAt(0.3), TaskPriorityColor.greenYellow);
    expect(colorAt(0.5), TaskPriorityColor.yellow);
    expect(colorAt(0.7), TaskPriorityColor.orange);
    expect(colorAt(0.9), TaskPriorityColor.red);
  });

  test('marca en rojo una tarea vencida', () {
    expect(
      TaskColorHelper.calculatePriorityColor(
        createdAt: createdAt,
        dueDate: dueDate,
        now: dueDate,
      ),
      TaskPriorityColor.red,
    );
  });
}
