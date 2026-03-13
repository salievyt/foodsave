// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipes_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipesRepositoryHash() => r'16cb95941de206d573aa70a2cee83667b37358af';

/// See also [recipesRepository].
@ProviderFor(recipesRepository)
final recipesRepositoryProvider =
    AutoDisposeProvider<RecipesRepository>.internal(
      recipesRepository,
      name: r'recipesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recipesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecipesRepositoryRef = AutoDisposeProviderRef<RecipesRepository>;
String _$filteredRecipesHash() => r'78d6d898b749dd78e1e5fbf61c1751cf26a82f62';

/// Smart filtered recipes — sorted by match percentage with fridge products.
///
/// Copied from [filteredRecipes].
@ProviderFor(filteredRecipes)
final filteredRecipesProvider =
    AutoDisposeProvider<AsyncValue<List<Recipe>>>.internal(
      filteredRecipes,
      name: r'filteredRecipesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredRecipesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredRecipesRef = AutoDisposeProviderRef<AsyncValue<List<Recipe>>>;
String _$favoriteRecipesHash() => r'74f45991f4b83246ee251d28b2b0b5dfb5e4988d';

/// See also [FavoriteRecipes].
@ProviderFor(FavoriteRecipes)
final favoriteRecipesProvider =
    AutoDisposeNotifierProvider<FavoriteRecipes, List<Recipe>>.internal(
      FavoriteRecipes.new,
      name: r'favoriteRecipesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteRecipesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FavoriteRecipes = AutoDisposeNotifier<List<Recipe>>;
String _$recipesViewModelHash() => r'd049f7a6c2a3d2d2f3399f13e24c6bd69da661f3';

/// See also [RecipesViewModel].
@ProviderFor(RecipesViewModel)
final recipesViewModelProvider =
    AutoDisposeNotifierProvider<
      RecipesViewModel,
      AsyncValue<List<Recipe>>
    >.internal(
      RecipesViewModel.new,
      name: r'recipesViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recipesViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecipesViewModel = AutoDisposeNotifier<AsyncValue<List<Recipe>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
