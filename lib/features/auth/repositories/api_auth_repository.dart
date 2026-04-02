import 'package:core/core/networking/app_api_operations.dart';
import 'package:core/core/networking/api_client.dart';
import 'package:core/core/networking/api_parsing.dart';
import 'package:core/core/networking/openapi_client.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required OpenApiClient openApiClient,
    required ApiClient apiClient,
  }) : _openApiClient = openApiClient,
       _apiClient = apiClient;

  final OpenApiClient _openApiClient;
  final ApiClient _apiClient;

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.signInEmail,
        data: {'email': email, 'password': password, 'rememberMe': true},
      );

      final body = asJsonMap(response.data, context: 'auth sign-in response');
      _maybeUpdateToken(body);

      return _mapUser(body['user'], fallbackEmail: email);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.signUpEmail,
        data: {'email': email, 'password': password, 'name': name},
      );

      final body = asJsonMap(response.data, context: 'auth sign-up response');
      _maybeUpdateToken(body);

      return _mapUser(body['user'], fallbackEmail: email, fallbackName: name);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<User?> getSessionUser() async {
    try {
      final response = await _openApiClient.call(AppApiOperations.getSession);
      if (response.data == null) {
        return null;
      }

      final body = asJsonMap(response.data, context: 'auth session response');
      final userRaw = body['user'];
      if (userRaw is! Map<String, dynamic>) {
        return null;
      }

      return _mapUser(userRaw);
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<User> getAccountInfo() async {
    try {
      final response = await _openApiClient.call(
        AppApiOperations.getAccountInfo,
      );
      final body = asJsonMap(
        response.data,
        context: 'auth account-info response',
      );
      final userRaw = body['user'] is Map<String, dynamic>
          ? body['user']
          : body;

      return _mapUser(userRaw, fallbackEmail: 'unknown@cargo.app');
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> changeEmail({
    required String newEmail,
    String? callbackURL,
  }) async {
    try {
      await _openApiClient.call(
        AppApiOperations.changeEmail,
        data: {
          'newEmail': newEmail,
          if (callbackURL != null) 'callbackURL': callbackURL,
        },
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    bool revokeOtherSessions = false,
  }) async {
    try {
      await _openApiClient.call(
        AppApiOperations.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'revokeOtherSessions': revokeOtherSessions,
        },
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> requestPasswordReset({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await _openApiClient.call(
        AppApiOperations.requestPasswordReset,
        data: {
          'email': email,
          if (redirectTo != null) 'redirectTo': redirectTo,
        },
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> sendVerificationEmail({
    required String email,
    String? callbackURL,
  }) async {
    try {
      await _openApiClient.call(
        AppApiOperations.sendVerificationEmail,
        data: {
          'email': email,
          if (callbackURL != null) 'callbackURL': callbackURL,
        },
      );
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _openApiClient.call(
        AppApiOperations.signOut,
        data: <String, dynamic>{},
      );
    } catch (_) {
      // Ignore remote sign-out failures to ensure local state is cleared.
    } finally {
      _apiClient.updateAuthToken(null);
    }
  }

  void _maybeUpdateToken(Map<String, dynamic> body) {
    final token = body['token'] as String?;
    if (token != null && token.isNotEmpty) {
      _apiClient.updateAuthToken(token);
    }
  }

  User _mapUser(dynamic raw, {String? fallbackEmail, String? fallbackName}) {
    final userMap = raw is Map<String, dynamic> ? raw : <String, dynamic>{};

    final parsedEmail = (userMap['email'] as String?)?.trim();
    final parsedId = (userMap['id'] as String?)?.trim();
    final parsedName = (userMap['name'] as String?)?.trim();

    final resolvedEmail = (parsedEmail == null || parsedEmail.isEmpty)
        ? (fallbackEmail ?? 'unknown@cargo.app')
        : parsedEmail;

    final resolvedId = (parsedId == null || parsedId.isEmpty)
        ? resolvedEmail
        : parsedId;

    final resolvedName = (parsedName == null || parsedName.isEmpty)
        ? fallbackName
        : parsedName;
    final role = UserRoleParsing.fromString(userMap['role'] as String?);

    return User(
      id: resolvedId,
      email: resolvedEmail,
      name: resolvedName,
      role: role,
    );
  }
}
