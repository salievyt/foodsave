import 'package:food_save/features/recipes/presentation/controllers/recipes_controller.dart';
import 'package:food_save/features/recipes/presentation/viewmodels/recipes_view_model.dart';

abstract class RecipesRepository {
  Future<List<Recipe>> getRecipes();
}
