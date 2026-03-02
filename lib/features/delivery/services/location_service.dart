import 'dart:async';

class DriverLocation {
  const DriverLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class LocationService {
  Stream<DriverLocation> trackDriver() async* {
    var tick = 0;
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 2));
      tick++;
      yield DriverLocation(
        latitude: 47.9184 + (tick * 0.00016),
        longitude: 106.9177 + (tick * 0.00013),
      );
    }
  }
}
