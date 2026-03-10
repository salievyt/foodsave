import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/architecture/base_view_model.dart';
import 'package:food_save/core/services/notification_service.dart';
import 'package:food_save/core/services/local_storage_service.dart';
import 'package:food_save/features/fridge/data/repositories/fridge_repository_impl.dart';
import 'package:food_save/features/fridge/domain/repositories/fridge_repository.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';

final fridgeSearchProvider = StateProvider<String>((ref) => '');
final fridgeCategoryProvider = StateProvider<String>((ref) => 'Все');

final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  return FridgeRepositoryImpl();
});

final fridgeViewModelProvider = NotifierProvider<FridgeViewModel, BaseState<List<Product>>>(() {
  return FridgeViewModel();
});

final filteredFridgeProvider = Provider<List<Product>>((ref) {
  final fridgeState = ref.watch(fridgeViewModelProvider);
  final search = ref.watch(fridgeSearchProvider).toLowerCase();
  final category = ref.watch(fridgeCategoryProvider);

  var result = fridgeState.data.where((p) => !p.isEaten && !p.isSpoiled).toList();

  if (category != 'Все') {
    result = result.where((p) => p.category == category).toList();
  }

  if (search.isNotEmpty) {
    result = result.where((p) => p.name.toLowerCase().contains(search)).toList();
  }

  result.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

  return result;
});

class FridgeViewModel extends Notifier<BaseState<List<Product>>> {
  late final FridgeRepository _repository;

  @override
  BaseState<List<Product>> build() {
    _repository = ref.watch(fridgeRepositoryProvider);
    state = BaseState(data: []);
    _loadCachedThenFetch();
    return state;
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(Object? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void updateData(List<Product> data) {
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

  Future<void> _loadCachedThenFetch() async {
    try {
      final cached = await LocalStorageService.loadProducts();
      if (cached.isNotEmpty && state.data.isEmpty) {
        updateData(cached);
      }
    } catch (_) {}

    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    await safeExecute(() async {
      final products = await _repository.getProducts();
      updateData(products);
      await _repository.saveProducts(products);
      NotificationService.scheduleExpiryNotifications(products);
    });
  }

  Future<void> addProducts(List<Product> products) async {
    final newData = [...state.data, ...products];
    updateData(newData);
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
    final newData = [...state.data, product];
    updateData(newData);
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
    final newData = [
      for (final p in state.data)
        if (p.id == id) p.copyWith(isEaten: true) else p
    ];
    updateData(newData);
    await _repository.saveProducts(newData);
    _repository.updateProductStatus(id, 'CONSUMED');
  }

  Future<void> markAsSpoiled(String id) async {
    final newData = [
      for (final p in state.data)
        if (p.id == id) p.copyWith(isSpoiled: true) else p
    ];
    updateData(newData);
    await _repository.saveProducts(newData);
    _repository.updateProductStatus(id, 'WASTED');
  }

  Future<void> restoreProduct(Product product) async {
    final newData = [
      for (final p in state.data)
        if (p.id == product.id) product.copyWith(isEaten: false, isSpoiled: false) else p
    ];
    updateData(newData);
    await _repository.saveProducts(newData);
    _repository.updateProductStatus(product.id, 'ACTIVE');
  }

  Future<void> markAsEatenByName(String name) async {
    final productsToUpdate = state.data.where((p) => p.name.toLowerCase() == name.toLowerCase() && !p.isEaten && !p.isSpoiled).toList();
    
    final newData = [
      for (final p in state.data)
        if (p.name.toLowerCase() == name.toLowerCase() && !p.isEaten && !p.isSpoiled)
          p.copyWith(isEaten: true)
        else
          p
    ];

    updateData(newData);
    await _repository.saveProducts(newData);
    for (var p in productsToUpdate) {
      _repository.updateProductStatus(p.id, 'CONSUMED');
    }
  }

  Future<void> removeProduct(String id) async {
    final newData = state.data.where((p) => p.id != id).toList();
    updateData(newData);
    await _repository.saveProducts(newData);
  }

  int get totalEaten => state.data.where((p) => p.isEaten).length;
  int get totalSpoiled => state.data.where((p) => p.isSpoiled).length;
  int get totalActive => state.data.where((p) => !p.isEaten && !p.isSpoiled).length;
  int get totalProducts => state.data.length;
}
