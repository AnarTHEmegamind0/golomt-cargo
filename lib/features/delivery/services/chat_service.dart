import 'dart:async';

import 'package:core/features/delivery/models/chat_message.dart';

class ChatService {
  final _controller = StreamController<List<ChatMessage>>.broadcast();
  final List<ChatMessage> _messages = <ChatMessage>[];

  Stream<List<ChatMessage>> watchMessages(String orderId) {
    Future<void>.microtask(() {
      _controller.add(
        _messages.where((message) => message.orderId == orderId).toList(),
      );
    });
    return _controller.stream;
  }

  Future<void> sendMessage({
    required String orderId,
    required String sender,
    required String text,
  }) async {
    _messages.add(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        orderId: orderId,
        sender: sender,
        text: text,
        sentAt: DateTime.now(),
      ),
    );

    _controller.add(
      _messages.where((message) => message.orderId == orderId).toList(),
    );
  }

  void dispose() {
    _controller.close();
  }
}
