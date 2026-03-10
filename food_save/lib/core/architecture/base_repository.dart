import 'package:food_save/core/services/api_service.dart';
import 'package:food_save/core/services/local_storage_service.dart';

/// Base class for all repositories to provide access to shared services.
abstract class BaseRepository {
  final ApiService api = ApiService();
  final LocalStorageService storage = LocalStorageService();
}
