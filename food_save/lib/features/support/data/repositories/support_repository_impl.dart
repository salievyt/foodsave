import 'package:food_save/core/architecture/base_repository.dart';

abstract class SupportRepository extends BaseRepository {
  Future<List<Map<String, dynamic>>> getSupportMessages();
}

class SupportRepositoryImpl extends SupportRepository {
  @override
  Future<List<Map<String, dynamic>>> getSupportMessages() async {
    final response = await api.getSupportMessages();
    return List<Map<String, dynamic>>.from(response.data);
  }
}
