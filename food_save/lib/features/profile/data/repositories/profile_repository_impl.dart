import 'package:food_save/core/architecture/base_repository.dart';

abstract class ProfileRepository extends BaseRepository {
  Future<Map<String, dynamic>> getProfile();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<void> uploadAvatar(String imagePath);
}

class ProfileRepositoryImpl extends ProfileRepository {
  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await api.getProfile();
    return response.data;
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    await api.updateProfile(data);
  }

  @override
  Future<void> uploadAvatar(String imagePath) async {
    await api.uploadAvatar(imagePath);
  }
}
