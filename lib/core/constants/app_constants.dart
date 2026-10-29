class AppConstants {
  static const String appName = 'Libro de Tareas';

  // Constantes de Notificaciones
  static const String notificationChannelId = 'task_aging_channel';
  static const String notificationChannelName = 'Alertas de Envejecimiento';
  static const String notificationChannelDescription =
      'Notificaciones enviadas cuando una tarea envejece y sube su nivel de urgencia.';

  // Configuraciones de umbral de color por defecto (en días)
  static const int defaultGreenDays = 3;
  static const int defaultOrangeDays = 7;
  static const int defaultRedDays = 8;

  // Claves de acción de notificaciones
  static const String notificationActionCompleteId = 'complete_task_action';
  static const String notificationActionCompleteTitle = 'Completar Tarea';

  // Claves de la aplicación para la configuración
  static const String settingsId = 'app_settings_row_id';
}
