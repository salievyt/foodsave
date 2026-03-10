import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/architecture/base_view_model.dart';
import 'package:food_save/features/profile/data/repositories/profile_repository_impl.dart';

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

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

final profileViewModelProvider = NotifierProvider<ProfileViewModel, BaseState<UserProfile?>>(() {
  return ProfileViewModel();
});

class ProfileViewModel extends BaseViewModel<UserProfile?> {
  late final ProfileRepository _repository;

  @override
  UserProfile? get initialData => null;

  @override
  BaseState<UserProfile?> build() {
    _repository = ref.watch(profileRepositoryProvider);
    final initial = super.build();
    Future.microtask(fetchProfile);
    return initial;
  }

  Future<void> fetchProfile() async {
    await safeExecute(() async {
      final data = await _repository.getProfile();
      updateData(UserProfile.fromJson(data));
    });
  }

  Future<void> updateProfileField(Map<String, dynamic> data) async {
    await safeExecute(() async {
      await _repository.updateProfile(data);
      await fetchProfile();
    });
  }

  Future<void> uploadAvatar(String path) async {
    await safeExecute(() async {
      await _repository.uploadAvatar(path);
      await fetchProfile();
    });
  }

  Future<void> updatePreferences(String prefs) async {
    await updateProfileField({'dietary_preferences': prefs});
  }

  Future<void> updateAllergies(String allergies) async {
    await updateProfileField({'allergies': allergies});
  }
}
