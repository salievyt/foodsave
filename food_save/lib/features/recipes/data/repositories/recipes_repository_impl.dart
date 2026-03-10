import 'package:food_save/core/architecture/base_repository.dart';
import 'package:food_save/features/recipes/domain/repositories/recipes_repository.dart';
import 'package:food_save/features/recipes/presentation/viewmodels/recipes_view_model.dart';

class RecipesRepositoryImpl extends BaseRepository implements RecipesRepository {
  @override
  Future<List<Recipe>> getRecipes() async {
    final response = await api.getRecipes();
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((e) => Recipe.fromJson(e)).toList();
    }
    return [];
  }
}
