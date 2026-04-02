import 'package:core/core/config/api_config.dart';
import 'package:core/core/networking/api_client.dart';
import 'package:core/core/networking/models/cargo_model.dart';

/// Cargo API Repository
class CargoApiRepository {
  CargoApiRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Create a new cargo
  Future<ApiResult<CargoResponse>> createCargo({
    required String trackingNumber,
    String? description,
  }) async {
    return _apiClient.post(
      CargoEndpoints.cargos,
      data: {
        'trackingNumber': trackingNumber,
        if (description != null) 'description': description,
      },
      fromJson: (json) => CargoResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get all cargos with optional filters
  Future<ApiResult<CargoListResponse>> getCargos({
    CargoStatus? status,
    PaymentStatus? paymentStatus,
    FulfillmentType? fulfillmentType,
    String? trackingNumber,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) {
      queryParams['status'] = status.value;
    }
    if (paymentStatus != null) {
      queryParams['paymentStatus'] = paymentStatus.value;
    }
    if (fulfillmentType != null) {
      queryParams['fulfillmentType'] = fulfillmentType.value;
    }
    if (trackingNumber != null) {
      queryParams['trackingNumber'] = trackingNumber;
    }

    return _apiClient.get(
      CargoEndpoints.cargos,
      queryParameters: queryParams.isEmpty ? null : queryParams,
      fromJson: (json) =>
          CargoListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get cargo by ID
  Future<ApiResult<CargoResponse>> getCargoById(String cargoId) async {
    return _apiClient.get(
      CargoEndpoints.cargoById(cargoId),
      fromJson: (json) => CargoResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Search cargos
  Future<ApiResult<CargoListResponse>> searchCargos({
    required String query,
    CargoStatus? status,
    PaymentStatus? paymentStatus,
    FulfillmentType? fulfillmentType,
  }) async {
    final queryParams = <String, dynamic>{'q': query};
    if (status != null) {
      queryParams['status'] = status.value;
    }
    if (paymentStatus != null) {
      queryParams['paymentStatus'] = paymentStatus.value;
    }
    if (fulfillmentType != null) {
      queryParams['fulfillmentType'] = fulfillmentType.value;
    }

    return _apiClient.get(
      CargoEndpoints.search,
      queryParameters: queryParams,
      fromJson: (json) =>
          CargoListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get cargo statistics
  Future<ApiResult<CargoStatsResponse>> getCargoStats() async {
    return _apiClient.get(
      CargoEndpoints.stats,
      fromJson: (json) =>
          CargoStatsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get cargo events (timeline)
  Future<ApiResult<CargoEventsResponse>> getCargoEvents(String cargoId) async {
    return _apiClient.get(
      CargoEndpoints.events(cargoId),
      fromJson: (json) =>
          CargoEventsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Choose fulfillment method (pickup or delivery)
  Future<ApiResult<Map<String, dynamic>>> chooseFulfillment({
    required String cargoId,
    required FulfillmentType fulfillmentType,
    String? deliveryAddress,
    String? deliveryPhone,
  }) async {
    return _apiClient.post(
      CargoEndpoints.fulfillmentChoice(cargoId),
      data: {
        'fulfillmentType': fulfillmentType.value,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        if (deliveryPhone != null) 'deliveryPhone': deliveryPhone,
      },
    );
  }

  /// Get received image URL
  Future<ApiResult<Map<String, dynamic>>> getReceivedImage(
    String cargoId,
  ) async {
    return _apiClient.get(CargoEndpoints.receivedImage(cargoId));
  }

  // Admin endpoints

  /// Mark cargo as received in China (Admin)
  Future<ApiResult<Map<String, dynamic>>> markReceived({
    required String cargoId,
    String? image,
  }) async {
    return _apiClient.post(
      CargoEndpoints.receive(cargoId),
      data: {if (image != null) 'image': image},
    );
  }

  /// Mark cargo as shipped to Mongolia (Admin)
  Future<ApiResult<Map<String, dynamic>>> markShipped(String cargoId) async {
    return _apiClient.post(CargoEndpoints.ship(cargoId));
  }

  /// Mark cargo as arrived in Mongolia (Admin)
  Future<ApiResult<Map<String, dynamic>>> markArrived(String cargoId) async {
    return _apiClient.post(CargoEndpoints.arrive(cargoId));
  }

  /// Record weight and fee (Admin)
  Future<ApiResult<Map<String, dynamic>>> recordWeight({
    required String cargoId,
    required int weightGrams,
    required int baseShippingFeeMnt,
  }) async {
    return _apiClient.post(
      CargoEndpoints.recordWeight(cargoId),
      data: {
        'weightGrams': weightGrams,
        'baseShippingFeeMnt': baseShippingFeeMnt,
      },
    );
  }
}
