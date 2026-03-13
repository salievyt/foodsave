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

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => print(obj),
    ));

    _dio.interceptors.add(AuthInterceptor());
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

/// Interceptor для автоматического обновления JWT токена
class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<_QueuedRequest> _queuedRequests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await PersistenceHelper.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Пробуем обновить токен
      final refreshed = await _refreshToken();
      
      if (refreshed) {
        // Повторяем оригинальный запрос с новым токеном
        try {
          final opts = err.requestOptions;
          final newToken = await PersistenceHelper.getAccessToken();
          opts.headers['Authorization'] = 'Bearer $newToken';
          
          final dio = Dio(BaseOptions(
            baseUrl: opts.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ));
          
          final response = await dio.fetch(opts);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // Не удалось обновить токен - очищаем и возвращаем ошибку
        await PersistenceHelper.clearAuthTokens();
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;
    
    _isRefreshing = true;
    
    try {
      final refreshToken = await PersistenceHelper.getRefreshToken();
      if (refreshToken == null) {
        _isRefreshing = false;
        return false;
      }

      final dio = Dio(BaseOptions(
        baseUrl: ApiService()._dio.options.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.post('/auth/login/refresh/', data: {
        'refresh': refreshToken,
      });

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await PersistenceHelper.saveAuthTokens(newAccessToken, refreshToken);
        _isRefreshing = false;
        return true;
      }
    } catch (e) {
      // Ошибка при refresh - токен недействителен
    }
    
    _isRefreshing = false;
    return false;
  }
}

class _QueuedRequest {
  final RequestOptions options;
  final ResponseInterceptorHandler handler;

  _QueuedRequest(this.options, this.handler);
}
