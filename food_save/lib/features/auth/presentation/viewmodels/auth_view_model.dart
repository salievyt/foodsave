import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:food_save/core/services/persistence_helper.dart';
import 'package:food_save/features/auth/data/repositories/auth_repository_impl.dart';
import 'dart:math';

part 'auth_view_model.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl();
}

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late AuthRepository _repository;

  @override
  AsyncValue<bool> build() {
    _repository = ref.watch(authRepositoryProvider);
    return const AsyncValue.data(false);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.login(email, password);
      await PersistenceHelper.saveAuthTokens(data['access'], data['refresh']);
      await PersistenceHelper.setIsGuest(false);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.register(username, email, password);
      await PersistenceHelper.setIsGuest(false);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginAsGuest() async {
    state = const AsyncValue.loading();
    try {
      final suffix = DateTime.now().millisecondsSinceEpoch.toString();
      final rand = Random().nextInt(9999).toString().padLeft(4, '0');
      final username = 'guest_$suffix$rand';
      final email = 'guest_$suffix$rand@foodsave.local';
      final password = 'guest_$suffix$rand';

      final data = await _repository.registerAndLogin(username, email, password);
      await PersistenceHelper.saveAuthTokens(data['access'], data['refresh']);
      await PersistenceHelper.setIsGuest(true);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await PersistenceHelper.clearAuthTokens();
    state = const AsyncValue.data(false);
  }
}
