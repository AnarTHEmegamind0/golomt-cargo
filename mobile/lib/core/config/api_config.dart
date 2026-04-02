/// API Configuration
class ApiConfig {
  const ApiConfig._();

  /// Base URL for the Cargo API
  static const String baseUrl = 'https://cargo-back.darjs.workers.dev';

  /// API endpoints
  static const String apiPrefix = '/api';
  static const String authPrefix = '/auth';

  /// Connection timeout in milliseconds
  static const int connectTimeout = 30000;

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  /// Send timeout in milliseconds
  static const int sendTimeout = 30000;
}

/// Auth API endpoints
class AuthEndpoints {
  const AuthEndpoints._();

  static const String signUp = '${ApiConfig.authPrefix}/sign-up/email';
  static const String signIn = '${ApiConfig.authPrefix}/sign-in/email';
  static const String signInSocial = '${ApiConfig.authPrefix}/sign-in/social';
  static const String signOut = '${ApiConfig.authPrefix}/sign-out';
  static const String getSession = '${ApiConfig.authPrefix}/get-session';
  static const String refreshToken = '${ApiConfig.authPrefix}/refresh-token';
  static const String getAccessToken =
      '${ApiConfig.authPrefix}/get-access-token';
  static const String changeEmail = '${ApiConfig.authPrefix}/change-email';
  static const String changePassword =
      '${ApiConfig.authPrefix}/change-password';
  static const String verifyPassword =
      '${ApiConfig.authPrefix}/verify-password';
  static const String requestPasswordReset =
      '${ApiConfig.authPrefix}/request-password-reset';
  static const String resetPassword = '${ApiConfig.authPrefix}/reset-password';
  static const String accountInfo = '${ApiConfig.authPrefix}/account-info';
  static const String updateUser = '${ApiConfig.authPrefix}/update-user';
  static const String deleteUser = '${ApiConfig.authPrefix}/delete-user';
  static const String listSessions = '${ApiConfig.authPrefix}/list-sessions';
  static const String listAccounts = '${ApiConfig.authPrefix}/list-accounts';
  static const String revokeSession = '${ApiConfig.authPrefix}/revoke-session';
  static const String revokeSessions =
      '${ApiConfig.authPrefix}/revoke-sessions';
  static const String revokeOtherSessions =
      '${ApiConfig.authPrefix}/revoke-other-sessions';
  static const String unlinkAccount = '${ApiConfig.authPrefix}/unlink-account';
  static const String sendVerificationEmail =
      '${ApiConfig.authPrefix}/send-verification-email';
  static const String verifyEmail = '${ApiConfig.authPrefix}/verify-email';
}

/// Cargo API endpoints
class CargoEndpoints {
  const CargoEndpoints._();

  static const String cargos = '${ApiConfig.apiPrefix}/cargos';
  static String cargoById(String id) => '${ApiConfig.apiPrefix}/cargos/$id';
  static const String search = '${ApiConfig.apiPrefix}/cargos/search';
  static const String stats = '${ApiConfig.apiPrefix}/cargos/stats';
  static String events(String id) => '${ApiConfig.apiPrefix}/cargos/$id/events';
  static String fulfillmentChoice(String id) =>
      '${ApiConfig.apiPrefix}/cargos/$id/fulfillment-choice';
  static String receive(String id) =>
      '${ApiConfig.apiPrefix}/cargos/$id/receive';
  static String ship(String id) => '${ApiConfig.apiPrefix}/cargos/$id/ship';
  static String arrive(String id) => '${ApiConfig.apiPrefix}/cargos/$id/arrive';
  static String recordWeight(String id) =>
      '${ApiConfig.apiPrefix}/cargos/$id/record-weight';
  static String receivedImage(String id) =>
      '${ApiConfig.apiPrefix}/cargos/$id/received-image';
}

/// Branch API endpoints
class BranchEndpoints {
  const BranchEndpoints._();

  static const String branches = '${ApiConfig.apiPrefix}/branches';
}

/// Payment API endpoints
class PaymentEndpoints {
  const PaymentEndpoints._();

  static const String payments = '${ApiConfig.apiPrefix}/payments';
  static const String search = '${ApiConfig.apiPrefix}/payments/search';
  static String markPaid(String id) =>
      '${ApiConfig.apiPrefix}/payments/$id/mark-paid';
}
