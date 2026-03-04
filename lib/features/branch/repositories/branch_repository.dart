import 'package:core/features/branch/models/branch.dart';

/// Branch repository contract
abstract interface class BranchRepository {
  Future<List<Branch>> fetchAll();
  Future<Branch?> fetchById(String id);
}
