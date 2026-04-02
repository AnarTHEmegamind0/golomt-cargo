import 'package:core/core/config/api_config.dart';
import 'package:core/core/networking/api_client.dart';
import 'package:core/core/networking/models/user_model.dart';

/// Auth API Repository
class AuthApiRepository {
  AuthApiRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Sign up with email
  Future<ApiResult<AuthResponse>> signUp({
    required String name,
    required String email,
    required String password,
    String? image,
    String? callbackURL,
    bool rememberMe = true,
  }) async {
    return _apiClient.post(
      AuthEndpoints.signUp,
      data: {
        'name': name,
        'email': email,
        'password': password,
        if (image != null) 'image': image,
        if (callbackURL != null) 'callbackURL': callbackURL,
        'rememberMe': rememberMe,
      },
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sign in with email
  Future<ApiResult<AuthResponse>> signIn({
    required String email,
    required String password,
    String? callbackURL,
    bool rememberMe = true,
  }) async {
    return _apiClient.post(
      AuthEndpoints.signIn,
      data: {
        'email': email,
        'password': password,
        if (callbackURL != null) 'callbackURL': callbackURL,
        'rememberMe': rememberMe,
      },
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sign out
  Future<ApiResult<Map<String, dynamic>>> signOut() async {
    return _apiClient.post(AuthEndpoints.signOut, data: {});
  }

  /// Get current session
  Future<ApiResult<SessionResponse>> getSession() async {
    return _apiClient.get(
      AuthEndpoints.getSession,
      fromJson: (json) {
        if (json == null) {
          return const SessionResponse();
        }
        return SessionResponse.fromJson(json as Map<String, dynamic>);
      },
    );
  }

  /// Change email
  Future<ApiResult<Map<String, dynamic>>> changeEmail({
    required String newEmail,
    String? callbackURL,
  }) async {
    return _apiClient.post(
      AuthEndpoints.changeEmail,
      data: {
        'newEmail': newEmail,
        if (callbackURL != null) 'callbackURL': callbackURL,
      },
    );
  }

  /// Change password
  Future<ApiResult<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
    bool revokeOtherSessions = false,
  }) async {
    return _apiClient.post(
      AuthEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'revokeOtherSessions': revokeOtherSessions,
      },
    );
  }

  /// Verify password
  Future<ApiResult<Map<String, dynamic>>> verifyPassword({
    required String password,
  }) async {
    return _apiClient.post(
      AuthEndpoints.verifyPassword,
      data: {'password': password},
    );
  }

  /// Send verification email
  Future<ApiResult<Map<String, dynamic>>> sendVerificationEmail({
    required String email,
    String? callbackURL,
  }) async {
    return _apiClient.post(
      AuthEndpoints.sendVerificationEmail,
      data: {
        'email': email,
        if (callbackURL != null) 'callbackURL': callbackURL,
      },
    );
  }

  /// Request password reset
  Future<ApiResult<Map<String, dynamic>>> requestPasswordReset({
    required String email,
    String? redirectTo,
  }) async {
    return _apiClient.post(
      AuthEndpoints.requestPasswordReset,
      data: {'email': email, if (redirectTo != null) 'redirectTo': redirectTo},
    );
  }

  /// Reset password
  Future<ApiResult<Map<String, dynamic>>> resetPassword({
    required String newPassword,
    String? token,
  }) async {
    return _apiClient.post(
      AuthEndpoints.resetPassword,
      data: {'newPassword': newPassword, if (token != null) 'token': token},
    );
  }

  /// Get account info
  Future<ApiResult<Map<String, dynamic>>> getAccountInfo() async {
    return _apiClient.get(AuthEndpoints.accountInfo);
  }

  /// Update user profile
  Future<ApiResult<Map<String, dynamic>>> updateUser({
    String? name,
    String? image,
  }) async {
    return _apiClient.post(
      AuthEndpoints.updateUser,
      data: {if (name != null) 'name': name, if (image != null) 'image': image},
    );
  }

  /// Delete user
  Future<ApiResult<Map<String, dynamic>>> deleteUser({
    String? password,
    String? token,
    String? callbackURL,
  }) async {
    return _apiClient.post(
      AuthEndpoints.deleteUser,
      data: {
        if (password != null) 'password': password,
        if (token != null) 'token': token,
        if (callbackURL != null) 'callbackURL': callbackURL,
      },
    );
  }

  /// List all sessions
  Future<ApiResult<List<SessionModel>>> listSessions() async {
    return _apiClient.get(
      AuthEndpoints.listSessions,
      fromJson: (json) {
        if (json is Map<String, dynamic> && json['sessions'] is List) {
          final wrapped = json['sessions'] as List;
          return wrapped
              .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
              .toList(growable: false);
        }

        final list = json as List;
        return list
            .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      },
    );
  }

  /// Revoke specific session
  Future<ApiResult<Map<String, dynamic>>> revokeSession(String token) async {
    return _apiClient.post(AuthEndpoints.revokeSession, data: {'token': token});
  }

  /// Revoke all sessions
  Future<ApiResult<Map<String, dynamic>>> revokeSessions() async {
    return _apiClient.post(AuthEndpoints.revokeSessions, data: {});
  }

  /// Revoke all sessions except the current one
  Future<ApiResult<Map<String, dynamic>>> revokeOtherSessions() async {
    return _apiClient.post(AuthEndpoints.revokeOtherSessions, data: {});
  }

  /// List linked accounts
  Future<ApiResult<List<Map<String, dynamic>>>> listAccounts() async {
    return _apiClient.get(
      AuthEndpoints.listAccounts,
      fromJson: (json) {
        final list = json as List;
        return list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: false);
      },
    );
  }

  /// Unlink social account
  Future<ApiResult<Map<String, dynamic>>> unlinkAccount({
    required String providerId,
    String? accountId,
  }) async {
    return _apiClient.post(
      AuthEndpoints.unlinkAccount,
      data: {
        'providerId': providerId,
        if (accountId != null) 'accountId': accountId,
      },
    );
  }

  /// Refresh token
  Future<ApiResult<Map<String, dynamic>>> refreshToken({
    required String providerId,
    String? accountId,
    String? userId,
  }) async {
    return _apiClient.post(
      AuthEndpoints.refreshToken,
      data: {
        'providerId': providerId,
        if (accountId != null) 'accountId': accountId,
        if (userId != null) 'userId': userId,
      },
    );
  }

  /// Get access token
  Future<ApiResult<Map<String, dynamic>>> getAccessToken({
    required String providerId,
    String? accountId,
    String? userId,
  }) async {
    return _apiClient.post(
      AuthEndpoints.getAccessToken,
      data: {
        'providerId': providerId,
        if (accountId != null) 'accountId': accountId,
        if (userId != null) 'userId': userId,
      },
    );
  }
}
