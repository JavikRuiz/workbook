import 'package:drift/drift.dart';

import 'database_connection.dart'
    if (dart.library.html) 'database_connection_web.dart';

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer()(); // Código de color hexadecimal (ARGB)
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dueDate => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get categoryId => integer()
      .nullable()
      .references(Categories, #id, onDelete: KeyAction.setNull)();
}

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get greenDays => integer().withDefault(const Constant(3))();
  IntColumn get orangeDays => integer().withDefault(const Constant(7))();
  IntColumn get redDays => integer().withDefault(const Constant(8))();
  BoolColumn get useMinutes => boolean().withDefault(const Constant(false))();
  BoolColumn get darkMode => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Tasks, Categories, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();

        // Semilla para la configuración por defecto de la aplicación
        await into(settings).insert(const SettingsCompanion(
          id: Value(1),
          greenDays: Value(3),
          orangeDays: Value(7),
          redDays: Value(8),
          useMinutes: Value(false),
          darkMode: Value(true), // Modo oscuro por defecto
        ));

        // Semilla para las categorías por defecto
        await into(categories).insert(const CategoriesCompanion(
          name: Value('Personal'),
          color: Value(0xFF3B82F6), // Azul
        ));
        await into(categories).insert(const CategoriesCompanion(
          name: Value('Trabajo'),
          color: Value(0xFFEC4899), // Rosa
        ));
        await into(categories).insert(const CategoriesCompanion(
          name: Value('Salud'),
          color: Value(0xFF10B981), // Esmeralda
        ));
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(tasks, tasks.dueDate);

          // Las tareas antiguas no tenían fecha límite. Se conserva su
          // antigüedad asignándoles una fecha límite de siete días después
          // de su creación.
          await customStatement(
            'UPDATE tasks SET due_date = created_at + 604800000',
          );
        }
      },
    );
  }
}
