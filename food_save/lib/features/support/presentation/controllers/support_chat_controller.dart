import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/features/support/presentation/viewmodels/support_chat_view_model.dart';
import 'package:food_save/core/architecture/base_view_model.dart';

final supportChatControllerProvider = NotifierProvider<SupportChatController, BaseState<List<Map<String, dynamic>>>>(() {
  return SupportChatController();
});

class SupportChatController extends Notifier<BaseState<List<Map<String, dynamic>>>> {
  @override
  BaseState<List<Map<String, dynamic>>> build() {
    return ref.watch(supportChatViewModelProvider);
  }

  Future<void> fetchMessages() async {
    await ref.read(supportChatViewModelProvider.notifier).fetchMessages();
  }

  void addMessage(Map<String, dynamic> message) {
    ref.read(supportChatViewModelProvider.notifier).addMessage(message);
  }
}
