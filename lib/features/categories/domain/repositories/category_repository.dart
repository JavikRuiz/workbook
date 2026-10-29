import 'package:libro_de_tareas/core/database/database.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories();
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(int id);
  Future<int> insertCategory(CategoriesCompanion category);
  Future<bool> updateCategory(Category category);
  Future<int> deleteCategory(int id);
}
