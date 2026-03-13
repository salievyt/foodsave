import 'package:food_save/core/architecture/base_repository.dart';
import 'package:food_save/core/utils/emoji_helper.dart';
import 'package:food_save/features/fridge/domain/models/product.dart';
import 'package:food_save/features/fridge/domain/repositories/fridge_repository.dart';
import 'package:food_save/core/services/local_storage_service.dart';

class FridgeRepositoryImpl extends BaseRepository implements FridgeRepository {
  @override
  Future<List<Product>> getProducts() async {
    final response = await api.getProducts();
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((e) {
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
    }
    return [];
  }

  @override
  Future<void> saveProducts(List<Product> products) async {
    await LocalStorageService.saveProducts(products);
  }

  @override
  Future<void> addProduct(Map<String, dynamic> data) async {
    await api.addProduct(data);
  }

  @override
  Future<void> updateProductStatus(String id, String status) async {
    await api.updateProductStatus(id, status);
  }
}
