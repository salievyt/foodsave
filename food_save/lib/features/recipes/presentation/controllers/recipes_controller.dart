import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/features/recipes/presentation/viewmodels/recipes_view_model.dart';

final recipesControllerProvider = NotifierProvider<RecipesController, List<Recipe>>(() {
  return RecipesController();
});

class RecipesController extends Notifier<List<Recipe>> {
  @override
  List<Recipe> build() {
    final recipesAsync = ref.watch(recipesViewModelProvider);
    return recipesAsync.valueOrNull ?? [];
  }

  Future<void> fetchRecipes() async {
    await ref.read(recipesViewModelProvider.notifier).fetchRecipes();
  }
}
