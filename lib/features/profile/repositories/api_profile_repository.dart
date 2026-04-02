import 'package:core/core/networking/app_api_operations.dart';
import 'package:core/core/networking/api_parsing.dart';
import 'package:core/core/networking/openapi_client.dart';
import 'package:core/features/profile/models/profile.dart';
import 'package:core/features/profile/repositories/profile_repository.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository({required OpenApiClient openApiClient})
    : _openApiClient = openApiClient;

  final OpenApiClient _openApiClient;

  @override
  Future<Profile> fetchProfile() async {
    try {
      final sessionResponse = await _openApiClient.call(
        AppApiOperations.getSession,
      );
      final sessionUser = _extractUser(sessionResponse.data);
      if (sessionUser != null) {
        return _toProfile(sessionUser);
      }

      final accountInfoResponse = await _openApiClient.call(
        AppApiOperations.getAccountInfo,
      );
      final accountInfoMap = asJsonMap(
        accountInfoResponse.data,
        context: 'account-info response',
      );
      final userMap = accountInfoMap['user'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(accountInfoMap['user'] as Map)
          : <String, dynamic>{};
      return _toProfile(userMap);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  Map<String, dynamic>? _extractUser(dynamic raw) {
    if (raw == null) {
      return null;
    }

    final map = asJsonMap(raw, context: 'session response');
    final userRaw = map['user'];
    if (userRaw is Map<String, dynamic>) {
      return userRaw;
    }

    return null;
  }

  Profile _toProfile(Map<String, dynamic> user) {
    final email = ((user['email'] as String?) ?? '').trim();
    final name = ((user['name'] as String?) ?? '').trim();

    final fallbackName = email.isEmpty ? 'Хэрэглэгч' : email.split('@').first;

    return Profile(
      displayName: name.isEmpty ? fallbackName : name,
      email: email.isEmpty ? 'unknown@cargo.app' : email,
    );
  }
}
