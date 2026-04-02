/// Payment status enum
enum PaymentApiStatus {
  pending('PENDING'),
  paid('PAID'),
  failed('FAILED'),
  cancelled('CANCELLED'),
  refunded('REFUNDED');

  const PaymentApiStatus(this.value);
  final String value;

  static PaymentApiStatus fromString(String value) {
    return PaymentApiStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentApiStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case PaymentApiStatus.pending:
        return 'Хүлээгдэж буй';
      case PaymentApiStatus.paid:
        return 'Төлөгдсөн';
      case PaymentApiStatus.failed:
        return 'Амжилтгүй';
      case PaymentApiStatus.cancelled:
        return 'Цуцлагдсан';
      case PaymentApiStatus.refunded:
        return 'Буцаагдсан';
    }
  }
}

/// Payment method enum
enum PaymentMethod {
  app('APP'),
  cashInPerson('CASH_IN_PERSON');

  const PaymentMethod(this.value);
  final String value;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.app,
    );
  }

  String get label {
    switch (this) {
      case PaymentMethod.app:
        return 'Апп-аар';
      case PaymentMethod.cashInPerson:
        return 'Бэлнээр';
    }
  }
}

/// Payment model from API
class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.customerId,
    required this.status,
    required this.method,
    required this.totalAmountMnt,
    required this.currency,
    required this.createdAt,
    this.paidAt,
    this.note,
    this.cargoIds,
  });

  final String id;
  final String customerId;
  final PaymentApiStatus status;
  final PaymentMethod method;
  final int totalAmountMnt;
  final String currency;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? note;
  final List<String>? cargoIds;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      status: PaymentApiStatus.fromString(json['status'] as String),
      method: PaymentMethod.fromString(json['method'] as String),
      totalAmountMnt: _asInt(json['totalAmountMnt']) ?? 0,
      currency: json['currency'] as String? ?? 'MNT',
      createdAt: DateTime.parse(json['createdAt'] as String),
      paidAt: _asDateTime(json['paidAt']),
      note: json['note'] as String?,
      cargoIds: (json['cargoIds'] as List?)?.cast<String>(),
    );
  }
}

/// Create payment response
class CreatePaymentResponse {
  const CreatePaymentResponse({
    required this.message,
    required this.paymentId,
    required this.totalAmountMnt,
    required this.cargoCount,
  });

  final String message;
  final String paymentId;
  final int totalAmountMnt;
  final int cargoCount;

  factory CreatePaymentResponse.fromJson(Map<String, dynamic> json) {
    return CreatePaymentResponse(
      message: json['message'] as String,
      paymentId: json['paymentId'] as String,
      totalAmountMnt: _asInt(json['totalAmountMnt']) ?? 0,
      cargoCount: _asInt(json['cargoCount']) ?? 0,
    );
  }
}

/// Payment list response
class PaymentListResponse {
  const PaymentListResponse({required this.message, required this.data});

  final String message;
  final List<PaymentModel> data;

  factory PaymentListResponse.fromJson(Map<String, dynamic> json) {
    return PaymentListResponse(
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _asDateTime(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
