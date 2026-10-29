import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService();

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: android,
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(defaultActionName: 'Abrir'),
    );
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    _initialized = true;
  }

  Future<bool> _ensureInitialized() async {
    try {
      await init();
      return true;
    } catch (error, stackTrace) {
      debugPrint('No se pudieron inicializar las notificaciones: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> showNotification(
      {required int id, required String title, required String body}) async {
    if (!await _ensureInitialized()) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_channel',
      'Tareas',
      channelDescription: 'Notificaciones de cambios de prioridad de tareas',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: 'task_$id',
    );
  }

  Future<void> cancelTaskNotifications(int taskId) async {
    if (!await _ensureInitialized()) return;
    await _plugin.cancel(id: taskId);
  }

  Future<void> scheduleTaskDeadlineNotification({
    required int taskId,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    if (!await _ensureInitialized()) return;

    // Scheduled notifications are supported by the mobile platforms. Linux
    // and web do not provide a portable scheduler through this plugin.
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS)) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime.from(dueDate, tz.local);

    // Las tareas ya vencidas se muestran en rojo, pero no deben generar una
    // notificación inmediata cada vez que se sincronizan.
    if (!scheduledDate.isAfter(now)) return;

    await _plugin.zonedSchedule(
      id: taskId,
      title: 'Recordatorio: "$taskTitle"',
      body: 'La fecha límite de esta tarea ha llegado.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Tareas',
          channelDescription:
              'Notificaciones de cambios de prioridad de tareas',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'task_$taskId',
    );
  }
}
