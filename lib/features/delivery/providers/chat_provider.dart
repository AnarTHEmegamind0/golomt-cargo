import 'dart:async';

import 'package:core/features/delivery/models/chat_message.dart';
import 'package:core/features/delivery/services/chat_service.dart';
import 'package:flutter/foundation.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({required ChatService chatService}) : _chatService = chatService;

  final ChatService _chatService;

  StreamSubscription<List<ChatMessage>>? _subscription;
  List<ChatMessage> _messages = const [];

  List<ChatMessage> get messages => _messages;

  void watch(String orderId) {
    _subscription?.cancel();
    _subscription = _chatService.watchMessages(orderId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  Future<void> send({required String orderId, required String text}) {
    return _chatService.sendMessage(
      orderId: orderId,
      sender: 'Жолооч',
      text: text,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
