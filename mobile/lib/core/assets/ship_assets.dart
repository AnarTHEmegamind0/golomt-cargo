/// Ship icon assets for the cargo delivery app.
///
/// Usage:
/// ```dart
/// Image.asset(ShipAssets.truck, width: 24, height: 24)
/// // or use ShipIcon widget:
/// ShipIcon(ShipAssets.truck, size: 24, color: Colors.blue)
/// ```
class ShipAssets {
  ShipAssets._();

  static const String _basePath = 'assets/ship';

  // Delivery vehicles
  static const String truck = '$_basePath/truck.png';
  static const String truckAlt = '$_basePath/truck (1).png';
  static const String car = '$_basePath/car.png';
  static const String scooterDelivery = '$_basePath/scooter-delivery.png';
  static const String airplaneDelivery = '$_basePath/airplane-delivery.png';

  // Delivery status
  static const String delivery = '$_basePath/delivery.png';
  static const String deliveryAlt = '$_basePath/delivery (1).png';
  static const String manDeliveringPackage = '$_basePath/man-delivering-package-.png';
  static const String mailArrivedAndHand = '$_basePath/mail-arrived-and-hand-.png';

  // Package & returns
  static const String boxReturn = '$_basePath/box-return.png';
  static const String boxReturnAlt1 = '$_basePath/box-return (1).png';
  static const String boxReturnAlt2 = '$_basePath/box-return (2).png';
  static const String packageReturn = '$_basePath/package-return.png';
  static const String basket = '$_basePath/basket.png';
  static const String handWithCare = '$_basePath/hand-with-care.png';

  // Location & time
  static const String locationMaps = '$_basePath/location-maps.png';
  static const String distance = '$_basePath/distance.png';
  static const String clockAndHome = '$_basePath/clock-and-home.png';

  // Payment & finance
  static const String wallet = '$_basePath/wallet.png';
  static const String moneyBack = '$_basePath/money-back-.png';

  // UI elements
  static const String bell = '$_basePath/bell.png';
  static const String bellAlt = '$_basePath/bell (1).png';
  static const String search = '$_basePath/search.png';
}
