class AppApiOperations {
  static const signInSocial = 'POST /auth/sign-in/social';
  static const signInEmail = 'POST /auth/sign-in/email';
  static const signUpEmail = 'POST /auth/sign-up/email';
  static const signOut = 'POST /auth/sign-out';
  static const getSession = 'GET /auth/get-session';
  static const getAccountInfo = 'GET /auth/account-info';
  static const changeEmail = 'POST /auth/change-email';
  static const changePassword = 'POST /auth/change-password';
  static const verifyPassword = 'POST /auth/verify-password';
  static const sendVerificationEmail = 'POST /auth/send-verification-email';
  static const requestPasswordReset = 'POST /auth/request-password-reset';
  static const resetPassword = 'POST /auth/reset-password';
  static const updateUser = 'POST /auth/update-user';
  static const deleteUser = 'POST /auth/delete-user';
  static const listSessions = 'GET /auth/list-sessions';
  static const revokeSession = 'POST /auth/revoke-session';
  static const revokeSessions = 'POST /auth/revoke-sessions';
  static const revokeOtherSessions = 'POST /auth/revoke-other-sessions';
  static const listAccounts = 'GET /auth/list-accounts';
  static const unlinkAccount = 'POST /auth/unlink-account';
  static const refreshToken = 'POST /auth/refresh-token';
  static const getAccessToken = 'POST /auth/get-access-token';

  static const listBranches = 'GET /api/branches';

  static const listCargos = 'GET /api/cargos';
  static const createCargo = 'POST /api/cargos';
  static const searchCargos = 'GET /api/cargos/search';
  static const getCargoById = 'GET /api/cargos/{cargoId}';
  static const chooseCargoFulfillment =
      'POST /api/cargos/{cargoId}/fulfillment-choice';
  static const shipCargo = 'POST /api/cargos/{cargoId}/ship';
  static const arriveCargo = 'POST /api/cargos/{cargoId}/arrive';

  static const createBatchPayment = 'POST /api/payments';

  // Admin - User management
  static const adminListUsers = 'GET /auth/admin/list-users';
  static const adminGetUser = 'GET /auth/admin/get-user';
  static const adminCreateUser = 'POST /auth/admin/create-user';
  static const adminUpdateUser = 'POST /auth/admin/update-user';
  static const adminSetRole = 'POST /auth/admin/set-role';
  static const adminBanUser = 'POST /auth/admin/ban-user';
  static const adminUnbanUser = 'POST /auth/admin/unban-user';

  // Admin - Cargo management
  static const receiveCargo = 'POST /api/cargos/{cargoId}/receive';
  static const recordCargoWeight = 'POST /api/cargos/{cargoId}/record-weight';
}
