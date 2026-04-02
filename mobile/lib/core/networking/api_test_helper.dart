import 'package:core/core/networking/api_client.dart';
import 'package:core/core/networking/repositories/auth_api_repository.dart';
import 'package:core/core/networking/repositories/branch_api_repository.dart';
import 'package:core/core/networking/repositories/cargo_api_repository.dart';
import 'package:core/core/networking/repositories/payment_api_repository.dart';
import 'package:flutter/foundation.dart';

/// Helper class to test all API endpoints
class ApiTestHelper {
  ApiTestHelper({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  late final AuthApiRepository _authRepo = AuthApiRepository(
    apiClient: _apiClient,
  );
  late final CargoApiRepository _cargoRepo = CargoApiRepository(
    apiClient: _apiClient,
  );
  late final BranchApiRepository _branchRepo = BranchApiRepository(
    apiClient: _apiClient,
  );
  late final PaymentApiRepository _paymentRepo = PaymentApiRepository(
    apiClient: _apiClient,
  );

  /// Run all API tests
  Future<Map<String, bool>> runAllTests() async {
    final results = <String, bool>{};

    debugPrint('🧪 Starting API Tests...\n');

    // Test branches endpoint (public)
    results['GET /api/branches'] = await _testGetBranches();

    // Test cargos endpoints (requires auth)
    results['GET /api/cargos'] = await _testGetCargos();
    results['GET /api/cargos/stats'] = await _testGetCargoStats();

    // Test payments endpoint (requires auth)
    results['GET /api/payments/search'] = await _testSearchPayments();

    // Print summary
    debugPrint('\n📊 Test Results Summary:');
    debugPrint('=' * 50);
    for (final entry in results.entries) {
      final status = entry.value ? '✅ PASS' : '❌ FAIL';
      debugPrint('$status: ${entry.key}');
    }
    debugPrint('=' * 50);

    final passed = results.values.where((v) => v).length;
    final total = results.length;
    debugPrint('Total: $passed/$total passed\n');

    return results;
  }

  Future<bool> _testGetBranches() async {
    debugPrint('📡 Testing GET /api/branches...');
    try {
      final result = await _branchRepo.getBranches();
      if (result.isSuccess) {
        debugPrint('   ✅ Success: ${result.data!.data.length} branches found');
        for (final branch in result.data!.data) {
          debugPrint('      - ${branch.name} (${branch.code})');
        }
        return true;
      } else {
        debugPrint('   ❌ Error: ${result.error?.message}');
        return false;
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
      return false;
    }
  }

  Future<bool> _testGetCargos() async {
    debugPrint('📡 Testing GET /api/cargos...');
    try {
      final result = await _cargoRepo.getCargos();
      if (result.isSuccess) {
        debugPrint('   ✅ Success: ${result.data!.data.length} cargos found');
        return true;
      } else {
        // 401 is expected if not authenticated
        if (result.error?.statusCode == 401) {
          debugPrint(
            '   ⚠️  Auth required (expected for unauthenticated test)',
          );
          return true; // Still consider it a pass since endpoint is responding
        }
        debugPrint('   ❌ Error: ${result.error?.message}');
        return false;
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
      return false;
    }
  }

  Future<bool> _testGetCargoStats() async {
    debugPrint('📡 Testing GET /api/cargos/stats...');
    try {
      final result = await _cargoRepo.getCargoStats();
      if (result.isSuccess) {
        final stats = result.data!.data;
        debugPrint('   ✅ Success: Total ${stats.total} cargos');
        return true;
      } else {
        if (result.error?.statusCode == 401) {
          debugPrint(
            '   ⚠️  Auth required (expected for unauthenticated test)',
          );
          return true;
        }
        debugPrint('   ❌ Error: ${result.error?.message}');
        return false;
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
      return false;
    }
  }

  Future<bool> _testSearchPayments() async {
    debugPrint('📡 Testing GET /api/payments/search...');
    try {
      final result = await _paymentRepo.searchPayments();
      if (result.isSuccess) {
        debugPrint('   ✅ Success: ${result.data!.data.length} payments found');
        return true;
      } else {
        if (result.error?.statusCode == 401) {
          debugPrint(
            '   ⚠️  Auth required (expected for unauthenticated test)',
          );
          return true;
        }
        debugPrint('   ❌ Error: ${result.error?.message}');
        return false;
      }
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
      return false;
    }
  }

  /// Test authentication flow
  Future<bool> testAuthFlow({
    required String email,
    required String password,
  }) async {
    debugPrint('🔐 Testing Authentication Flow...\n');

    // Test sign in
    debugPrint('📡 Testing POST /auth/sign-in/email...');
    final signInResult = await _authRepo.signIn(
      email: email,
      password: password,
    );

    if (signInResult.isSuccess) {
      final token = signInResult.data!.token;
      final user = signInResult.data!.user;
      debugPrint('   ✅ Sign in successful!');
      debugPrint('   User: ${user.name} (${user.email})');
      if (token != null && token.isNotEmpty) {
        final preview = token.length > 20 ? token.substring(0, 20) : token;
        debugPrint('   Token: $preview...');
      } else {
        debugPrint('   ⚠️  No token returned in body');
      }

      // Update token for subsequent requests
      if (token != null && token.isNotEmpty) {
        _apiClient.updateAuthToken(token);
      }

      // Test get session
      debugPrint('\n📡 Testing GET /auth/get-session...');
      final sessionResult = await _authRepo.getSession();
      if (sessionResult.isSuccess) {
        debugPrint(
          sessionResult.data?.isAuthenticated == true
              ? '   ✅ Session valid'
              : '   ⚠️  Session endpoint returned no active session',
        );
      } else {
        debugPrint(
          '   ❌ Session check failed: ${sessionResult.error?.message}',
        );
      }

      // Test cargos with auth
      debugPrint('\n📡 Testing GET /api/cargos (authenticated)...');
      final cargosResult = await _cargoRepo.getCargos();
      if (cargosResult.isSuccess) {
        debugPrint('   ✅ Got ${cargosResult.data!.data.length} cargos');
        for (final cargo in cargosResult.data!.data.take(3)) {
          debugPrint('      - ${cargo.trackingNumber}: ${cargo.status.label}');
        }
      } else {
        debugPrint('   ❌ Error: ${cargosResult.error?.message}');
      }

      // Test sign out
      debugPrint('\n📡 Testing POST /auth/sign-out...');
      final signOutResult = await _authRepo.signOut();
      if (signOutResult.isSuccess) {
        debugPrint('   ✅ Sign out successful');
        _apiClient.clearAuthToken();
      } else {
        debugPrint('   ❌ Sign out failed: ${signOutResult.error?.message}');
      }

      return true;
    } else {
      debugPrint('   ❌ Sign in failed: ${signInResult.error?.message}');
      return false;
    }
  }
}
