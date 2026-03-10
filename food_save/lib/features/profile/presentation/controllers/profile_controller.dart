import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/features/profile/presentation/viewmodels/profile_view_model.dart';

class ProfileState {
  final UserProfile? data;
  final bool isLoading;
  final Object? error;

  ProfileState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? data,
    bool? isLoading,
    Object? error,
  }) {
    return ProfileState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final userProfileProvider = NotifierProvider<UserProfileController, ProfileState>(() {
  return UserProfileController();
});

class UserProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    final vmState = ref.watch(profileViewModelProvider);
    return ProfileState(
      data: vmState.data,
      isLoading: vmState.isLoading,
      error: vmState.error,
    );
  }

  Future<void> fetchProfile() async {
    await ref.read(profileViewModelProvider.notifier).fetchProfile();
  }

  Future<void> updateProfileField(Map<String, dynamic> data) async {
    await ref.read(profileViewModelProvider.notifier).updateProfileField(data);
  }

  Future<void> uploadAvatar(String path) async {
    await ref.read(profileViewModelProvider.notifier).uploadAvatar(path);
  }

  Future<void> updatePreferences(String prefs) async {
    await ref.read(profileViewModelProvider.notifier).updatePreferences(prefs);
  }

  Future<void> updateAllergies(String allergies) async {
    await ref.read(profileViewModelProvider.notifier).updateAllergies(allergies);
  }
}
