import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/features/recipes/presentation/viewmodels/recipes_view_model.dart';

final recipesControllerProvider = NotifierProvider<RecipesController, List<Recipe>>(() {
  return RecipesController();
});

class RecipesController extends Notifier<List<Recipe>> {
  @override
  List<Recipe> build() {
    return ref.watch(recipesViewModelProvider).data;
  }

  Future<void> fetchRecipes() async {
    await ref.read(recipesViewModelProvider.notifier).fetchRecipes();
  }
}
