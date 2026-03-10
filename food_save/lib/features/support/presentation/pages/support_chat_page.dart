import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/core/widgets/base_page.dart';
import 'package:food_save/features/support/presentation/controllers/support_chat_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_save/core/router/app_router.gr.dart';

@RoutePage()
class SupportChatPage extends ConsumerStatefulWidget {
  const SupportChatPage({super.key});

  @override
  ConsumerState<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends ConsumerState<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  WebSocketChannel? _channel;
  bool _needsAuth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChat();
    });
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() => _needsAuth = true);
      }
      return;
    }

    await ref.read(supportChatControllerProvider.notifier).fetchMessages();
    await _connectWebSocket(token);
    _scrollToBottom();
  }

  Future<void> _connectWebSocket(String token) async {
    try {
      if (mounted && _needsAuth) {
        setState(() => _needsAuth = false);
      }

      final wsBase = dotenv.env['WS_BASE_URL'] ?? 'ws://127.0.0.1:8000';
      final url = '$wsBase/ws/support_chat/?token=$token';
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen((message) {
        final decodedMessage = jsonDecode(message);
        final text = decodedMessage['message'];
        final fromSupport = decodedMessage['is_from_support'] ?? true;

        if (mounted) {
          ref.read(supportChatControllerProvider.notifier).addMessage({
            'isUser': !fromSupport,
            'text': text,
            'time': DateFormat('HH:mm').format(DateTime.now()),
          });
          _scrollToBottom();
        }
      }, onError: (err) {
        debugPrint("WS Error: $err");
      });
    } catch (e) {
      debugPrint("WS Connect Error: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_channel != null) {
      _channel!.sink.add(jsonEncode({'message': text}));
      
      ref.read(supportChatControllerProvider.notifier).addMessage({
        'isUser': true,
        'text': text,
        'time': DateFormat('HH:mm').format(DateTime.now())
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SupportChatPageContent(
      ref: ref,
      scrollController: _scrollController,
      messageController: _messageController,
      onSendMessage: _sendMessage,
      needsAuth: _needsAuth,
    );
  }
}

class _SupportChatPageContent extends BasePage {
  final WidgetRef ref;
  final ScrollController scrollController;
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final bool needsAuth;

  const _SupportChatPageContent({
    required this.ref,
    required this.scrollController,
    required this.messageController,
    required this.onSendMessage,
    required this.needsAuth,
  });

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Тех. Поддержка'),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final chatState = ref.watch(supportChatControllerProvider);
    final theme = Theme.of(context);

    if (chatState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (needsAuth) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Требуется вход для чата поддержки',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.navigateTo(const LoginRoute()),
                  child: const Text('Войти'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: chatState.data.length,
            itemBuilder: (context, index) {
              final message = chatState.data[index];
              final isUser = message['isUser'] as bool;

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : theme.cardColor,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['text'] as String,
                        style: TextStyle(
                          color: isUser ? Colors.white : theme.colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message['time'] as String,
                        style: TextStyle(
                          color: isUser ? Colors.white70 : theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Введите сообщение...',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => onSendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onSendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
