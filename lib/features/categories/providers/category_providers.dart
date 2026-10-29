import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libro_de_tareas/core/database/database.dart';
import 'package:libro_de_tareas/features/categories/domain/repositories/category_repository.dart';
import 'package:libro_de_tareas/providers/global_providers.dart';

/// Reactive provider that watches categories stored in SQLite.
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories();
});

/// Controller to perform Category CRUD updates.
final categoriesControllerProvider = Provider((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return CategoriesController(repo);
});

class CategoriesController {
  final CategoryRepository _repo;

  CategoriesController(this._repo);

  Future<void> addCategory(String name, int color) async {
    await _repo.insertCategory(
      CategoriesCompanion.insert(
        name: name,
        color: color,
      ),
    );
  }

  Future<void> editCategory(Category category) async {
    await _repo.updateCategory(category);
  }

  Future<void> removeCategory(int id) async {
    await _repo.deleteCategory(id);
  }
}
