import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/features/auth/presentation/viewmodels/auth_view_model.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class AuthState {
  final bool data;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    this.data = false,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? data,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      data: data ?? this.data,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authViewModelProvider.notifier).login(email, password);
      final vmState = ref.read(authViewModelProvider);
      state = state.copyWith(
        data: vmState.data,
        isAuthenticated: vmState.data,
        isLoading: false,
        error: vmState.error?.toString(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authViewModelProvider.notifier).register(username, email, password);
      state = state.copyWith(data: true, isAuthenticated: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loginAsGuest() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authViewModelProvider.notifier).loginAsGuest();
      final vmState = ref.read(authViewModelProvider);
      state = state.copyWith(
        data: vmState.data,
        isAuthenticated: vmState.data,
        isLoading: false,
        error: vmState.error?.toString(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await ref.read(authViewModelProvider.notifier).logout();
    state = AuthState();
  }
}
