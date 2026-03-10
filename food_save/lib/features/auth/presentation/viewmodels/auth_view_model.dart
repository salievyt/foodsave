import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/architecture/base_view_model.dart';
import 'package:food_save/core/services/persistence_helper.dart';
import 'package:food_save/features/auth/data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authViewModelProvider = NotifierProvider<AuthViewModel, BaseState<bool>>(() {
  return AuthViewModel();
});

class AuthViewModel extends BaseViewModel<bool> {
  late final AuthRepository _repository;

  @override
  bool get initialData => false;

  @override
  BaseState<bool> build() {
    _repository = ref.watch(authRepositoryProvider);
    return super.build();
  }

  Future<void> login(String email, String password) async {
    await safeExecute(() async {
      final data = await _repository.login(email, password);
      await PersistenceHelper.saveAuthTokens(data['access'], data['refresh']);
      updateData(true);
    });
  }

  Future<void> register(String username, String email, String password) async {
    await safeExecute(() async {
      await _repository.register(username, email, password);
      updateData(true);
    });
  }

  Future<void> logout() async {
    await PersistenceHelper.clearAuthTokens();
    updateData(false);
  }
}
