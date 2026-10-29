import 'package:flutter/material.dart';

enum TaskPriorityColor {
  green,
  greenYellow,
  yellow,
  orange,
  red,
}

class TaskColorHelper {
  /// Calcula el color según el porcentaje de tiempo transcurrido hasta la
  /// fecha límite.
  ///
  /// La transición es verde, verde amarillento, amarillo, naranja y rojo al
  /// alcanzar respectivamente el 30%, 50%, 70% y 90% del plazo.
  static TaskPriorityColor calculatePriorityColor({
    required DateTime createdAt,
    required DateTime dueDate,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final totalDuration = dueDate.difference(createdAt).inMilliseconds;

    if (totalDuration <= 0 || !currentTime.isBefore(dueDate)) {
      return TaskPriorityColor.red;
    }

    final elapsedDuration =
        currentTime.difference(createdAt).inMilliseconds.toDouble();
    final elapsedPercentage = elapsedDuration / totalDuration;

    if (elapsedPercentage < 0.3) {
      return TaskPriorityColor.green;
    } else if (elapsedPercentage < 0.5) {
      return TaskPriorityColor.greenYellow;
    } else if (elapsedPercentage < 0.7) {
      return TaskPriorityColor.yellow;
    } else if (elapsedPercentage < 0.9) {
      return TaskPriorityColor.orange;
    } else {
      return TaskPriorityColor.red;
    }
  }

  /// Asocia cada prioridad (enum) con su color de visualización
  static Color getColor(TaskPriorityColor priority) {
    switch (priority) {
      case TaskPriorityColor.green:
        return const Color(0xFF10B981); // Verde Esmeralda Vibrante
      case TaskPriorityColor.greenYellow:
        return const Color(0xFF9ACD32); // Verde amarillento
      case TaskPriorityColor.yellow:
        return const Color(0xFFFACC15); // Amarillo
      case TaskPriorityColor.orange:
        return const Color(0xFFF59E0B); // Naranja Ámbar Moderno
      case TaskPriorityColor.red:
        return const Color(0xFFEF4444); // Rojo Rosa Premium
    }
  }

  /// Asocia cada prioridad (enum) con una etiqueta legible por el usuario
  static String getLabel(TaskPriorityColor priority) {
    switch (priority) {
      case TaskPriorityColor.green:
        return 'A tiempo';
      case TaskPriorityColor.greenYellow:
        return 'Avanzando';
      case TaskPriorityColor.yellow:
        return 'Atención';
      case TaskPriorityColor.orange:
        return 'Próxima a vencer';
      case TaskPriorityColor.red:
        return 'Crítica o vencida';
    }
  }
}
