import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base state for all feature notifiers.
class BaseState<T> {
  final T data;
  final bool isLoading;
  final Object? error;

  BaseState({
    required this.data,
    this.isLoading = false,
    this.error,
  });

  BaseState<T> copyWith({
    T? data,
    bool? isLoading,
    Object? error,
  }) {
    return BaseState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error, // If error is not passed, it becomes null
    );
  }
}

/// Base class for all feature view models.
abstract class BaseViewModel<T> extends Notifier<BaseState<T>> {
  @override
  BaseState<T> build() {
    return BaseState(data: initialData);
  }

  T get initialData;

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(Object? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void updateData(T data) {
    state = state.copyWith(data: data, isLoading: false, error: null);
  }

  /// Safe execution wrapper for async tasks.
  Future<void> safeExecute(Future<void> Function() task) async {
    try {
      setLoading(true);
      await task();
    } catch (e) {
      setError(e);
    } finally {
      setLoading(false);
    }
  }
}
