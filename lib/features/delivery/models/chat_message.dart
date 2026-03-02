class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.orderId,
    required this.sender,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String orderId;
  final String sender;
  final String text;
  final DateTime sentAt;
}
