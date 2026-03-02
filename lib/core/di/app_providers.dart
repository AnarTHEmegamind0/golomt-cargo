import 'package:core/core/networking/api_client.dart';
import 'package:core/core/services/api_service.dart';
import 'package:core/features/delivery/providers/chat_provider.dart';
import 'package:core/features/delivery/providers/delivery_provider.dart';
import 'package:core/features/delivery/providers/driver_notification_provider.dart';
import 'package:core/features/delivery/repositories/delivery_repository.dart';
import 'package:core/features/delivery/repositories/fake_delivery_repository.dart';
import 'package:core/features/delivery/services/chat_service.dart';
import 'package:core/features/delivery/services/delivery_service.dart';
import 'package:core/features/delivery/services/earning_service.dart';
import 'package:core/features/delivery/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';
import 'package:core/features/auth/repositories/fake_auth_repository.dart';
import 'package:core/features/auth/services/auth_service.dart';
import 'package:core/features/home/providers/pin_feed_provider.dart';
import 'package:core/features/home/repositories/fake_pin_feed_repository.dart';
import 'package:core/features/home/repositories/pin_feed_repository.dart';
import 'package:core/features/home/services/pin_feed_service.dart';
import 'package:core/features/profile/providers/profile_provider.dart';
import 'package:core/features/profile/repositories/fake_profile_repository.dart';
import 'package:core/features/profile/repositories/profile_repository.dart';
import 'package:core/features/profile/services/profile_service.dart';
import 'package:core/features/settings/providers/settings_provider.dart';
import 'package:core/features/settings/repositories/in_memory_settings_repository.dart';
import 'package:core/features/settings/repositories/settings_repository.dart';
import 'package:core/features/settings/services/settings_service.dart';
import 'package:core/features/shell/service/navigation_controller.dart';

class AppProviders {
  static List<SingleChildWidget> build() {
    return [
      Provider<AuthRepository>(create: (_) => FakeAuthRepository()),
      Provider<AuthService>(
        create: (context) => AuthService(authRepository: context.read()),
      ),
      ChangeNotifierProvider<AuthProvider>(
        create: (context) => AuthProvider(authService: context.read()),
      ),
      Provider<ApiClient>(
        create: (_) => ApiClient(baseUrl: 'https://api.example.com'),
      ),
      Provider<ApiService>(create: (context) => ApiService(apiClient: context.read())),
      Provider<DeliveryRepository>(create: (_) => FakeDeliveryRepository()),
      Provider<DeliveryService>(
        create: (context) => DeliveryService(repository: context.read()),
      ),
      Provider<LocationService>(create: (_) => LocationService()),
      Provider<EarningService>(create: (_) => const EarningService()),
      Provider<ChatService>(
        create: (_) => ChatService(),
        dispose: (_, service) => service.dispose(),
      ),
      ChangeNotifierProvider<DeliveryProvider>(
        create: (context) => DeliveryProvider(service: context.read()),
      ),
      ChangeNotifierProvider<DriverNotificationProvider>(
        create: (_) => DriverNotificationProvider(),
      ),
      ChangeNotifierProvider<ChatProvider>(
        create: (context) => ChatProvider(chatService: context.read()),
      ),
      Provider<PinFeedRepository>(create: (_) => FakePinFeedRepository()),
      Provider<PinFeedService>(
        create: (context) => PinFeedService(repository: context.read()),
      ),
      ChangeNotifierProvider<PinFeedProvider>(
        create: (context) => PinFeedProvider(service: context.read()),
      ),
      Provider<ProfileRepository>(create: (_) => FakeProfileRepository()),
      Provider<ProfileService>(
        create: (context) => ProfileService(profileRepository: context.read()),
      ),
      ChangeNotifierProvider<ProfileProvider>(
        create: (context) => ProfileProvider(profileService: context.read()),
      ),
      Provider<SettingsRepository>(
        create: (_) => InMemorySettingsRepository(),
      ),
      Provider<SettingsService>(
        create: (context) =>
            SettingsService(settingsRepository: context.read()),
      ),
      ChangeNotifierProvider<SettingsProvider>(
        create: (context) =>
            SettingsProvider(settingsService: context.read())..load(),
      ),
      ChangeNotifierProvider(create: (_) => NavigationController()),
    ];
  }
}
