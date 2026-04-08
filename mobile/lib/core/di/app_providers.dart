import 'package:core/core/networking/api_client.dart';
import 'package:core/core/networking/openapi_client.dart';
import 'package:core/core/networking/repositories/auth_api_repository.dart';
import 'package:core/core/networking/repositories/branch_api_repository.dart';
import 'package:core/core/networking/repositories/cargo_api_repository.dart';
import 'package:core/core/networking/repositories/payment_api_repository.dart';
import 'package:core/core/services/api_service.dart';
import 'package:core/features/admin/providers/admin_branches_provider.dart';
import 'package:core/features/admin/providers/admin_cargos_provider.dart';
import 'package:core/features/admin/providers/admin_finance_provider.dart';
import 'package:core/features/admin/providers/admin_logs_provider.dart';
import 'package:core/features/admin/providers/admin_shipments_provider.dart';
import 'package:core/features/admin/providers/admin_users_provider.dart';
import 'package:core/features/admin/providers/admin_vehicles_provider.dart';
import 'package:core/features/admin/services/pricing_service.dart';
import 'package:core/features/admin/repositories/admin_repository.dart';
import 'package:core/features/admin/repositories/api_admin_repository.dart';
import 'package:core/features/admin/services/admin_service.dart';
import 'package:core/features/china_staff/providers/china_cargo_provider.dart';
import 'package:core/features/branch/providers/branch_provider.dart';
import 'package:core/features/branch/repositories/api_branch_repository.dart';
import 'package:core/features/branch/repositories/branch_repository.dart';
import 'package:core/features/branch/repositories/fake_branch_repository.dart';
import 'package:core/features/branch/services/branch_service.dart';
import 'package:core/features/delivery/providers/delivery_provider.dart';
import 'package:core/features/delivery/repositories/api_delivery_repository.dart';
import 'package:core/features/delivery/repositories/delivery_repository.dart';
import 'package:core/features/delivery/repositories/fake_delivery_repository.dart';
import 'package:core/features/delivery/services/delivery_service.dart';
import 'package:core/features/orders/providers/order_provider.dart';
import 'package:core/features/orders/repositories/api_order_repository.dart';
import 'package:core/features/orders/repositories/fake_order_repository.dart';
import 'package:core/features/orders/repositories/order_repository.dart';
import 'package:core/features/orders/services/order_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/auth/repositories/api_auth_repository.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';
import 'package:core/features/auth/repositories/fake_auth_repository.dart';
import 'package:core/features/auth/services/auth_service.dart';
import 'package:core/features/home/providers/pin_feed_provider.dart';
import 'package:core/features/home/repositories/api_pin_feed_repository.dart';
import 'package:core/features/home/repositories/fake_pin_feed_repository.dart';
import 'package:core/features/home/repositories/pin_feed_repository.dart';
import 'package:core/features/home/services/pin_feed_service.dart';
import 'package:core/features/profile/providers/profile_provider.dart';
import 'package:core/features/profile/repositories/api_profile_repository.dart';
import 'package:core/features/profile/repositories/fake_profile_repository.dart';
import 'package:core/features/profile/repositories/profile_repository.dart';
import 'package:core/features/profile/services/profile_service.dart';
import 'package:core/features/settings/providers/settings_provider.dart';
import 'package:core/features/settings/repositories/in_memory_settings_repository.dart';
import 'package:core/features/settings/repositories/settings_repository.dart';
import 'package:core/features/settings/services/settings_service.dart';
import 'package:core/features/shell/service/navigation_controller.dart';

class AppProviders {
  static List<SingleChildWidget> build({bool useMocks = false}) {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://cargo-back.darjs.workers.dev',
    );

    return [
      // Networking
      Provider<ApiClient>(create: (_) => ApiClient(baseUrl: apiBaseUrl)),
      Provider<ApiService>(
        create: (context) => ApiService(apiClient: context.read()),
      ),
      Provider<OpenApiClient>(
        create: (context) => OpenApiClient(apiService: context.read()),
      ),
      Provider<AuthApiRepository>(
        create: (context) => AuthApiRepository(apiClient: context.read()),
      ),
      Provider<CargoApiRepository>(
        create: (context) => CargoApiRepository(apiClient: context.read()),
      ),
      Provider<BranchApiRepository>(
        create: (context) => BranchApiRepository(apiClient: context.read()),
      ),
      Provider<PaymentApiRepository>(
        create: (context) => PaymentApiRepository(apiClient: context.read()),
      ),

      // Auth
      Provider<AuthRepository>(
        create: (context) => useMocks
            ? FakeAuthRepository()
            : ApiAuthRepository(
                openApiClient: context.read(),
                apiClient: context.read(),
              ),
      ),
      Provider<AuthService>(
        create: (context) => AuthService(authRepository: context.read()),
      ),
      ChangeNotifierProvider<AuthProvider>(
        create: (context) => AuthProvider(authService: context.read()),
      ),

      // Delivery
      Provider<DeliveryRepository>(
        create: (context) => useMocks
            ? FakeDeliveryRepository()
            : ApiDeliveryRepository(openApiClient: context.read()),
      ),
      Provider<DeliveryService>(
        create: (context) => DeliveryService(repository: context.read()),
      ),
      ChangeNotifierProvider<DeliveryProvider>(
        create: (context) => DeliveryProvider(
          service: context.read(),
          customerIdResolver: () => context.read<AuthProvider>().user?.id,
        ),
      ),

      // Orders
      Provider<OrderRepository>(
        create: (context) => useMocks
            ? FakeOrderRepository()
            : ApiOrderRepository(openApiClient: context.read()),
      ),
      Provider<OrderService>(
        create: (context) => OrderService(repository: context.read()),
      ),
      ChangeNotifierProvider<OrderProvider>(
        create: (context) => OrderProvider(
          service: context.read(),
          customerIdResolver: () => context.read<AuthProvider>().user?.id,
        ),
      ),

      // Branch
      Provider<BranchRepository>(
        create: (context) => useMocks
            ? FakeBranchRepository()
            : ApiBranchRepository(openApiClient: context.read()),
      ),
      Provider<BranchService>(
        create: (context) => BranchService(repository: context.read()),
      ),
      ChangeNotifierProvider<BranchProvider>(
        create: (context) => BranchProvider(service: context.read()),
      ),

      // Pin Feed (Home)
      Provider<PinFeedRepository>(
        create: (context) => useMocks
            ? FakePinFeedRepository()
            : ApiPinFeedRepository(openApiClient: context.read()),
      ),
      Provider<PinFeedService>(
        create: (context) => PinFeedService(repository: context.read()),
      ),
      ChangeNotifierProvider<PinFeedProvider>(
        create: (context) => PinFeedProvider(service: context.read()),
      ),

      // Profile
      Provider<ProfileRepository>(
        create: (context) => useMocks
            ? FakeProfileRepository()
            : ApiProfileRepository(openApiClient: context.read()),
      ),
      Provider<ProfileService>(
        create: (context) => ProfileService(profileRepository: context.read()),
      ),
      ChangeNotifierProvider<ProfileProvider>(
        create: (context) => ProfileProvider(profileService: context.read()),
      ),

      // Settings
      Provider<SettingsRepository>(create: (_) => InMemorySettingsRepository()),
      Provider<SettingsService>(
        create: (context) =>
            SettingsService(settingsRepository: context.read()),
      ),
      ChangeNotifierProvider<SettingsProvider>(
        create: (context) =>
            SettingsProvider(settingsService: context.read())..load(),
      ),

      // Admin
      Provider<AdminRepository>(
        create: (context) => ApiAdminRepository(openApiClient: context.read()),
      ),
      Provider<AdminService>(
        create: (context) => AdminService(repository: context.read()),
      ),
      Provider<PricingService>(create: (_) => const PricingService()),
      ChangeNotifierProvider<AdminUsersProvider>(
        create: (context) => AdminUsersProvider(service: context.read()),
      ),
      ChangeNotifierProvider<AdminCargosProvider>(
        create: (context) => AdminCargosProvider(
          adminService: context.read(),
          orderService: context.read(),
        ),
      ),
      ChangeNotifierProvider<AdminVehiclesProvider>(
        create: (context) => AdminVehiclesProvider(adminService: context.read()),
      ),
      ChangeNotifierProvider<AdminShipmentsProvider>(
        create: (context) =>
            AdminShipmentsProvider(adminService: context.read()),
      ),
      ChangeNotifierProvider<AdminFinanceProvider>(
        create: (context) => AdminFinanceProvider(adminService: context.read()),
      ),
      ChangeNotifierProvider<AdminLogsProvider>(
        create: (context) => AdminLogsProvider(adminService: context.read()),
      ),
      ChangeNotifierProvider<AdminBranchesProvider>(
        create: (context) => AdminBranchesProvider(
          adminService: context.read(),
          branchService: context.read(),
        ),
      ),

      // China Staff
      ChangeNotifierProvider<ChinaCargoProvider>(
        create: (context) => ChinaCargoProvider(
          adminService: context.read(),
          orderService: context.read(),
        ),
      ),

      // Navigation
      ChangeNotifierProvider(create: (_) => NavigationController()),
    ];
  }
}
