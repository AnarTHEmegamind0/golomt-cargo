import 'package:core/core/networking/openapi_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OpenAPI registry includes core app endpoints', () {
    expect(kOpenApiOperations, isNotEmpty);
    expect(kOpenApiOperations.containsKey('POST /auth/sign-in/email'), isTrue);
    expect(kOpenApiOperations.containsKey('POST /auth/change-email'), isTrue);
    expect(kOpenApiOperations.containsKey('GET /api/cargos'), isTrue);
    expect(kOpenApiOperations.containsKey('POST /api/payments'), isTrue);
    expect(kOpenApiOperations.containsKey('GET /api/branches'), isTrue);
  });
}
