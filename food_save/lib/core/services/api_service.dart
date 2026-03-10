import 'package:dio/dio.dart';
import 'package:food_save/core/services/persistence_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  // Use 127.0.0.1 for iOS Simulator, 10.0.2.2 for Android Emulator
  // For production, set API_BASE_URL in .env
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api';

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await PersistenceHelper.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, could implement refresh logic here
        }
        return handler.next(e);
      },
    ));
  }

  // Auth
  Future<Response> login(String username, String password) async {
    return _dio.post('/auth/login/', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Response> register(String username, String email, String password) async {
    return _dio.post('/auth/register/', data: {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  // Fridge
  Future<Response> getProducts() async {
    return _dio.get('/fridge/products/');
  }

  Future<Response> scanReceipt(String imagePath) async {
    FormData formData = FormData.fromMap({
      "receipt_image": await MultipartFile.fromFile(imagePath, filename: "receipt.jpg"),
    });
    return _dio.post('/fridge/products/scan-receipt/', data: formData);
  }

  Future<Response> addProduct(Map<String, dynamic> data) async {
    return _dio.post('/fridge/products/', data: data);
  }

  Future<Response> updateProductStatus(String id, String status) async {
    return _dio.patch('/fridge/products/$id/', data: {'status': status});
  }

  // Profile
  Future<Response> getProfile() async {
    return _dio.get('/auth/profile/');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return _dio.patch('/auth/profile/', data: data);
  }

  Future<Response> uploadAvatar(String imagePath) async {
    FormData formData = FormData.fromMap({
      "avatar": await MultipartFile.fromFile(imagePath, filename: "avatar.jpg"),
    });
    return _dio.patch('/auth/profile/', data: formData);
  }

  // Recipes
  Future<Response> getRecipes() async {
    return _dio.get('/recipes/');
  }

  // Notifications
  Future<Response> getSupportMessages() async {
    return _dio.get('/notifications/support-chat/');
  }
}
