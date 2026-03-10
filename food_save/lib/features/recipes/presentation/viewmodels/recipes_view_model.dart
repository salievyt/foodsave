import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/architecture/base_view_model.dart';
import 'package:food_save/features/fridge/presentation/controllers/fridge_controller.dart';
import 'package:food_save/features/recipes/data/repositories/recipes_repository_impl.dart';
import 'package:food_save/features/recipes/domain/repositories/recipes_repository.dart';

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

  Recipe copyWith({
    String? id,
    String? title,
    String? emoji,
    List<String>? ingredients,
    List<RecipeStep>? steps,
    String? time,
    String? difficulty,
    String? description,
    int? calories,
    double? matchPercentage,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      time: time ?? this.time,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      matchPercent: matchPercentage ?? this.matchPercent,
    );
  }
}

final recipesRepositoryProvider = Provider<RecipesRepository>((ref) {
  return RecipesRepositoryImpl();
});

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

final recipesViewModelProvider = NotifierProvider<RecipesViewModel, BaseState<List<Recipe>>>(() {
  return RecipesViewModel();
});

class RecipesViewModel extends Notifier<BaseState<List<Recipe>>> {
  late final RecipesRepository _repository;

  @override
  BaseState<List<Recipe>> build() {
    _repository = ref.watch(recipesRepositoryProvider);
    state = BaseState(data: []);
    fetchRecipes();
    return state;
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(Object? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void updateData(List<Recipe> data) {
    state = state.copyWith(data: data, isLoading: false, error: null);
  }

  Future<void> safeExecute(Future<void> Function() task) async {
    try {
      setLoading(true);
      await task();
    } catch (e) {
      setError(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchRecipes() async {
    await safeExecute(() async {
      final recipes = await _repository.getRecipes();
      updateData(recipes);
    });
  }
}

/// Smart filtered recipes — sorted by match percentage with fridge products.
final filteredRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final recipesState = ref.watch(recipesViewModelProvider);
  final fridgeProducts = ref.watch(fridgeControllerProvider);

  if (recipesState.isLoading) return const AsyncValue.loading();
  if (recipesState.error != null) return AsyncValue.error(recipesState.error!, StackTrace.current);

  final recipes = recipesState.data;
  final activeProductNames = fridgeProducts
      .where((p) => !p.isEaten && !p.isSpoiled)
      .map((p) => p.name.toLowerCase())
      .toSet();

  final result = recipes.map((recipe) {
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
    return recipe;
  }).toList();

  result.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
  return AsyncValue.data(result);
});
