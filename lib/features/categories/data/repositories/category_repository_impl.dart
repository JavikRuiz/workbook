import 'package:drift/drift.dart';
import 'package:libro_de_tareas/core/database/database.dart';
import 'package:libro_de_tareas/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db);

  @override
  Stream<List<Category>> watchCategories() {
    return (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .watch();
  }

  @override
  Future<List<Category>> getAllCategories() {
    return _db.select(_db.categories).get();
  }

  @override
  Future<Category?> getCategoryById(int id) {
    return (_db.select(_db.categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<int> insertCategory(CategoriesCompanion category) {
    return _db.into(_db.categories).insert(category);
  }

  @override
  Future<bool> updateCategory(Category category) {
    return _db.update(_db.categories).replace(category);
  }

  @override
  Future<int> deleteCategory(int id) {
    return (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }
}
