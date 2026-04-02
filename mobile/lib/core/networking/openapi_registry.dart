class OpenApiOperation {
  const OpenApiOperation({required this.method, required this.path});

  final String method;
  final String path;
}

const Map<String, OpenApiOperation> kOpenApiOperations = {
  "POST /api/cargos": OpenApiOperation(method: "POST", path: "/api/cargos"),
  "GET /api/cargos": OpenApiOperation(method: "GET", path: "/api/cargos"),
  "POST /api/cargos/{cargoId}/fulfillment-choice": OpenApiOperation(
    method: "POST",
    path: "/api/cargos/{cargoId}/fulfillment-choice",
  ),
  "GET /api/cargos/search": OpenApiOperation(
    method: "GET",
    path: "/api/cargos/search",
  ),
  "GET /api/cargos/stats": OpenApiOperation(
    method: "GET",
    path: "/api/cargos/stats",
  ),
  "GET /api/cargos/{cargoId}": OpenApiOperation(
    method: "GET",
    path: "/api/cargos/{cargoId}",
  ),
  "GET /api/cargos/{cargoId}/events": OpenApiOperation(
    method: "GET",
    path: "/api/cargos/{cargoId}/events",
  ),
  "GET /api/cargos/{cargoId}/received-image": OpenApiOperation(
    method: "GET",
    path: "/api/cargos/{cargoId}/received-image",
  ),
  "POST /api/cargos/{cargoId}/receive": OpenApiOperation(
    method: "POST",
    path: "/api/cargos/{cargoId}/receive",
  ),
  "POST /api/cargos/{cargoId}/ship": OpenApiOperation(
    method: "POST",
    path: "/api/cargos/{cargoId}/ship",
  ),
  "POST /api/cargos/{cargoId}/record-weight": OpenApiOperation(
    method: "POST",
    path: "/api/cargos/{cargoId}/record-weight",
  ),
  "POST /api/cargos/{cargoId}/arrive": OpenApiOperation(
    method: "POST",
    path: "/api/cargos/{cargoId}/arrive",
  ),
  "POST /api/payments": OpenApiOperation(method: "POST", path: "/api/payments"),
  "GET /api/payments/search": OpenApiOperation(
    method: "GET",
    path: "/api/payments/search",
  ),
  "POST /api/payments/{paymentId}/mark-paid": OpenApiOperation(
    method: "POST",
    path: "/api/payments/{paymentId}/mark-paid",
  ),
  "GET /api/branches": OpenApiOperation(method: "GET", path: "/api/branches"),
  "GET /": OpenApiOperation(method: "GET", path: "/"),
  "POST /auth/sign-in/social": OpenApiOperation(
    method: "POST",
    path: "/auth/sign-in/social",
  ),
  "GET /auth/get-session": OpenApiOperation(
    method: "GET",
    path: "/auth/get-session",
  ),
  "POST /auth/sign-out": OpenApiOperation(
    method: "POST",
    path: "/auth/sign-out",
  ),
  "POST /auth/sign-up/email": OpenApiOperation(
    method: "POST",
    path: "/auth/sign-up/email",
  ),
  "POST /auth/sign-in/email": OpenApiOperation(
    method: "POST",
    path: "/auth/sign-in/email",
  ),
  "POST /auth/reset-password": OpenApiOperation(
    method: "POST",
    path: "/auth/reset-password",
  ),
  "POST /auth/verify-password": OpenApiOperation(
    method: "POST",
    path: "/auth/verify-password",
  ),
  "GET /auth/verify-email": OpenApiOperation(
    method: "GET",
    path: "/auth/verify-email",
  ),
  "POST /auth/send-verification-email": OpenApiOperation(
    method: "POST",
    path: "/auth/send-verification-email",
  ),
  "POST /auth/change-email": OpenApiOperation(
    method: "POST",
    path: "/auth/change-email",
  ),
  "POST /auth/change-password": OpenApiOperation(
    method: "POST",
    path: "/auth/change-password",
  ),
  "POST /auth/update-user": OpenApiOperation(
    method: "POST",
    path: "/auth/update-user",
  ),
  "POST /auth/delete-user": OpenApiOperation(
    method: "POST",
    path: "/auth/delete-user",
  ),
  "POST /auth/request-password-reset": OpenApiOperation(
    method: "POST",
    path: "/auth/request-password-reset",
  ),
  "GET /auth/reset-password/{token}": OpenApiOperation(
    method: "GET",
    path: "/auth/reset-password/{token}",
  ),
  "GET /auth/list-sessions": OpenApiOperation(
    method: "GET",
    path: "/auth/list-sessions",
  ),
  "POST /auth/revoke-session": OpenApiOperation(
    method: "POST",
    path: "/auth/revoke-session",
  ),
  "POST /auth/revoke-sessions": OpenApiOperation(
    method: "POST",
    path: "/auth/revoke-sessions",
  ),
  "POST /auth/revoke-other-sessions": OpenApiOperation(
    method: "POST",
    path: "/auth/revoke-other-sessions",
  ),
  "POST /auth/link-social": OpenApiOperation(
    method: "POST",
    path: "/auth/link-social",
  ),
  "GET /auth/list-accounts": OpenApiOperation(
    method: "GET",
    path: "/auth/list-accounts",
  ),
  "GET /auth/delete-user/callback": OpenApiOperation(
    method: "GET",
    path: "/auth/delete-user/callback",
  ),
  "POST /auth/unlink-account": OpenApiOperation(
    method: "POST",
    path: "/auth/unlink-account",
  ),
  "POST /auth/refresh-token": OpenApiOperation(
    method: "POST",
    path: "/auth/refresh-token",
  ),
  "POST /auth/get-access-token": OpenApiOperation(
    method: "POST",
    path: "/auth/get-access-token",
  ),
  "GET /auth/account-info": OpenApiOperation(
    method: "GET",
    path: "/auth/account-info",
  ),
  "GET /auth/ok": OpenApiOperation(method: "GET", path: "/auth/ok"),
  "GET /auth/error": OpenApiOperation(
    method: "GET",
    path: "/auth/error",
  ),
  "POST /auth/admin/set-role": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/set-role",
  ),
  "GET /auth/admin/get-user": OpenApiOperation(
    method: "GET",
    path: "/auth/admin/get-user",
  ),
  "POST /auth/admin/create-user": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/create-user",
  ),
  "POST /auth/admin/update-user": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/update-user",
  ),
  "GET /auth/admin/list-users": OpenApiOperation(
    method: "GET",
    path: "/auth/admin/list-users",
  ),
  "POST /auth/admin/list-user-sessions": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/list-user-sessions",
  ),
  "POST /auth/admin/unban-user": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/unban-user",
  ),
  "POST /auth/admin/ban-user": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/ban-user",
  ),
  "POST /auth/admin/impersonate-user": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/impersonate-user",
  ),
  "POST /auth/admin/stop-impersonating": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/stop-impersonating",
  ),
  "POST /auth/admin/revoke-user-session": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/revoke-user-session",
  ),
  "POST /auth/admin/revoke-user-sessions": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/revoke-user-sessions",
  ),
  "POST /auth/admin/remove-user": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/remove-user",
  ),
  "POST /auth/admin/set-user-password": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/set-user-password",
  ),
  "POST /auth/admin/has-permission": OpenApiOperation(
    method: "POST",
    path: "/auth/admin/has-permission",
  ),
};
