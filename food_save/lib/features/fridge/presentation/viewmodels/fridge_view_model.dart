import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:food_save/core/services/notification_service.dart';
import 'package:food_save/core/services/local_storage_service.dart';
import 'package:food_save/features/fridge/data/repositories/fridge_repository_impl.dart';
import 'package:food_save/features/fridge/domain/repositories/fridge_repository.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';

part 'fridge_view_model.g.dart';

// State providers for search and category
@riverpod
class FridgeSearch extends _$FridgeSearch {
  @override
  String build() => '';

  void update(String value) {
    state = value;
  }
}

@riverpod
class FridgeCategory extends _$FridgeCategory {
  @override
  String build() => 'Все';

  void update(String value) {
    state = value;
  }
}

@riverpod
FridgeRepository fridgeRepository(Ref ref) {
  return FridgeRepositoryImpl();
}

@riverpod
class FridgeViewModel extends _$FridgeViewModel {
  late FridgeRepository _repository;

  @override
  AsyncValue<List<Product>> build() {
    _repository = ref.watch(fridgeRepositoryProvider);
    _loadCachedThenFetch();
    return const AsyncValue.loading();
  }

  Future<void> _loadCachedThenFetch() async {
    try {
      final cached = await LocalStorageService.loadProducts();
      if (cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      }
    } catch (_) {}

    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _repository.getProducts();
      await _repository.saveProducts(products);
      NotificationService.scheduleExpiryNotifications(products);
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addProducts(List<Product> products) async {
    final currentData = state.valueOrNull ?? [];
    final newData = [...currentData, ...products];
    state = AsyncValue.data(newData);
    await _repository.saveProducts(newData);
    for (final p in products) {
      _repository.addProduct({
        'name': p.name,
        'expiration_date': p.expiryDate.toIso8601String().split('T')[0],
        'status': 'ACTIVE',
        'quantity': 1,
        'unit': 'PCS',
      });
    }
  }

  Future<void> addProduct(Product product) async {
    final currentData = state.valueOrNull ?? [];
    final newData = [...currentData, product];
    state = AsyncValue.data(newData);
    await _repository.saveProducts(newData);
    _repository.addProduct({
      'name': product.name,
      'expiration_date': product.expiryDate.toIso8601String().split('T')[0],
      'status': 'ACTIVE',
      'quantity': 1,
      'unit': 'PCS',
    });
  }

  Future<void> markAsEaten(String id) async {
    final currentData = state.valueOrNull ?? [];
    final newData = [
      for (final p in currentData)
        if (p.id == id) p.copyWith(isEaten: true) else p
    ];
    state = AsyncValue.data(newData);
    await _repository.saveProducts(newData);
    _repository.updateProductStatus(id, 'CONSUMED');
  }

  Future<void> markAsSpoiled(String id) async {
    final currentData = state.valueOrNull ?? [];
    final newData = [
      for (final p in currentData)
        if (p.id == id) p.copyWith(isSpoiled: true) else p
    ];
    state = AsyncValue.data(newData);
    await _repository.saveProducts(newData);
    _repository.updateProductStatus(id, 'WASTED');
  }

  Future<void> restoreProduct(Product product) async {
    final currentData = state.valueOrNull ?? [];
    final newData = [
      for (final p in currentData)
        if (p.id == product.id) product.copyWith(isEaten: false, isSpoiled: false) else p
    ];
    state = AsyncValue.data(newData);
    await _repository.saveProducts(newData);
    _repository.updateProductStatus(product.id, 'ACTIVE');
  }

  Future<void> markAsEatenByName(String name) async {
    final currentData = state.valueOrNull ?? [];
    final productsToUpdate = currentData.where(
      (p) => p.name.toLowerCase() == name.toLowerCase() && !p.isEaten && !p.isSpoiled,
    ).toList();

    final newData = [
      for (final p in currentData)
        if (p.name.toLowerCase() == name.toLowerCase() && !p.isEaten && !p.isSpoiled)
          p.copyWith(isEaten: true)
        else
          p
    ];

    state = AsyncValue.data(newData);
    await _repository.saveProducts(newData);
    for (var p in productsToUpdate) {
      _repository.updateProductStatus(p.id, 'CONSUMED');
    }
  }

  Future<void> removeProduct(String id) async {
    final currentData = state.valueOrNull ?? [];
    final newData = currentData.where((p) => p.id != id).toList();
    state = AsyncValue.data(newData);
    await _repository.saveProducts(newData);
  }

  int get totalEaten => (state.valueOrNull ?? []).where((p) => p.isEaten).length;
  int get totalSpoiled => (state.valueOrNull ?? []).where((p) => p.isSpoiled).length;
  int get totalActive => (state.valueOrNull ?? []).where((p) => !p.isEaten && !p.isSpoiled).length;
  int get totalProducts => (state.valueOrNull ?? []).length;
}

@riverpod
List<Product> filteredFridge(Ref ref) {
  final fridgeAsync = ref.watch(fridgeViewModelProvider);
  final search = ref.watch(fridgeSearchProvider).toLowerCase();
  final category = ref.watch(fridgeCategoryProvider);

  return fridgeAsync.when(
    data: (products) {
      var result = products.where((p) => !p.isEaten && !p.isSpoiled).toList();

      if (category != 'Все') {
        result = result.where((p) => p.category == category).toList();
      }

      if (search.isNotEmpty) {
        result = result.where((p) => p.name.toLowerCase().contains(search)).toList();
      }

      result.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      return result;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}
