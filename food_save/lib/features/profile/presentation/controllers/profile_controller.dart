import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/services/api_service.dart';

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

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  UserProfileNotifier() : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  final ApiService _api = ApiService();

  Future<void> fetchProfile() async {
    try {
      final response = await _api.getProfile();
      if (response.statusCode == 200) {
        state = AsyncValue.data(UserProfile.fromJson(response.data));
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> updateProfileField(Map<String, dynamic> data) async {
    try {
      final response = await _api.updateProfile(data);
      if (response.statusCode == 200) {
        fetchProfile();
      }
    } catch (e) {
      print("Update profile field error: $e");
    }
  }

  Future<void> uploadAvatar(String path) async {
    try {
      final response = await _api.uploadAvatar(path);
      if (response.statusCode == 200) {
        fetchProfile();
      }
    } catch (e) {
      print("Upload avatar error: $e");
    }
  }

  Future<void> updatePreferences(String prefs) async {
    await updateProfileField({'dietary_preferences': prefs});
  }

  Future<void> updateAllergies(String allergies) async {
    await updateProfileField({'allergies': allergies});
  }
}
