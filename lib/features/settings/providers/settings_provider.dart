import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libro_de_tareas/core/database/database.dart';
import 'package:libro_de_tareas/providers/global_providers.dart';

class SettingsNotifier extends StateNotifier<Setting?> {
  final AppDatabase _db;

  SettingsNotifier(this._db) : super(null) {
    _loadSettings();
  }

  /// Load settings from database
  Future<void> _loadSettings() async {
    final settingsRow = await (_db.select(_db.settings)
          ..where((s) => s.id.equals(1)))
        .getSingleOrNull();
    if (settingsRow != null) {
      state = settingsRow;
    }
  }

  /// Update app settings in database and refresh state
  Future<void> updateSettings({
    int? greenDays,
    int? orangeDays,
    int? redDays,
    bool? useMinutes,
    bool? darkMode,
  }) async {
    if (state == null) return;

    final updated = state!.copyWith(
      greenDays: greenDays ?? state!.greenDays,
      orangeDays: orangeDays ?? state!.orangeDays,
      redDays: redDays ?? state!.redDays,
      useMinutes: useMinutes ?? state!.useMinutes,
      darkMode: darkMode ?? state!.darkMode,
    );

    await _db.update(_db.settings).replace(updated);
    state = updated;
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Setting?>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsNotifier(db);
});
