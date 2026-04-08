import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';
import 'package:core/features/auth/services/auth_service.dart';
import 'package:core/features/branch/models/branch.dart';
import 'package:core/features/branch/providers/branch_provider.dart';
import 'package:core/features/branch/repositories/branch_repository.dart';
import 'package:core/features/branch/repositories/fake_branch_repository.dart';
import 'package:core/features/branch/services/branch_service.dart';
import 'package:core/features/capture/models/capture_request.dart';
import 'package:core/features/delivery/models/delivery_candidate.dart';
import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:core/features/delivery/providers/delivery_provider.dart';
import 'package:core/features/delivery/repositories/delivery_repository.dart';
import 'package:core/features/delivery/repositories/fake_delivery_repository.dart';
import 'package:core/features/delivery/services/delivery_service.dart';
import 'package:core/features/home/models/pin_item.dart';
import 'package:core/features/home/providers/pin_feed_provider.dart';
import 'package:core/features/home/repositories/fake_pin_feed_repository.dart';
import 'package:core/features/home/repositories/pin_feed_repository.dart';
import 'package:core/features/home/services/pin_feed_service.dart';
import 'package:core/features/orders/models/order.dart';
import 'package:core/features/orders/providers/order_provider.dart';
import 'package:core/features/orders/repositories/fake_order_repository.dart';
import 'package:core/features/orders/repositories/order_repository.dart';
import 'package:core/features/orders/services/order_service.dart';
import 'package:core/features/profile/models/profile.dart';
import 'package:core/features/profile/providers/profile_provider.dart';
import 'package:core/features/profile/repositories/fake_profile_repository.dart';
import 'package:core/features/profile/repositories/profile_repository.dart';
import 'package:core/features/profile/services/profile_service.dart';
import 'package:core/features/settings/providers/settings_provider.dart';
import 'package:core/features/settings/repositories/in_memory_settings_repository.dart';
import 'package:core/features/settings/repositories/settings_repository.dart';
import 'package:core/features/settings/services/settings_service.dart';
import 'package:core/features/shell/service/navigation_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> buildCaptureProviders({
  required CaptureStatePreset preset,
}) {
  return [
    // Auth
    Provider<AuthRepository>(create: (_) => _CaptureAuthRepository()),
    Provider<AuthService>(
      create: (context) => AuthService(authRepository: context.read()),
    ),
    ChangeNotifierProvider<AuthProvider>(
      create: (context) => AuthProvider(authService: context.read()),
    ),

    // Delivery
    Provider<DeliveryRepository>(
      create: (_) => _CaptureDeliveryRepository(preset: preset),
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
      create: (_) => _CaptureOrderRepository(preset: preset),
    ),
    Provider<OrderService>(
      create: (context) => OrderService(repository: context.read()),
    ),
    ChangeNotifierProvider<OrderProvider>(
      create: (context) => OrderProvider(service: context.read()),
    ),

    // Branch
    Provider<BranchRepository>(
      create: (_) => _CaptureBranchRepository(preset: preset),
    ),
    Provider<BranchService>(
      create: (context) => BranchService(repository: context.read()),
    ),
    ChangeNotifierProvider<BranchProvider>(
      create: (context) => BranchProvider(service: context.read()),
    ),

    // Pin Feed (Home)
    Provider<PinFeedRepository>(
      create: (_) => _CapturePinFeedRepository(preset: preset),
    ),
    Provider<PinFeedService>(
      create: (context) => PinFeedService(repository: context.read()),
    ),
    ChangeNotifierProvider<PinFeedProvider>(
      create: (context) => PinFeedProvider(service: context.read()),
    ),

    // Profile
    Provider<ProfileRepository>(
      create: (_) => _CaptureProfileRepository(preset: preset),
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
      create: (context) => SettingsService(settingsRepository: context.read()),
    ),
    ChangeNotifierProvider<SettingsProvider>(
      create: (context) =>
          SettingsProvider(settingsService: context.read())..load(),
    ),

    // Navigation
    ChangeNotifierProvider(create: (_) => NavigationController()),
  ];
}

class _CaptureAuthRepository implements AuthRepository {
  User _user = const User(
    id: 'capture_user',
    email: 'capture@cargo.app',
    name: 'Capture User',
    role: UserRole.customer,
  );

  @override
  Future<User> login({required String email, required String password}) async {
    _user = User(
      id: 'capture_user',
      email: email,
      name: 'Capture User',
      role: UserRole.customer,
    );
    return _user;
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _user = User(
      id: 'capture_user',
      email: email,
      name: name,
      role: UserRole.customer,
    );
    return _user;
  }

  @override
  Future<User?> getSessionUser() async {
    return _user;
  }

  @override
  Future<User> getAccountInfo() async {
    return _user;
  }

  @override
  Future<void> changeEmail({
    required String newEmail,
    String? callbackURL,
  }) async {
    _user = User(
      id: _user.id,
      email: newEmail,
      name: _user.name,
      role: _user.role,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    bool revokeOtherSessions = false,
  }) async {}

  @override
  Future<void> requestPasswordReset({
    required String email,
    String? redirectTo,
  }) async {}

  @override
  Future<void> sendVerificationEmail({
    required String email,
    String? callbackURL,
  }) async {}

  @override
  Future<void> logout() async {
    _user = const User(
      id: 'capture_user',
      email: 'capture@cargo.app',
      name: 'Capture User',
      role: UserRole.customer,
    );
  }
}

class _CaptureOrderRepository implements OrderRepository {
  _CaptureOrderRepository({required this.preset});

  final CaptureStatePreset preset;
  final FakeOrderRepository _delegate = FakeOrderRepository();

  @override
  Future<Order> createOrder({
    required String trackingCode,
    String? productName,
  }) async {
    if (preset == CaptureStatePreset.error) {
      throw Exception('Capture forced error state');
    }
    if (preset == CaptureStatePreset.loading) {
      await Future<void>.delayed(const Duration(minutes: 5));
    }
    return _delegate.createOrder(
      trackingCode: trackingCode,
      productName: productName,
    );
  }

  @override
  Future<List<Order>> fetchAll({String? customerId}) => _run(
    emptyValue: const [],
    onDefault: () => _delegate.fetchAll(customerId: customerId),
  );

  @override
  Future<Order?> fetchById(String id) =>
      _run(emptyValue: null, onDefault: () => _delegate.fetchById(id));

  @override
  Future<List<Order>> fetchByStatus(OrderStatus status) => _run(
    emptyValue: const [],
    onDefault: () => _delegate.fetchByStatus(status),
  );

  @override
  Future<List<Order>> search(String query) =>
      _run(emptyValue: const [], onDefault: () => _delegate.search(query));

  @override
  Future<void> delete(String id) => _runVoid(() => _delegate.delete(id));

  @override
  Future<void> markAsPaid(String id) =>
      _runVoid(() => _delegate.markAsPaid(id));

  @override
  Future<void> requestDelivery(String id) =>
      _runVoid(() => _delegate.requestDelivery(id));

  @override
  Future<void> updateStatus(String id, OrderStatus status) =>
      _runVoid(() => _delegate.updateStatus(id, status));

  Future<T> _run<T>({
    required T emptyValue,
    required Future<T> Function() onDefault,
  }) async {
    switch (preset) {
      case CaptureStatePreset.loading:
        await Future<void>.delayed(const Duration(minutes: 5));
        return onDefault();
      case CaptureStatePreset.error:
        throw Exception('Capture forced error state');
      case CaptureStatePreset.empty:
        return emptyValue;
      case CaptureStatePreset.defaultState:
        return onDefault();
    }
  }

  Future<void> _runVoid(Future<void> Function() onDefault) async {
    if (preset == CaptureStatePreset.error) {
      throw Exception('Capture forced error state');
    }
    await onDefault();
  }
}

class _CaptureBranchRepository implements BranchRepository {
  _CaptureBranchRepository({required this.preset});

  final CaptureStatePreset preset;
  final FakeBranchRepository _delegate = FakeBranchRepository();

  @override
  Future<List<Branch>> fetchAll() =>
      _run(emptyValue: const [], onDefault: _delegate.fetchAll);

  @override
  Future<Branch?> fetchById(String id) =>
      _run(emptyValue: null, onDefault: () => _delegate.fetchById(id));

  Future<T> _run<T>({
    required T emptyValue,
    required Future<T> Function() onDefault,
  }) async {
    switch (preset) {
      case CaptureStatePreset.loading:
        await Future<void>.delayed(const Duration(minutes: 5));
        return onDefault();
      case CaptureStatePreset.error:
        throw Exception('Capture forced error state');
      case CaptureStatePreset.empty:
        return emptyValue;
      case CaptureStatePreset.defaultState:
        return onDefault();
    }
  }
}

class _CaptureDeliveryRepository implements DeliveryRepository {
  _CaptureDeliveryRepository({required this.preset});

  final CaptureStatePreset preset;
  final FakeDeliveryRepository _delegate = FakeDeliveryRepository();

  @override
  Future<List<DeliveryOrder>> fetchActiveOrders({String? customerId}) => _run(
    emptyValue: const [],
    onDefault: () => _delegate.fetchActiveOrders(customerId: customerId),
  );

  @override
  Future<List<DeliveryCandidate>> fetchEligibleCargos({String? customerId}) =>
      _run(
        emptyValue: const [],
        onDefault: () => _delegate.fetchEligibleCargos(customerId: customerId),
      );

  @override
  Future<void> createDeliveryRequest({
    required String cargoId,
    required String deliveryAddress,
    String? deliveryPhone,
  }) async {
    await _delegate.createDeliveryRequest(
      cargoId: cargoId,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
    );
  }

  @override
  Future<void> updateOrderStep({
    required String orderId,
    required DeliveryStep step,
  }) async {
    await _delegate.updateOrderStep(orderId: orderId, step: step);
  }

  @override
  Future<void> uploadProof({
    required String orderId,
    required String localPath,
  }) async {
    await _delegate.uploadProof(orderId: orderId, localPath: localPath);
  }

  Future<T> _run<T>({
    required T emptyValue,
    required Future<T> Function() onDefault,
  }) async {
    switch (preset) {
      case CaptureStatePreset.loading:
        await Future<void>.delayed(const Duration(minutes: 5));
        return onDefault();
      case CaptureStatePreset.error:
        throw Exception('Capture forced error state');
      case CaptureStatePreset.empty:
        return emptyValue;
      case CaptureStatePreset.defaultState:
        return onDefault();
    }
  }
}

class _CapturePinFeedRepository implements PinFeedRepository {
  _CapturePinFeedRepository({required this.preset});

  final CaptureStatePreset preset;
  final FakePinFeedRepository _delegate = FakePinFeedRepository();

  @override
  Future<List<PinItem>> fetchPins() =>
      _run(emptyValue: const [], onDefault: _delegate.fetchPins);

  Future<T> _run<T>({
    required T emptyValue,
    required Future<T> Function() onDefault,
  }) async {
    switch (preset) {
      case CaptureStatePreset.loading:
        await Future<void>.delayed(const Duration(minutes: 5));
        return onDefault();
      case CaptureStatePreset.error:
        throw Exception('Capture forced error state');
      case CaptureStatePreset.empty:
        return emptyValue;
      case CaptureStatePreset.defaultState:
        return onDefault();
    }
  }
}

class _CaptureProfileRepository implements ProfileRepository {
  _CaptureProfileRepository({required this.preset});

  final CaptureStatePreset preset;
  final FakeProfileRepository _delegate = FakeProfileRepository();

  @override
  Future<Profile> fetchProfile() => _run(
    emptyValue: const Profile(
      displayName: 'Хэрэглэгч',
      email: 'empty@cargo.app',
    ),
    onDefault: _delegate.fetchProfile,
  );

  Future<T> _run<T>({
    required T emptyValue,
    required Future<T> Function() onDefault,
  }) async {
    switch (preset) {
      case CaptureStatePreset.loading:
        await Future<void>.delayed(const Duration(minutes: 5));
        return onDefault();
      case CaptureStatePreset.error:
        throw Exception('Capture forced error state');
      case CaptureStatePreset.empty:
        return emptyValue;
      case CaptureStatePreset.defaultState:
        return onDefault();
    }
  }
}
