import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:food_save/features/profile/data/repositories/profile_repository_impl.dart';

part 'profile_view_model.g.dart';

class UserProfile {
  final String username;
  final String? email;
  final String? avatarUrl;
  final String dietaryPreferences;
  final String allergies;

  UserProfile({
    required this.username,
    this.email,
    this.avatarUrl,
    required this.dietaryPreferences,
    required this.allergies,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatar'],
      dietaryPreferences: json['dietary_preferences'] ?? '',
      allergies: json['allergies'] ?? '',
    );
  }
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl();
}

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  late ProfileRepository _repository;

  @override
  AsyncValue<UserProfile?> build() {
    _repository = ref.watch(profileRepositoryProvider);
    Future.microtask(fetchProfile);
    return const AsyncValue.data(null);
  }

  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getProfile();
      state = AsyncValue.data(UserProfile.fromJson(data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfileField(Map<String, dynamic> data) async {
    try {
      await _repository.updateProfile(data);
      await fetchProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> uploadAvatar(String path) async {
    try {
      await _repository.uploadAvatar(path);
      await fetchProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePreferences(String prefs) async {
    await updateProfileField({'dietary_preferences': prefs});
  }

  Future<void> updateAllergies(String allergies) async {
    await updateProfileField({'allergies': allergies});
  }

  Future<void> updateProfile({
    String? username,
    String? email,
    String? allergies,
    String? dietaryPreferences,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (allergies != null) data['allergies'] = allergies;
    if (dietaryPreferences != null) data['dietary_preferences'] = dietaryPreferences;
    
    if (data.isNotEmpty) {
      await updateProfileField(data);
    }
  }
}
