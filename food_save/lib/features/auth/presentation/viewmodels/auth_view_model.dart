import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/architecture/base_view_model.dart';
import 'package:food_save/core/services/persistence_helper.dart';
import 'package:food_save/features/auth/data/repositories/auth_repository_impl.dart';
import 'dart:math';

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
      await PersistenceHelper.setIsGuest(false);
      updateData(true);
    });
  }

  Future<void> register(String username, String email, String password) async {
    await safeExecute(() async {
      await _repository.register(username, email, password);
      await PersistenceHelper.setIsGuest(false);
      updateData(true);
    });
  }

  Future<void> loginAsGuest() async {
    await safeExecute(() async {
      final suffix = DateTime.now().millisecondsSinceEpoch.toString();
      final rand = Random().nextInt(9999).toString().padLeft(4, '0');
      final username = 'guest_$suffix$rand';
      final email = 'guest_$suffix$rand@foodsave.local';
      final password = 'guest_$suffix$rand';

      final data = await _repository.registerAndLogin(username, email, password);
      await PersistenceHelper.saveAuthTokens(data['access'], data['refresh']);
      await PersistenceHelper.setIsGuest(true);
      updateData(true);
    });
  }

  Future<void> logout() async {
    await PersistenceHelper.clearAuthTokens();
    updateData(false);
  }
}
