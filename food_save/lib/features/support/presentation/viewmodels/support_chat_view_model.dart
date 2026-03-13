import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:food_save/features/support/data/repositories/support_repository_impl.dart';
import 'package:intl/intl.dart';

part 'support_chat_view_model.g.dart';

@riverpod
SupportRepository supportRepository(Ref ref) {
  return SupportRepositoryImpl();
}

@riverpod
class SupportChatViewModel extends _$SupportChatViewModel {
  late SupportRepository _repository;

  @override
  AsyncValue<List<Map<String, dynamic>>> build() {
    _repository = ref.watch(supportRepositoryProvider);
    fetchMessages();
    return const AsyncValue.loading();
  }

  Future<void> fetchMessages() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getSupportMessages();
      final messages = data.map((item) {
        final date = DateTime.parse(item['created_at']).toLocal();
        return {
          'isUser': item['is_from_user'],
          'text': item['text'],
          'time': DateFormat('HH:mm').format(date),
        };
      }).toList();
      state = AsyncValue.data(messages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addMessage(Map<String, dynamic> message) {
    final currentMessages = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentMessages, message]);
  }
}
