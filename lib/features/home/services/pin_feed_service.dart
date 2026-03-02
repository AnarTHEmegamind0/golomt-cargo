import 'package:core/features/home/models/pin_item.dart';
import 'package:core/features/home/repositories/pin_feed_repository.dart';

class PinFeedService {
  PinFeedService({required PinFeedRepository repository})
    : _repository = repository;

  final PinFeedRepository _repository;

  Future<List<PinItem>> fetchPins() => _repository.fetchPins();
}
