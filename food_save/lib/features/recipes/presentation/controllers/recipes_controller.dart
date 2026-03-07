import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/services/api_service.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';

class RecipeStep {
  final int stepNumber;
  final String instruction;

  RecipeStep({required this.stepNumber, required this.instruction});

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepNumber: json['step_number'] ?? 0,
      instruction: json['instruction'] ?? '',
    );
  }
}

class Recipe {
  final String id;
  final String title;
  final String emoji;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final String? time;
  final String? difficulty;
  final String? description;
  final int? calories;
  double matchPercent;

  Recipe({
    required this.id, 
    required this.title, 
    required this.emoji, 
    required this.ingredients,
    this.steps = const [],
    this.time,
    this.difficulty,
    this.description,
    this.calories,
    this.matchPercent = 0,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final steps = (json['steps'] as List?)
        ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    steps.sort((a, b) => a.stepNumber.compareTo(b.stepNumber));

    return Recipe(
      id: json['id'].toString(),
      title: json['title'],
      emoji: json['emoji'] ?? "🍲",
      description: json['description'],
      calories: json['calories'],
      ingredients: (json['ingredients'] as List?)?.map((e) => e['name'].toString()).toList() ?? [],
      steps: steps,
      time: "${(json['prep_time_minutes'] ?? 0) + (json['cook_time_minutes'] ?? 0)} мин",
      difficulty: "Средне",
    );
  }
}

final favoriteRecipesProvider = StateNotifierProvider<FavoriteRecipesNotifier, List<Recipe>>((ref) {
  return FavoriteRecipesNotifier();
});

class FavoriteRecipesNotifier extends StateNotifier<List<Recipe>> {
  FavoriteRecipesNotifier() : super([]);

  void toggleFavorite(Recipe recipe) {
    if (state.any((r) => r.id == recipe.id)) {
      state = state.where((r) => r.id != recipe.id).toList();
    } else {
      state = [...state, recipe];
    }
  }

  bool isFavorite(String id) => state.any((r) => r.id == id);
}

final allRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final api = ApiService();
  final response = await api.getRecipes();
  if (response.statusCode == 200) {
    final List data = response.data;
    return data.map((e) => Recipe.fromJson(e)).toList();
  }
  return [];
});

/// Smart filtered recipes — sorted by match percentage with fridge products.
final filteredRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final recipesAsync = ref.watch(allRecipesProvider);
  final products = ref.watch(fridgeControllerProvider);

  // Get active product names (lowercase)
  final activeProductNames = products
      .where((p) => !p.isEaten && !p.isSpoiled)
      .map((p) => p.name.toLowerCase())
      .toSet();

  return recipesAsync.whenData((recipes) {
    for (final recipe in recipes) {
      if (recipe.ingredients.isEmpty) {
        recipe.matchPercent = 0;
      } else {
        final matched = recipe.ingredients.where(
          (ing) => activeProductNames.any((name) => 
            name.contains(ing.toLowerCase()) || ing.toLowerCase().contains(name)
          ),
        ).length;
        recipe.matchPercent = (matched / recipe.ingredients.length) * 100;
      }
    }

    // Sort: highest match first
    recipes.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
    return recipes;
  });
});
