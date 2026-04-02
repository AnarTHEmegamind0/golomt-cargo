import 'package:core/core/config/api_config.dart';
import 'package:core/core/networking/api_client.dart';
import 'package:core/core/networking/models/payment_model.dart';

/// Payment API Repository
class PaymentApiRepository {
  PaymentApiRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Create batch payment for cargos
  Future<ApiResult<CreatePaymentResponse>> createPayment({
    required List<String> cargoIds,
    required PaymentMethod method,
    String? note,
  }) async {
    return _apiClient.post(
      PaymentEndpoints.payments,
      data: {
        'cargoIds': cargoIds,
        'method': method.value,
        if (note != null) 'note': note,
      },
      fromJson: (json) =>
          CreatePaymentResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Search payments
  Future<ApiResult<PaymentListResponse>> searchPayments({
    PaymentApiStatus? status,
    PaymentMethod? method,
    String? paymentId,
    String? cargoId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status.value;
    if (method != null) queryParams['method'] = method.value;
    if (paymentId != null) queryParams['paymentId'] = paymentId;
    if (cargoId != null) queryParams['cargoId'] = cargoId;

    return _apiClient.get(
      PaymentEndpoints.search,
      queryParameters: queryParams.isEmpty ? null : queryParams,
      fromJson: (json) =>
          PaymentListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Mark payment as paid (Admin)
  Future<ApiResult<Map<String, dynamic>>> markPaymentPaid(
    String paymentId,
  ) async {
    return _apiClient.post(PaymentEndpoints.markPaid(paymentId));
  }
}
