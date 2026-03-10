import 'package:food_save/features/fridge/domain/models/product.dart';

abstract class FridgeRepository {
  Future<List<Product>> getProducts();
  Future<void> saveProducts(List<Product> products);
  Future<void> addProduct(Map<String, dynamic> data);
  Future<void> updateProductStatus(String id, String status);
}
