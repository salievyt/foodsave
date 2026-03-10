import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';
import 'package:food_save/features/fridge/presentation/viewmodels/fridge_view_model.dart';

final fridgeControllerProvider = NotifierProvider<FridgeController, List<Product>>(() {
  return FridgeController();
});

final filteredFridgeProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(fridgeControllerProvider);
  final search = ref.watch(fridgeSearchProvider);
  final category = ref.watch(fridgeCategoryProvider);
  
  return products.where((p) {
    final matchesSearch = search.isEmpty || p.name.toLowerCase().contains(search.toLowerCase());
    final matchesCategory = category == 'Все' || p.category == category;
    return matchesSearch && matchesCategory;
  }).toList();
});

class FridgeController extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    return ref.watch(fridgeViewModelProvider).data;
  }

  Future<void> addProduct(Product product) async {
    await ref.read(fridgeViewModelProvider.notifier).addProduct(product);
  }

  Future<void> addProducts(List<Product> products) async {
    await ref.read(fridgeViewModelProvider.notifier).addProducts(products);
  }

  Future<void> removeProduct(String id) async {
    await ref.read(fridgeViewModelProvider.notifier).removeProduct(id);
  }

  Future<void> markAsEaten(String id) async {
    await ref.read(fridgeViewModelProvider.notifier).markAsEaten(id);
  }

  Future<void> markAsSpoiled(String id) async {
    await ref.read(fridgeViewModelProvider.notifier).markAsSpoiled(id);
  }

  Future<void> restoreProduct(Product product) async {
    await ref.read(fridgeViewModelProvider.notifier).restoreProduct(product);
  }

  Future<void> markAsEatenByName(String name) async {
    await ref.read(fridgeViewModelProvider.notifier).markAsEatenByName(name);
  }

  int get totalEaten => ref.read(fridgeViewModelProvider.notifier).totalEaten;
  int get totalSpoiled => ref.read(fridgeViewModelProvider.notifier).totalSpoiled;
  int get totalActive => ref.read(fridgeViewModelProvider.notifier).totalActive;
  int get totalProducts => ref.read(fridgeViewModelProvider.notifier).totalProducts;
}
