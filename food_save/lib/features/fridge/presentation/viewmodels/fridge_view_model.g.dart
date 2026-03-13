// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fridge_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fridgeRepositoryHash() => r'717e39ca5fc29e7bed5a103205c264d2403a2522';

/// See also [fridgeRepository].
@ProviderFor(fridgeRepository)
final fridgeRepositoryProvider = AutoDisposeProvider<FridgeRepository>.internal(
  fridgeRepository,
  name: r'fridgeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fridgeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FridgeRepositoryRef = AutoDisposeProviderRef<FridgeRepository>;
String _$filteredFridgeHash() => r'e4b36e83af339661d53ac506dcaf85ed119e5a29';

/// See also [filteredFridge].
@ProviderFor(filteredFridge)
final filteredFridgeProvider = AutoDisposeProvider<List<Product>>.internal(
  filteredFridge,
  name: r'filteredFridgeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredFridgeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredFridgeRef = AutoDisposeProviderRef<List<Product>>;
String _$fridgeSearchHash() => r'6b06795090fd20e49ea0a5a29b58440b5c7065bc';

/// See also [FridgeSearch].
@ProviderFor(FridgeSearch)
final fridgeSearchProvider =
    AutoDisposeNotifierProvider<FridgeSearch, String>.internal(
      FridgeSearch.new,
      name: r'fridgeSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fridgeSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FridgeSearch = AutoDisposeNotifier<String>;
String _$fridgeCategoryHash() => r'718a9989c847ea39ac96742c30081e172bdcd82c';

/// See also [FridgeCategory].
@ProviderFor(FridgeCategory)
final fridgeCategoryProvider =
    AutoDisposeNotifierProvider<FridgeCategory, String>.internal(
      FridgeCategory.new,
      name: r'fridgeCategoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fridgeCategoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FridgeCategory = AutoDisposeNotifier<String>;
String _$fridgeViewModelHash() => r'b6180281ad1b9e4d22e486e904866a5293602527';

/// See also [FridgeViewModel].
@ProviderFor(FridgeViewModel)
final fridgeViewModelProvider =
    AutoDisposeNotifierProvider<
      FridgeViewModel,
      AsyncValue<List<Product>>
    >.internal(
      FridgeViewModel.new,
      name: r'fridgeViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fridgeViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FridgeViewModel = AutoDisposeNotifier<AsyncValue<List<Product>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
