import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libro_de_tareas/core/database/database.dart';
import 'package:libro_de_tareas/features/categories/data/repositories/category_repository_impl.dart';
import 'package:libro_de_tareas/features/categories/domain/repositories/category_repository.dart';
import 'package:libro_de_tareas/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:libro_de_tareas/features/tasks/domain/repositories/task_repository.dart';
import 'package:libro_de_tareas/services/notification_service.dart';
import 'package:libro_de_tareas/services/voice_recognition_service.dart';

// Database Provider (Singleton)
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Repository Providers
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TaskRepositoryImpl(db);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepositoryImpl(db);
});

// Services Providers
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final voiceRecognitionServiceProvider =
    Provider<VoiceRecognitionService>((ref) {
  return VoiceRecognitionService();
});
