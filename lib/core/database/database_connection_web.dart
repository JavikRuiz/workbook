// Drift's sql.js backend is currently the most compatible option for this
// application because it persists its database through IndexedDB.
// ignore_for_file: deprecated_member_use, experimental_member_use

import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openConnection() {
  return WebDatabase.withStorage(
    DriftWebStorage.indexedDb('libro_de_tareas'),
  );
}
