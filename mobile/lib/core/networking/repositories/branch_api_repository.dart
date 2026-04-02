import 'package:core/core/config/api_config.dart';
import 'package:core/core/networking/api_client.dart';
import 'package:core/core/networking/models/branch_model.dart';

/// Branch API Repository
class BranchApiRepository {
  BranchApiRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Get all active branches
  Future<ApiResult<BranchListResponse>> getBranches() async {
    return _apiClient.get(
      BranchEndpoints.branches,
      fromJson: (json) =>
          BranchListResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
