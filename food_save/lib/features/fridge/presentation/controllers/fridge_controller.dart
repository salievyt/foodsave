import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/services/api_service.dart';
import 'package:food_save/core/utils/emoji_helper.dart';
import 'package:food_save/core/services/local_storage_service.dart';
import 'package:food_save/core/services/notification_service.dart';
import '../../domain/models/product.dart';

final fridgeSearchProvider = StateProvider<String>((ref) => '');
final fridgeCategoryProvider = StateProvider<String>((ref) => 'Все');

final filteredFridgeProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(fridgeControllerProvider);
  final search = ref.watch(fridgeSearchProvider).toLowerCase();
  final category = ref.watch(fridgeCategoryProvider);

  var result = products.where((p) => !p.isEaten && !p.isSpoiled).toList();

  if (category != 'Все') {
    result = result.where((p) => p.category == category).toList();
  }

  if (search.isNotEmpty) {
    result = result.where((p) => p.name.toLowerCase().contains(search)).toList();
  }

  // Сортировка по сроку годности: сначала самые срочные
  result.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

  return result;
});

final fridgeControllerProvider = NotifierProvider<FridgeController, List<Product>>(() {
  return FridgeController();
});

class FridgeController extends Notifier<List<Product>> {
  final ApiService _api = ApiService();

  @override
  List<Product> build() {
    _loadCachedThenFetch();
    return [];
  }

  Future<void> _loadCachedThenFetch() async {
    // Load from cache first (offline support)
    try {
      final cached = await LocalStorageService.loadProducts();
      if (cached.isNotEmpty && state.isEmpty) {
        state = cached;
      }
    } catch (_) {}

    // Then fetch from server
    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await _api.getProducts();
      if (response.statusCode == 200) {
        final List data = response.data;
        state = data.map((e) {
          final expDateStr = e['expiration_date'] as String;
          final addDateStr = e['added_date'] as String;
          final category = e['category_detail']?['name'] ?? "Другое";
          return Product(
            id: e['id'].toString(),
            name: e['name'],
            category: category,
            emoji: EmojiHelper.getEmoji(category),
            purchaseDate: DateTime.parse(addDateStr),
            expiryDate: DateTime.parse(expDateStr),
            isEaten: e['status'] == 'CONSUMED',
            isSpoiled: e['status'] == 'WASTED',
          );
        }).toList();

        // Save to cache
        await LocalStorageService.saveProducts(state);

        // Schedule expiry notifications
        NotificationService.scheduleExpiryNotifications(state);
      }
    } catch (e) {
      // If network fails, keep cached data
      print("Error fetching products: $e");
    }
  }

  void addProducts(List<Product> products) {
    state = [...state, ...products];
    _saveCache();
    for (final p in products) {
      _api.addProduct({
        'name': p.name,
        'expiration_date': p.expiryDate.toIso8601String().split('T')[0],
        'status': 'ACTIVE',
        'quantity': 1,
        'unit': 'PCS',
      });
    }
  }

  void addProduct(Product product) {
    state = [...state, product];
    _saveCache();
    _api.addProduct({
      'name': product.name,
      'expiration_date': product.expiryDate.toIso8601String().split('T')[0],
      'status': 'ACTIVE',
      'quantity': 1,
      'unit': 'PCS',
    });
  }

  void markAsEaten(String id) {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(isEaten: true) else p
    ];
    _saveCache();
    _api.updateProductStatus(id, 'CONSUMED');
  }

  void markAsSpoiled(String id) {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(isSpoiled: true) else p
    ];
    _saveCache();
    _api.updateProductStatus(id, 'WASTED');
  }

  /// Restore a product after undo (swipe undo)
  void restoreProduct(Product product) {
    state = [
      for (final p in state)
        if (p.id == product.id) product.copyWith(isEaten: false, isSpoiled: false) else p
    ];
    _saveCache();
    _api.updateProductStatus(product.id, 'ACTIVE');
  }

  void markAsEatenByName(String name) {
    final productsToUpdate = state.where((p) => p.name.toLowerCase() == name.toLowerCase() && !p.isEaten && !p.isSpoiled).toList();
    
    state = [
      for (final p in state)
        if (p.name.toLowerCase() == name.toLowerCase() && !p.isEaten && !p.isSpoiled)
          p.copyWith(isEaten: true)
        else
          p
    ];

    _saveCache();
    for (var p in productsToUpdate) {
      _api.updateProductStatus(p.id, 'CONSUMED');
    }
  }

  void removeProduct(String id) {
    state = state.where((p) => p.id != id).toList();
    _saveCache();
  }

  /// Statistics helpers
  int get totalEaten => state.where((p) => p.isEaten).length;
  int get totalSpoiled => state.where((p) => p.isSpoiled).length;
  int get totalActive => state.where((p) => !p.isEaten && !p.isSpoiled).length;
  int get totalProducts => state.length;

  Future<void> _saveCache() async {
    try {
      await LocalStorageService.saveProducts(state);
    } catch (_) {}
  }
}
