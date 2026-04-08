/// Activity log for admin actions
class AdminActivityLog {
  const AdminActivityLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.targetType,
    this.targetId,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  final String id;
  final String adminId;
  final String adminName;
  final String action;
  final String targetType;
  final String? targetId;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  factory AdminActivityLog.fromJson(Map<String, dynamic> json) {
    return AdminActivityLog(
      id: json['id'] as String,
      adminId: json['admin_id'] as String,
      adminName: json['admin_name'] as String? ?? 'Unknown',
      action: json['action'] as String,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String?,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'admin_name': adminName,
      'action': action,
      'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Get action label in Mongolian
  String get actionLabel {
    return switch (action) {
      'CREATE' => 'Үүсгэсэн',
      'UPDATE' => 'Шинэчилсэн',
      'DELETE' => 'Устгасан',
      'STATUS_CHANGE' => 'Төлөв өөрчилсөн',
      'RECEIVE' => 'Хүлээн авсан',
      'SHIP' => 'Ачилт илгээсэн',
      'ARRIVE' => 'Ирсэн болгосон',
      'BAN' => 'Хориглосон',
      'UNBAN' => 'Хориг нээсэн',
      'ROLE_CHANGE' => 'Эрх өөрчилсөн',
      'PRICE_OVERRIDE' => 'Үнэ өөрчилсөн',
      'WEIGHT_RECORD' => 'Жин бүртгэсэн',
      'IMPORT' => 'Импорт хийсэн',
      _ => action,
    };
  }

  /// Get target type label in Mongolian
  String get targetTypeLabel {
    return switch (targetType) {
      'CARGO' => 'Бараа',
      'USER' => 'Хэрэглэгч',
      'SHIPMENT' => 'Ачилт',
      'VEHICLE' => 'Машин',
      'BRANCH' => 'Салбар',
      _ => targetType,
    };
  }

  /// Formatted timestamp display
  String get timeDisplay {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Саяхан';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин';
    if (diff.inHours < 24) return '${diff.inHours} цаг';
    if (diff.inDays < 7) return '${diff.inDays} өдөр';
    return '${createdAt.month}/${createdAt.day}';
  }

  @override
  String toString() => 'Log($action on $targetType by $adminName)';
}
