import 'package:food_save/core/architecture/base_repository.dart';

abstract class AuthRepository extends BaseRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> logout();
  Future<void> register(String username, String email, String password);
}

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await api.login(email, password);
    return response.data;
  }

  @override
  Future<void> logout() async {
    // Implement logout if needed (e.g., clear tokens)
  }

  @override
  Future<void> register(String username, String email, String password) async {
    await api.register(username, email, password);
  }
}
