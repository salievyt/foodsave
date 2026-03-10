import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/architecture/base_view_model.dart';
import 'package:food_save/features/support/data/repositories/support_repository_impl.dart';
import 'package:intl/intl.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepositoryImpl();
});

final supportChatViewModelProvider = NotifierProvider<SupportChatViewModel, BaseState<List<Map<String, dynamic>>>>(() {
  return SupportChatViewModel();
});

class SupportChatViewModel extends BaseViewModel<List<Map<String, dynamic>>> {
  late final SupportRepository _repository;

  @override
  List<Map<String, dynamic>> get initialData => [];

  @override
  BaseState<List<Map<String, dynamic>>> build() {
    _repository = ref.watch(supportRepositoryProvider);
    return super.build();
  }

  Future<void> fetchMessages() async {
    await safeExecute(() async {
      final data = await _repository.getSupportMessages();
      final messages = data.map((item) {
        final date = DateTime.parse(item['created_at']).toLocal();
        return {
          'isUser': item['is_from_user'],
          'text': item['text'],
          'time': DateFormat('HH:mm').format(date),
        };
      }).toList();
      updateData(messages);
    });
  }

  void addMessage(Map<String, dynamic> message) {
    updateData([...state.data, message]);
  }
}
