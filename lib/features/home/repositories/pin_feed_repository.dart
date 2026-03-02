import 'package:core/features/home/models/pin_item.dart';

abstract interface class PinFeedRepository {
  Future<List<PinItem>> fetchPins();
}
